//
//  YTAudioManager.m
//  YTPressRecordView
//
//  Created by 易特周 on 2019/5/20.
//  Copyright © 2019 易特周. All rights reserved.
//

#import "YTAudioManager.h"
#import <AVFoundation/AVFoundation.h>

#import "YTRecordFileManager.h"
#define YBufferCount  3
#define YBufferDurationSeconds  0.2
#define YDefaultSampleRate  8000

#define YDefalutChannel  1
#define YBitsPerChannel  16

@interface YTAudioManager() {
    AudioQueueRef audioQRef;       //音频队列对象指针
    AudioStreamBasicDescription recordFormat;   //音频流配置
    AudioQueueBufferRef audioBuffers[YBufferCount];  //音频流缓冲区对象
}

@property(nonatomic,strong)NSString* recordFileName;  //音频目录
@property(nonatomic,assign)AudioFileID recordFileID;   //音频文件标识  用于关联音频文件
@property(nonatomic,assign)SInt64 recordPacket;  //录音文件的当前包
@end



@implementation YTAudioManager 

+  (instancetype)sharedManager {
    
    static YTAudioManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YTAudioManager alloc]init];
    });
    return manager;
    
}

- (instancetype)init {
    if(self == [super init]) {
        [self initConfig] ;
    }
    return self;
    
}

- (void)initConfig {
    [self initFile];
    [self initFormat];
}

- (void)initFile {
    self.recordFileName = [YTRecordFileManager cacheFileWidthPath:@"tempRecordPath" Name:@"tempRecord.wav"] ;
    NSLog(@"recordFile:%@",_recordFileName);
}


-  (void)initFormat {
    recordFormat.mSampleRate =  YDefaultSampleRate;  //采样率
    recordFormat.mChannelsPerFrame = YDefalutChannel; //声道数量
    //编码格式
    recordFormat.mFormatID = kAudioFormatLinearPCM;
    recordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    //每采样点占用位数
    recordFormat.mBitsPerChannel = YBitsPerChannel;
    //每帧的字节数
    recordFormat.mBytesPerFrame = (recordFormat.mBitsPerChannel / 8) * recordFormat.mChannelsPerFrame;
    //每包的字节数
    recordFormat.mBytesPerPacket = recordFormat.mBytesPerFrame;
    //每帧的字节数
    recordFormat.mFramesPerPacket = 1;
}

- (void)initAudio {
    //设置音频输入信息和回调
    OSStatus status = AudioQueueNewInput(&recordFormat, inputBufferHandler, (__bridge void *)(self), NULL, NULL, 0, &audioQRef);
    
    if( status != kAudioSessionNoError )
    {
        NSLog(@"初始化出错");
        return ;
    }
    
    
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)self.recordFileName, NULL);
    //创建音频文件夹
    AudioFileCreateWithURL(url, kAudioFileCAFType, &recordFormat, kAudioFileFlags_EraseFile,&_recordFileID);
    CFRelease(url);
    
    //计算估算的缓存区大小
    int frames = (int)ceil(YBufferDurationSeconds * recordFormat.mSampleRate);
    int bufferByteSize = frames * recordFormat.mBytesPerFrame;
    //        NSLog(@"缓存区大小%d",bufferByteSize);
    //创建缓冲器
    for (int i = 0; i < YBufferCount; i++){
        AudioQueueAllocateBuffer(audioQRef, bufferByteSize, &audioBuffers[i]);
        AudioQueueEnqueueBuffer(audioQRef, audioBuffers[i], 0, NULL);
    }
    
    self.recordPacket = 0;
}

//回调
void inputBufferHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{
    YTAudioManager *audioManager = [YTAudioManager sharedManager];
    if (inNumPackets > 0) {
        //写入文件
        AudioFileWritePackets(audioManager.recordFileID, FALSE, inBuffer->mAudioDataByteSize,inPacketDesc, audioManager.recordPacket, &inNumPackets, inBuffer->mAudioData);
        audioManager.recordPacket += inNumPackets;
    }
    if (audioManager.isRecording) {
       //把存有音频数据的Buffer插入到AudioQueue内置的Buffer队列中
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
    
}

- (void)startRecord
{
    [YTRecordFileManager removeFileAtPath:self.recordFileName];
    
    [self initAudio];
   
    //当有音频设备（比如播放音乐）导致改变时 需要配置
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    OSStatus status = AudioQueueStart(audioQRef, NULL);
    if( status != kAudioSessionNoError )
    {
        NSLog(@"开始出错");
        return;
    }
    self.isRecording = true;
    
    // 设置可以更新声道的power信息
    [self performSelectorOnMainThread:@selector(enableUpdateLevelMetering) withObject:nil waitUntilDone:NO];
    
}

- (float)getCurrentPower {
    UInt32 dataSize = sizeof(AudioQueueLevelMeterState) * recordFormat.mChannelsPerFrame;
    AudioQueueLevelMeterState *levels = (AudioQueueLevelMeterState*)malloc(dataSize);
    //kAudioQueueProperty_EnableLevelMetering的getter
    OSStatus rc = AudioQueueGetProperty(audioQRef, kAudioQueueProperty_CurrentLevelMeter, levels, &dataSize);
    if (rc) {
        NSLog(@"NoiseLeveMeter>>takeSample - AudioQueueGetProperty(CurrentLevelMeter) returned %@", rc);
    }
    
    float channelAvg = 0;
    for (int i = 0; i < recordFormat.mChannelsPerFrame; i++) {
        channelAvg += levels[i].mPeakPower;  //取个平均值 
    }
    free(levels);
    
    // This works because in this particular case one channel always has an mAveragePower of 0.
    return channelAvg;
}

- (BOOL)enableUpdateLevelMetering
{
    UInt32 val = 1;
    //kAudioQueueProperty_EnableLevelMetering的setter
    OSStatus status = AudioQueueSetProperty(audioQRef, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32));
    if( status == kAudioSessionNoError )
    {
        return YES;
    }
    
    return NO;
}


- (void)stopRecord
{
    if (self.isRecording)
    {
        self.isRecording = NO;
        //停止录音队列和移，这里无需考虑成功与否
        AudioQueueStop(audioQRef, true);
        AudioFileClose(_recordFileID);
    
    }
}


- (void)dealloc {
    AudioQueueDispose(audioQRef, TRUE);
    AudioFileClose(_recordFileID);
}

@end
