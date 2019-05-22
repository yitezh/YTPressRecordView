//
//  YTAudioManager.h
//  YTPressRecordView
//
//  Created by 易特周 on 2019/5/20.
//  Copyright © 2019 易特周. All rights reserved.
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
