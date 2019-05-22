//
//  WWHoldButton.m
//  BaBa
//
//  Created by soma on 2019/4/23.
//  Copyright © 2019 Instanza Inc. All rights reserved.
//

#import "YTHoldButton.h"
#import "UIColor+Hex.h"
@interface YTHoldButton ()

@end
#define SCALE(s)                         ((s) / 375.0 * SCREEN_WIDTH)
@implementation YTHoldButton

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    UILabel *label = [[UILabel alloc]initWithFrame:self.bounds];
    label.text = @"按下说话";
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.titleLabel = label;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.titleLabel.frame = self.bounds;
    
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
