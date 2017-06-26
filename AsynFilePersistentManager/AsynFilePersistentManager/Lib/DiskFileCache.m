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
#import "ReadWriteLock.h"

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
    ReadWriteLock *lock = [[DiskFileCache sharedInstance] getLockByFilePath:filePath];
    [lock wrLock];
    BOOL success = [data writeToFile:filePath atomically:YES];
    [lock unLock];
    return success;
}

+ (void)asynCoverWrite:(NSData *)data toPath:(NSString *)filePath finished:(WriteFinished)finished {
    dispatch_async(GlobalQueue(), ^{
        BOOL success = [DiskFileCache synCoverWrite:data toPath:filePath];
        if (finished) {
            finished(success);
        }
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
        if (finished) {
            finished(success);
        }
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
    if (!filePath || ![FileManager fileExistAtPath:filePath]) {
        return nil;
    }
    NSInteger size = [FileManager fileSize:filePath];
    NSError *error;
    NSData *data;
    ReadWriteLock *lock = [[DiskFileCache sharedInstance] getLockByFilePath:filePath];
    [lock rdLock];
    if (size > Big_File_Size) {
        data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    } else {
        data = [NSData dataWithContentsOfFile:filePath];
    }
    [lock unLock];
    NSLog(@"error is %@", error);
    return data;
}

+ (void)asynRead:(NSString *)filePath finished:(ReadAllFinished)finished {
    dispatch_async(GlobalQueue(), ^{
        NSData *data = [DiskFileCache synRead:filePath];
        if (finished) {
            finished(data, YES);
        }
    });
}

+ (void)synRead:(NSString *)filePath withSize:(NSUInteger)size progress:(ReadBlockFinished)progress over:(ReadFileOver)over {
    [DiskFileCache read:filePath bySize:size progress:progress over:over];
}

+ (void)asynRead:(NSString *)filePath withSize:(NSUInteger)size progress:(ReadBlockFinished)progress over:(ReadFileOver)over {
    dispatch_async(GlobalQueue(), ^{
        [DiskFileCache read:filePath bySize:size progress:progress over:over];
    });
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

//- (dispatch_semaphore_t)getLockByFilePath:(NSString *)filePath {
//    if (!filePath) {
//        return nil;
//    }
//    dispatch_semaphore_t lock = [_lockCache objectForKey:filePath];
//    if (!lock) {
//        lock = GetLock();
//        [_lockCache setObject:lock forKey:filePath];
//    }
//    return lock;
//}

- (ReadWriteLock *)getLockByFilePath:(NSString *)filePath {
    if (!filePath) {
        return nil;
    }
    ReadWriteLock *lock = [_lockCache objectForKey:filePath];
    if (!lock) {
        lock = [[ReadWriteLock alloc] init];
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
    ReadWriteLock *lock = [[DiskFileCache sharedInstance] getLockByFilePath:filePath];
    [lock wrLock];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle synchronizeFile];
    [fileHandle closeFile];
    [lock unLock];
    return YES;
}

+ (void)read:(NSString *)filePath bySize:(NSUInteger)size progress:(ReadBlockFinished)progress over:(ReadFileOver)over {
    if (!filePath || ![FileManager fileExistAtPath:filePath]) {
        if (over) {
            over();
        }
        return;
    }
    ReadWriteLock *lock = [[DiskFileCache sharedInstance] getLockByFilePath:filePath];
    [lock rdLock];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    unsigned long long fileSize = [fileHandle seekToEndOfFile];
    unsigned long long index = 0;
    unsigned long long readSize = 0; // 已读大小
    unsigned long long nextSizeToRead = fileSize > size ? size : fileSize; // 下一次要读的大小
    NSData *data;
    while (readSize <= fileSize) {
        @autoreleasepool {
            if (nextSizeToRead <= 0) {
                break;
            }
            [fileHandle seekToFileOffset:readSize];
            data = [fileHandle readDataOfLength:nextSizeToRead];
            if (progress) {
                progress(data, index, YES);
            }
            index ++;
            readSize += nextSizeToRead;
            
            if (fileSize >= (readSize + size)) {
                nextSizeToRead = size;
            } else {
                nextSizeToRead = fileSize - readSize;
            }
        }
    }
    if (over) {
        over();
    }
    [fileHandle closeFile];
    [lock unLock];
}

#pragma mark - delegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    NSLog(@"lock [%@] is removed from cache", obj);
}

@end
