//
//  RecordFileManager.h
//  YTPressRecordView
//
//  Created by soma on 2019/4/29.
//  Copyright © 2019 Instanza Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YTRecordFileManager : NSObject
+ (NSString *)cacheFileWidthPath:(NSString *)path Name:(NSString *)name;
+ (void)removeFileAtPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
