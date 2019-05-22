//
//  YTPlayerManager.h
//  YTPressRecordView
//
//  Created by soma on 2019/4/29.
//  Copyright © 2019 Instanza Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YTAudioPlayerManager : NSObject

@property (assign,nonatomic)BOOL isPlaying;

+  (instancetype)sharedManager;

- (void)play;

@end

NS_ASSUME_NONNULL_END
