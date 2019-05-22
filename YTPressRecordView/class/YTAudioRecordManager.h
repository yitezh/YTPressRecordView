//
//  YTAudioManager.h
//  YTPressRecordView
//
//  Created by 易特周 on 2019/5/20.
//  Copyright © 2019 易特周. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YTAudioManager : NSObject
+  (instancetype)sharedManager;


@property(nonatomic,assign)BOOL isRecording;
- (void)startRecord;
- (void)stopRecord;
- (float)getCurrentPower;
@end

NS_ASSUME_NONNULL_END
