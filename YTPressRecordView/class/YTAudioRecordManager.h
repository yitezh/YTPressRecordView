//
//  YTAudioManager.h
//  YTPressRecordView
//
//  Created by soma on 2019/4/29.
//  Copyright © 2019 Instanza Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YTAudioRecordManager : NSObject
+  (instancetype)sharedManager;


@property(nonatomic,assign)BOOL isRecording;
//开始播放
- (void)startRecord;
//停止播放
- (void)stopRecord;

//获取音量
- (float)getCurrentPower;
@end

NS_ASSUME_NONNULL_END
