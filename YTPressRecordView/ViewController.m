//
//  ViewController.m
//  YTPressRecordView
//
//  Created by 易特周 on 2019/5/16.
//  Copyright © 2019 易特周. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "YTHoldButton.h"
#import "YTAudioRecordManager.h"
#import "YTRecordStatusView.h"
#import "YTRecordFileManager.h"
#import "YTAudioPlayerManager.h"
CGFloat  release_distance  = 80;

@interface ViewController ()<YTHoldButtonDelegate>
@property(nonatomic, strong) NSTimer *voiceTimer;
@property (nonatomic,strong) YTHoldButton *holdVoiceButton;
@property (nonatomic,strong)   YTRecordStatusView *recordStatusView;
@property (nonatomic, assign) VoiceActionMode voiceActionMode;
@property (nonatomic, strong) YTAudioPlayerManager *audioPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSubView];
    [self addObser];
}

- (void)initSubView {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, self.view.frame.size.height-30-50, 200, 50)];
    [button setTitle:@"播放" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    button.layer.borderWidth = 0.5;
    button.center = CGPointMake(self.view.frame.size.width/2, button.center.y);
    [button addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.holdVoiceButton = [[YTHoldButton alloc]initWithFrame:CGRectMake(100, self.view.frame.size.height-100-50, 200, 50)];;
    self.holdVoiceButton.backgroundColor = [UIColor whiteColor];
    self.holdVoiceButton.layer.borderWidth = 0.5;
    self.holdVoiceButton.layer.borderColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:205/255.0 alpha:1.0].CGColor;
    self.holdVoiceButton.layer.cornerRadius = 4;
    self.holdVoiceButton.userInteractionEnabled = YES;
    self.holdVoiceButton.delegate = self;
    [self.view addSubview:self.holdVoiceButton];
    
    self.holdVoiceButton.center = CGPointMake(self.view.frame.size.width/2, self.holdVoiceButton.center.y);
    self.recordStatusView = [YTRecordStatusView Instance];
    
}

- (void)addObser {
    //通过kvo监听录音状态
    [[YTAudioRecordManager sharedManager] addObserver:self forKeyPath:@"isRecording" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc{
    [[YTAudioRecordManager sharedManager] removeObserver:self forKeyPath:@"isRecording"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"isRecording"]) {
        bool _isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_isRunning) {
                [self.recordStatusView dismiss];
                [self.recordStatusView showInWindow];
            }
            else {
                [self.recordStatusView dismiss];
            }
        });
    }
}

- (void)voiceButton_touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(authStatus==AVAuthorizationStatusAuthorized) {
        [self prepareRecording];
    }
    else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if(!granted) {
                return ;
            }
        }];
    }
}


- (void)prepareRecording {
    //延迟是为了防止用户快速点击也不停触发录音
    [self performSelector:@selector(beginRecord) withObject:nil afterDelay:0.3];
}

- (void)beginRecord {
    [self startRecording];
    [self stopPowerTimer];
    
    //定时获取音量
    self.voiceTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(powerTimerUpdate) userInfo:nil repeats:true];
    [self.voiceTimer fire];
}

- (void)cancelPrepareing{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginRecord) object:nil];
}


- (void)voiceButton_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch_move");

    UITouch *touch = [touches anyObject];
    CGPoint movePoint = [touch locationInView:self.holdVoiceButton];
     NSLog(@"movePoint:%@",NSStringFromCGPoint(movePoint));
    CGFloat movePoint_y = movePoint.y;
    if(movePoint_y<-release_distance) {
        self.voiceActionMode = VoiceMode_ReleaseToCancel;
    }
    else {
        self.voiceActionMode = VoiceMode_ReleaseToSend;
    }

    [self.recordStatusView setVoiceActionMode: self.voiceActionMode];
}

- (void)voiceButton_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelPrepareing];
    [self stopPowerTimer];
    [self stopRecording];
    
    if(self.voiceActionMode == VoiceMode_ReleaseToSend) {
        NSLog(@"发送消息");
    }
    else if(self.voiceActionMode == VoiceMode_ReleaseToCancel){
        NSLog(@"啥也不做");
    }
    
}

- (void)voiceButton_touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch_cancel");
    [self cancelPrepareing];
    //voip模式，则不进入录音逻辑
    [self stopPowerTimer];
    [self stopRecording];

}

#define record_queue "com.soma.recordQueue"
- (void)startRecording
{
    //正在录音不处理
    dispatch_queue_t recordQ =  dispatch_queue_create(record_queue,
                                                      DISPATCH_QUEUE_SERIAL);
    dispatch_async(recordQ, ^{
        if ([YTAudioRecordManager sharedManager].isRecording) {
            [[YTAudioRecordManager sharedManager] stopRecord];
            return;
        }
        [[YTAudioRecordManager sharedManager] startRecord];
    });
}


- (void)stopRecording
{
    dispatch_queue_t recordQ =  dispatch_queue_create(record_queue,
                                                      DISPATCH_QUEUE_SERIAL);
    dispatch_async(recordQ, ^{
        if ([YTAudioRecordManager sharedManager].isRecording) {
            [[YTAudioRecordManager sharedManager] stopRecord];
        }
    });

}

- (void)powerTimerUpdate
{
    if (![[YTAudioRecordManager sharedManager] isRecording]) {
        return;
    }
    float power = [[YTAudioRecordManager sharedManager] getCurrentPower];
    NSLog(@"power%f",power);
    [self.recordStatusView updateWithPower:power];
}

- (void)stopPowerTimer {
    if (self.voiceTimer) {
        [self.voiceTimer invalidate];
        self.voiceTimer = nil;
    }
}


//播放
- (void)playButtonClicked:(id)sender {
//   NSString *urlString = [YTRecordFileManager cacheFileWidthPath:@"tempRecordPath" Name:@"tempRecord.wav"];
//   self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:urlString] fileTypeHint:AVFileTypeMPEGLayer3 error:nil];
//    AVAudioSession * session = [AVAudioSession sharedInstance];
//    [session setActive:YES error:nil];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//
//    self.audioPlayer.numberOfLoops = 0;
//
//    [self.audioPlayer prepareToPlay];
//    [self.audioPlayer play];
    
    
    
    
    
    self.audioPlayer  = [YTAudioPlayerManager sharedManager];
    [self.audioPlayer  play];
    

}



@end
