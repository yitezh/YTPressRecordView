//
//  RecordStatusView.h
//  BaBa
//
//  Created by soma on 2019/4/29.
//  Copyright © 2019 Instanza Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, VoiceActionMode) {
    VoiceMode_ReleaseToSend = 0, //all
    VoiceMode_ReleaseToCancel, //text and emoji
};
NS_ASSUME_NONNULL_BEGIN

@interface YTRecordStatusView : UIView

+ (instancetype)Instance;
- (void)showInWindow;
- (void)dismiss;

@property (assign,nonatomic)VoiceActionMode voiceActionMode;
- (void)updateWithPower:(float)power;
@end

NS_ASSUME_NONNULL_END
