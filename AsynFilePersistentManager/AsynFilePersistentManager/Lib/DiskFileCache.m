//
//  DiskFileCache.m
//  AsynFilePersistentManager
//
//  Created by hui hong on 2017/6/22.
//  Copyright © 2017年 hui hong. All rights reserved.
//

#import "DiskFileCache.h"
#import "FileManager.h"
#import "MacroForCache.h"

@interface DiskFileCache ()<NSCacheDelegate>

@property (nonatomic, strong) NSCache *lockCache;

@end

@implementation DiskFileCache

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _lockCache = [[NSCache alloc] init];
        _lockCache.delegate = self;
    }
    return self;
}

#pragma mark - public methods

+ (BOOL)synCoverWrite:(NSData *)data toPath:(NSString *)filePath {
    if (!data || !filePath) {
        return NO;
    }
    if (![FileManager fileExistAtPath:filePath]) {
        [FileManager createFileAtPath:filePath];
    }
    dispatch_semaphore_t lock = [[DiskFileCache sharedInstance] getLockByFilePath:filePath];
    Lock(lock);
    BOOL success = WriteFile(data, filePath);
    UnLock(lock);
    return success;
}

+ (void)asynCoverWrite:(NSData *)data toPath:(NSString *)filePath finished:(WriteFinished)finished {
    dispatch_async(GlobalQueue(), ^{
        BOOL success = [DiskFileCache synCoverWrite:data toPath:filePath];
        finished(success);
    });
}

+ (BOOL)synAppendWrite:(NSData *)data toPath:(NSString *)filePath {
    if (!data || !filePath) {
        return NO;
    }
    if (![FileManager fileExistAtPath:filePath]) {
        [FileManager createFileAtPath:filePath];
    }
    return [DiskFileCache write:data toFile:filePath];
}

+ (void)asynAppendWrite:(NSData *)data toPath:(NSString *)filePath finished:(WriteFinished)finished {
    dispatch_async(GlobalQueue(), ^{
        BOOL success = [DiskFileCache synAppendWrite:data toPath:filePath];
        finished(success);
    });
}

+ (void)synWrite:(NSData *)data toPath:(NSString *)filePath writeType:(YKDiskCacheWriteType)writeType {
    if (YKDiskCacheWriteTypeCover == writeType) {
        [self synCoverWrite:data toPath:filePath];
    } else {
        [self synAppendWrite:data toPath:filePath];
    }
}

+ (void)asynWrite:(NSData *)data toPath:(NSString *)filePath writeType:(YKDiskCacheWriteType)writeType finished:(WriteFinished)finished {
    if (YKDiskCacheWriteTypeCover == writeType) {
        [self asynCoverWrite:data toPath:filePath finished:finished];
    } else {
        [self asynAppendWrite:data toPath:filePath finished:finished];
    }
}

+ (NSData *)synRead:(NSString *)filePath {
    return nil;
}

+ (void)asynRead:(NSString *)filePath finished:(ReadAllFinished)finished {
    
}

+ (void)synReadWithSize:(NSUInteger)size progress:(ReadBlockFinished)progress over:(ReadFileOver)over {
    
}

+ (void)asynReadWithSize:(NSUInteger)size progress:(ReadBlockFinished)progress over:(ReadFileOver)over {
    
}

#pragma mark - private methods

+ (instancetype)sharedInstance {
    static DiskFileCache *diskCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        diskCache = [[DiskFileCache alloc] init];
    });
    return diskCache;
}

- (NSString *)tmpFolderPath {
    return Tmp_File_Path(@"tmp");
}

- (NSString *)createTmpFile:(NSString *)fileName {
    NSString *tmpFilePath = [[self tmpFolderPath] stringByAppendingPathComponent:fileName];
    if (![FileManager fileExistAtPath:tmpFilePath]) {
        [FileManager createFileAtPath:tmpFilePath];
    }
    return tmpFilePath;
}

- (void)removeTempFile:(NSString *)fileName {
    NSString *filePath = [[self tmpFolderPath] stringByAppendingPathComponent:fileName];
    if ([FileManager fileExistAtPath:filePath]) {
        [FileManager removeFileAtPath:filePath];
    }
}

- (dispatch_semaphore_t)getLockByFilePath:(NSString *)filePath {
    if (!filePath) {
        return nil;
    }
    dispatch_semaphore_t lock = [_lockCache objectForKey:filePath];
    if (!lock) {
        lock = GetLock();
        [_lockCache setObject:lock forKey:filePath];
    }
    return lock;
}

+ (BOOL)write:(NSData *)data toFile:(NSString *)filePath {
    if (!data || !filePath) {
        return NO;
    }
    if (![FileManager fileExistAtPath:filePath]) {
        [FileManager createFileAtPath:filePath];
    }
    dispatch_semaphore_t lock = [[DiskFileCache sharedInstance] getLockByFilePath:filePath];
    Lock(lock);
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    unsigned long long offset = [fileHandle seekToEndOfFile];
    [fileHandle seekToFileOffset:offset];
    [fileHandle writeData:data];
    [fileHandle synchronizeFile];
    [fileHandle closeFile];
    UnLock(lock);
    return YES;
}

#pragma mark - delegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    NSLog(@"lock [%@] is removed from cache", obj);
}

@end
