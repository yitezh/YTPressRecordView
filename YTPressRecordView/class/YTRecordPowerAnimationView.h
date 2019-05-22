//
//  BBVoiceRecordPowerAnimationView.h
//  BaBa
//
//  Created by soma on 2019/4/29.
//  Copyright © 2019 Instanza Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface YTRecordPowerAnimationView : UIView

@property (nonatomic, assign) CGSize originSize;
- (void)updateWithPower:(float)power;

@end
