//
//  FileManager.m
//
//  Created by huihong on 2017/6/7.
//  Copyright © 2017年 hfighter. All rights reserved.
//

#import "FileManager.h"
#import "MacroForCache.h"

@implementation FileManager

+ (NSString *)defalutCacheFolder {
    return Cache_Path;
}

+ (BOOL)fileExistWithName:(NSString *)fileName {
    return [FileManager fileExistAtPath:Cache_File_Path(fileName)];
}

+ (BOOL)fileExistAtPath:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (BOOL)createFileWithName:(NSString *)fileName {
    return [FileManager createFileAtPath:Cache_File_Path(fileName)];
}

+ (BOOL)createFileAtPath:(NSString *)filePath {
    BOOL success = YES;
    if (![FileManager fileExistAtPath:filePath]) {
        NSString *folderPath = [filePath stringByDeletingLastPathComponent];
        BOOL folderSuccess = [FileManager createFolderAtPath:folderPath];
        if (!folderSuccess) {
            success = NO;
        } else {
            success = [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        }
    }
    return success;
}

+ (BOOL)createFolderWithName:(NSString *)folderName {
    return [FileManager createFileAtPath:Cache_File_Path(folderName)];
}

+ (BOOL)createFolderAtPath:(NSString *)filePath {
    BOOL success = YES;
    if (![FileManager fileExistAtPath:filePath]) {
        NSError *error;
        success = [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"%s - error is %@", __func__, error);
        }
    }
    return success;
}

+ (void)removeFileWithName:(NSString *)fileName {
    [FileManager removeFileAtPath:Cache_File_Path(fileName)];
}

+ (void)removeFileAtPath:(NSString *)filePath {
    if ([FileManager fileExistAtPath:filePath]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
            NSLog(@"%s -- error is %@", __func__, error);
        }
    }
}

+ (NSUInteger)fileSize:(NSString *)filePath {
    if (![FileManager fileExistAtPath:filePath]) {
        return 0;
    }
    NSError *error;
    NSUInteger size = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error] fileSize];
    NSLog(@"%s -- error is %@", __func__, error);
    return size;
}

+ (void)moveFile:(NSString *)sourceFilePath toFile:(NSString *)descFilePath {
    if (!sourceFilePath || !descFilePath) {
        return;
    }
    if (![FileManager fileExistAtPath:sourceFilePath] || ![FileManager fileExistAtPath:descFilePath]) {
        return;
    }
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtPath:sourceFilePath toPath:descFilePath error:&error];
    NSLog(@"%s -- error is %@", __func__, error);
}

@end
