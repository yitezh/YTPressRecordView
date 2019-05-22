//
//  RecordStatusView.m
//  BaBa
//
//  Created by soma on 2019/4/29.
//  Copyright © 2019 Instanza Inc. All rights reserved.
//

#import "YTRecordStatusView.h"
#import "YTRecordPowerAnimationView.h"
#import "UIView+Additions.h"
@interface YTRecordStatusView()
@property (strong,nonatomic)UIImageView *backImageView;
@property (strong,nonatomic)UILabel *statusLabel;
@property (strong,nonatomic)UIImageView *statusImageView;
@property (strong,nonatomic)YTRecordPowerAnimationView *recordRippleImageView;
@end

CGFloat leftMargin =40;
CGFloat sizeNumber =136;
NSInteger recordViewTag = 12462727;
@implementation YTRecordStatusView

+ (instancetype)Instance {
    YTRecordStatusView *recordView = [[YTRecordStatusView alloc]initWithFrame:CGRectMake(0, 0, sizeNumber, sizeNumber)];
    recordView.tag = recordViewTag;
    [recordView initSubViews];
    return recordView;
}


- (void)initSubViews {
    [self addSubview:self.backImageView];
    [self addSubview:self.statusImageView];
    [self addSubview:self.recordRippleImageView];
    [self addSubview:self.statusLabel];
    
    self.statusImageView.topValue = 30;
    self.recordRippleImageView.bottomValue = self.statusImageView.bottomValue;
    _statusImageView.leftValue = leftMargin;
    self.recordRippleImageView.frame =CGRectMake(CGRectGetMaxX(self.statusImageView.frame)+10, self.recordRippleImageView.frame.origin.y, self.recordRippleImageView.widthValue, self.statusImageView.heightValue);
    self.recordRippleImageView.originSize =  self.recordRippleImageView.frame.size;
    self.statusLabel.topValue = self.heightValue - self.statusLabel.heightValue-10;
    [self.recordRippleImageView updateWithPower:9];
}



- (void)setVoiceActionMode:(VoiceActionMode)voiceActionMode {
    _voiceActionMode = voiceActionMode;
    if(voiceActionMode == VoiceMode_ReleaseToSend) {
        _statusLabel.text =  @"松开发送";
        _statusImageView.image = [UIImage imageNamed:@"voice_record_send"];
    }
    else if(voiceActionMode == VoiceMode_ReleaseToCancel){
        _statusLabel.text = @"松开取消";
        _statusImageView.image = [UIImage imageNamed:@"voice_record_cancel"];

    }
    [self layoutImageView];
}

- (void)layoutImageView {
    if(_voiceActionMode == VoiceMode_ReleaseToSend) {
         self.recordRippleImageView.hidden = NO;
        _statusImageView.leftValue = leftMargin;
    }
    else if(_voiceActionMode == VoiceMode_ReleaseToCancel){
        self.recordRippleImageView.centerYValue = self.widthValue/2;
        self.recordRippleImageView.hidden = YES;
    }
}

- (void)updateWithPower:(float)power{
    [self.recordRippleImageView updateWithPower:power];
}


- (void)showInWindow{
    [self setVoiceActionMode:VoiceMode_ReleaseToSend];
    UIWindow *keyWindow =  [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    self.center = CGPointMake(keyWindow.frame.size.width/2, keyWindow.frame.size.height/2);
}

- (void)dismiss {
    if(self.superview)
    {
      [self removeFromSuperview];
    }
}


- (UIImageView *)backImageView {
    if(!_backImageView) {
        _backImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _backImageView.backgroundColor =  [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
        _backImageView.layer.cornerRadius = 8;
    }
    return _backImageView;
    
}

- (UILabel *)statusLabel{
    if(!_statusLabel) {
        _statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.widthValue, 18)];
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.text = NSLocalizedString(@"omg_voice_record_cancel_tip", nil);
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.font = [UIFont systemFontOfSize:12];
    }
    return _statusLabel;
}

- (UIImageView *)statusImageView {
    if(!_statusImageView) {
        _statusImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"voice_record_send"]];
    }
    return _statusImageView;
}


- (YTRecordPowerAnimationView *)recordRippleImageView{
    if(!_recordRippleImageView) {
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"record_ripple"]];
        _recordRippleImageView = [[YTRecordPowerAnimationView alloc]initWithFrame:imageView.bounds];
     
        
    }
    return _recordRippleImageView;
}



@end
