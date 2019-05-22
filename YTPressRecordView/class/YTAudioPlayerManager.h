//
//  YTPlayerManager.h
//  YTPressRecordView
//
//  Created by 易特周 on 2019/5/20.
//  Copyright © 2019 易特周. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YTAudioPlayerManager : NSObject

@property (assign,nonatomic)BOOL isPlaying;

+  (instancetype)sharedManager;

- (void)play;

@end

NS_ASSUME_NONNULL_END
