//
//  WWHoldButton.m
//  BaBa
//
//  Created by soma on 2019/4/23.
//  Copyright © 2019 Instanza Inc. All rights reserved.
//

#import "WWHoldButton.h"
@interface WWHoldButton ()

@end
#define SCALE(s)                         ((s) / 375.0 * SCREEN_WIDTH)
@implementation WWHoldButton




- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    UILabel *label = [[UILabel alloc]initWithFrame:self.frame];
    label.text = NSLocalizedString(@"talkview.hold2talk", nil);
    label.textColor = [UIColor colorWithHex:0x8E8E93];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.titleLabel = label;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.titleLabel.frame = self.bounds;
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGFloat extra = - SCALE(20);
    CGRect newRect = CGRectInset(self.bounds, 0, extra);
    return CGRectContainsPoint(newRect, point);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [UIColor colorWithHex:0xDDDDDD];
    if([self.delegate respondsToSelector:@selector(voiceButton_touchesBegan:withEvent:)]) {
        [self.delegate voiceButton_touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.backgroundColor = [UIColor colorWithHex:0xDDDDDD];
    if([self.delegate respondsToSelector:@selector(voiceButton_touchesMoved:withEvent:)]) {
        [self.delegate voiceButton_touchesMoved:touches withEvent:event];
    }
}
//
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [UIColor whiteColor];
    if([self.delegate respondsToSelector:@selector(voiceButton_touchesEnded:withEvent:)]) {
        [self.delegate voiceButton_touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [UIColor whiteColor];
    if([self.delegate respondsToSelector:@selector(voiceButton_touchesCancelled:withEvent:)]) {
        [self.delegate voiceButton_touchesCancelled:touches withEvent:event];
    }
}


@end
