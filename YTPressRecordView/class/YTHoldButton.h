//
//  WWHoldButton.h
//  BaBa
//
//  Created by soma on 2019/4/23.
//  Copyright © 2019 Instanza Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol YTHoldButtonDelegate <NSObject>

- (void)voiceButton_touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)voiceButton_touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event ;
- (void)voiceButton_touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)voiceButton_touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
@end

@interface YTHoldButton : UIView
@property (strong,nonatomic)UILabel *titleLabel;

@property (weak,nonatomic)id<YTHoldButtonDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
