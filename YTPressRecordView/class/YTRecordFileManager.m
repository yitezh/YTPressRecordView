//
//  RecordFileManager.m
//  YTPressRecordView
//
//  Created by 易特周 on 2019/5/20.
//  Copyright © 2019 易特周. All rights reserved.
//

#import "YTRecordFileManager.h"

@implementation YTRecordFileManager

+ (NSString *)cacheFileWidthPath:(NSString *)path Name:(NSString *)name {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath= [cachePath stringByAppendingPathComponent:path];;
    
    // 先创建子目录
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        NSLog(@"已创建文件夹");
    }
    NSString *recordFileName = [filePath stringByAppendingPathComponent:name];
    return recordFileName;
//    NSLog(@"recordFile:%@");
}

+ (void)removeFileAtPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
}


@end
