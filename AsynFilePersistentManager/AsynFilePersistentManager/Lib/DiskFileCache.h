//
//  DiskFileCache.h
//  AsynFilePersistentManager
//
//  Created by hui hong on 2017/6/22.
//  Copyright © 2017年 hui hong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YKDiskCacheWriteType)
{
    YKDiskCacheWriteTypeCover,  // 覆盖写
    YKDiskCacheWriteTypeAppend  // 追加写
};

// 考虑iCloud同步问题

/**
 写文件结束时回调
 */
typedef void(^WriteFinished)(BOOL success);
typedef void(^ReadAllFinished) (NSData *data, BOOL success);
typedef void(^ReadBlockFinished) (NSData *data, NSUInteger index, BOOL success);
typedef void(^ReadFileOver)();

@interface DiskFileCache : NSObject

// 覆盖写文件
+ (BOOL)synCoverWrite:(NSData *)data toPath:(NSString *)filePath;
+ (void)asynCoverWrite:(NSData *)data toPath:(NSString *)filePath finished:(WriteFinished)finished;

// 追加写文件
+ (BOOL)synAppendWrite:(NSData *)data toPath:(NSString *)filePath;
+ (void)asynAppendWrite:(NSData *)data toPath:(NSString *)filePath finished:(WriteFinished)finished;

// 可自定义文件类型写文件
+ (void)synWrite:(NSData *)data toPath:(NSString *)filePath writeType:(YKDiskCacheWriteType)writeType;
+ (void)asynWrite:(NSData *)data toPath:(NSString *)filePath writeType:(YKDiskCacheWriteType)writeType finished:(WriteFinished)finished;

// 一次性读取文件
+ (NSData *)synRead:(NSString *)filePath;
+ (void)asynRead:(NSString *)filePath finished:(ReadAllFinished)finished;

// 每次读取size大小数据，直到文件读取完成（上传数据时）
+ (void)synReadWithSize:(NSUInteger)size progress:(ReadBlockFinished)progress over:(ReadFileOver)over;
+ (void)asynReadWithSize:(NSUInteger)size progress:(ReadBlockFinished)progress over:(ReadFileOver)over;

@end
