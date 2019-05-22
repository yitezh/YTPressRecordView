//
//  BBVoiceRecordPowerAnimationView.m
//  BaBa
//
//  Created by soma on 2019/4/29.
//  Copyright © 2019 Instanza Inc. All rights reserved.
//


#import "YTRecordPowerAnimationView.h"

@interface YTRecordPowerAnimationView ()

@property (nonatomic, strong) UIImageView *imgContent;
@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation YTRecordPowerAnimationView




- (void)updateWithPower:(float)power
{
    int viewCount = ceil(fabs(power)*20);
    viewCount =  MIN(viewCount, 9);
    viewCount =  MAX(viewCount, 1);
    
    CGFloat itemHeight = 3;
    CGFloat itemPadding = 3.5;
    CGFloat maskPadding = itemHeight*viewCount + (viewCount)*itemPadding;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, self.frame.size.height - maskPadding,  self.frame.size.width,  self.frame.size.height)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    maskLayer.path = path.CGPath;
    
    self.imgContent.layer.mask = maskLayer;
    
}

- (UIImageView *)imgContent{
    if(!_imgContent) {
        _imgContent = [UIImageView new];
        _imgContent.backgroundColor = [UIColor clearColor];
        _imgContent.image = [UIImage imageNamed:@"record_ripple"];
        [self addSubview:_imgContent];
        _imgContent.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    return _imgContent;
}

@end
