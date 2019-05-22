//
//  YTPlayerManager.m
//  YTPressRecordView
//
//  Created by 易特周 on 2019/5/20.
//  Copyright © 2019 易特周. All rights reserved.
//

#import "YTAudioPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import "YTRecordFileManager.h"

#define YBufferCount  3
#define YBufferDurationSeconds  0.2
#define YDefaultSampleRate  8000

#define YDefalutChannel  1
#define YBitsPerChannel  16
@interface YTAudioPlayerManager() {
    AudioQueueRef audioQRef;       //音频队列对象指针
    
    AudioQueueBufferRef audioBuffers[YBufferCount];  //音频流缓冲区对象
    AudioStreamPacketDescription  *mPacketDescs;
}

@property(nonatomic,strong)NSString* playFileName;  //音频目录
@property(nonatomic,assign)AudioFileID playFileID;   //音频文件标识  用于关联音频文件
@property(nonatomic,assign)AudioStreamBasicDescription basicFormat;
@property(nonatomic,assign)AudioStreamPacketDescription  *packetFormat; //数据包的格式不同时会不同

@property(nonatomic,assign)UInt32  mNumPacketsToRead;   //记录包的数量

@property(nonatomic,assign)SInt64 playPacket;   //当前读取包的index
@end


@implementation YTAudioPlayerManager

+  (instancetype)sharedManager {
    
    static YTAudioPlayerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YTAudioPlayerManager alloc]init];
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
}

- (void)initFile {
    self.playFileName = [YTRecordFileManager cacheFileWidthPath:@"tempRecordPath" Name:@"tempRecord.wav"] ;
    NSLog(@"recordFile:%@",_playFileName);
}

- (void)initAudio {
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.playFileName]) {
        NSLog(@"文件不存在");
        return;
    }
    
    //打开audioFile
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)self.playFileName, NULL);
    AudioFileOpenURL(url, kAudioFileReadPermission, kAudioFileCAFType, &_playFileID);
    CFRelease(url);
    
    
    //获取audio的format(就是我们录制的时候配置的参数)
    UInt32 dateFormatSize = sizeof(self.basicFormat);
    AudioFileGetProperty(self.playFileID, kAudioFilePropertyDataFormat, &dateFormatSize, &_basicFormat);
    
    
    UInt32 maxPacketSize;
    UInt32 propertySize = sizeof(maxPacketSize);
    AudioFileGetProperty(self.playFileID, kAudioFilePropertyPacketSizeUpperBound, &propertySize, &maxPacketSize);
    
    
    //UInt32
    UInt32 outBufferSize = [self computeBufferSize:self.basicFormat maxPackSize:maxPacketSize time:0.2];
    //Packet的数量
    self.mNumPacketsToRead = outBufferSize / maxPacketSize;
    
    OSStatus status = AudioQueueNewOutput(&_basicFormat, outputBufferHandler, (__bridge void *)(self), NULL, NULL, 0, &audioQRef);
    
    if( status != kAudioSessionNoError )
    {
        NSLog(@"初始化出错");
        return ;
    }
    
    //    在整个Core Audio中可能会用到三种不同的packets：
    //    CBR (constant bit rate) formats：例如 linear PCM and IMA/ADPCM，所有的packet使用相同的大小。
    //    VBR (variable bit rate) formats：例如 AAC，Apple Lossless，MP3，所有的packets拥有相同的frames，但是每个sample中的bits数目不同。
    //    VFR (variable frame rate) formats：packets拥有数目不同的的frames。
    bool isFormatVBR = (self.basicFormat.mBytesPerPacket == 0 ||self. basicFormat.mFramesPerPacket == 0);
    
    if (isFormatVBR) {
        self.packetFormat =(AudioStreamPacketDescription*) malloc (self.mNumPacketsToRead * sizeof (AudioStreamPacketDescription));
    } else {
        self.packetFormat = NULL;  // linearPCM
    }
    
    //创建缓冲器
    for (int i = 0; i < YBufferCount; i++){
        AudioQueueAllocateBuffer(audioQRef, outBufferSize, &audioBuffers[i]);
        outputBufferHandler((__bridge void * _Nullable)(self),audioQRef,audioBuffers[i]);
    }

}


- (UInt32)computeBufferSize:(AudioStreamBasicDescription )inDesc  maxPackSize:(UInt32)maxPacketSize time:(Float64)inSeconds {
    UInt32 outBufferSize;
    
    static const int maxBufferSize = 0x10000;
    static const int minBufferSize = 0x4000;
    
    if (inDesc.mFramesPerPacket != 0) {
        //如果每个Packet不止一个Frame，则按照包进行计算
        Float64 numPacketsForTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * inSeconds;
        outBufferSize = numPacketsForTime * maxPacketSize;
    } else {
        //如果每个Packet只有一个Frame，则直接确定缓冲区大小
        outBufferSize = maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize;
    }
    
    if (outBufferSize > maxBufferSize && outBufferSize > maxPacketSize){
        outBufferSize = maxBufferSize;
    }
    else {
        if (outBufferSize < minBufferSize){
            outBufferSize = minBufferSize;
        }
    }
    return outBufferSize;
}


//回调的触发时机是在某个buffer被用完的时候，需要在方法内部把数据填充满，填充内容是你从AudioFile中读取的。
void outputBufferHandler(void * __nullable outUserData,AudioQueueRef outAQ,AudioQueueBufferRef outBuffer)
{
    YTAudioPlayerManager *audioManager = (__bridge YTAudioPlayerManager *)outUserData;
    UInt32 numBytesReadFromFile = 2048;
    UInt32 numPackets = audioManager.mNumPacketsToRead;
    AudioFileReadPacketData(audioManager.playFileID, false, &numBytesReadFromFile, audioManager.packetFormat, audioManager.playPacket, &numPackets, outBuffer->mAudioData);
    if(numPackets>0) {
        outBuffer->mAudioDataByteSize = numBytesReadFromFile;
        audioManager.playPacket += numPackets;
        AudioQueueEnqueueBuffer(outAQ, outBuffer, 0, NULL);
    }
    else {
        NSLog(@"播完啦");
        [audioManager stopPlay];
    }
    
}

- (void)play{
    self.playPacket = 0;
    if(self.isPlaying) {
        [self stopPlay];
    }
    [self initAudio];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    OSStatus status = AudioQueueStart(audioQRef, NULL);
    if( status != kAudioSessionNoError )
    {
        NSLog(@"开始出错");
        return;
    }
    self.isPlaying = YES;
 
}


- (void)stopPlay
{
    if (self.isPlaying)
    {
        self.isPlaying = NO;
        //停止录音队列和移，这里无需考虑成功与否
        AudioQueueStop(audioQRef, YES);
        AudioFileClose(_playFileID);
        
        AudioQueueDispose(audioQRef, YES);
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
}


- (void)dealloc {
    AudioQueueDispose(audioQRef, YES);
    AudioFileClose(_playFileID);
}



@end
