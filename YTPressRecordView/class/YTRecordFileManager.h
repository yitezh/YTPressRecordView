//
//  RecordFileManager.h
//  YTPressRecordView
//
//  Created by 易特周 on 2019/5/20.
//  Copyright © 2019 易特周. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YTRecordFileManager : NSObject
+ (NSString *)cacheFileWidthPath:(NSString *)path Name:(NSString *)name;
+ (void)removeFileAtPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
