//
//  FileManager.h
//
//  Created by huihong on 2017/6/7.
//  Copyright © 2017年 hfighter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (NSString *)defalutCacheFolder;

/**
 判断cache中文件是否存在

 @param fileName 文件名
 @return 返回结果
 */
+ (BOOL)fileExistWithName:(NSString *)fileName;

/**
 判断文件是否存在

 @param filePath 文件全路径
 @return 返回结果
 */
+ (BOOL)fileExistAtPath:(NSString *)filePath;

/**
 默认在cache中创建文件

 @param fileName 文件名
 */
+ (BOOL)createFileWithName:(NSString *)fileName;

/**
 在指定目录创建文件

 @param filePath 文件全路径
 */
+ (BOOL)createFileAtPath:(NSString *)filePath;

/**
 默认在cache中创建目录

 @param folderName 目录名
 */
+ (BOOL)createFolderWithName:(NSString *)folderName;

/**
 在指定目录创建子目录

 @param filePath 目录的全路径
 */
+ (BOOL)createFolderAtPath:(NSString *)filePath;

/**
 删除默认目录cache下的文件

 @param fileName 文件名
 */
+ (void)removeFileWithName:(NSString *)fileName;

/**
删除指定目录中的文件

 @param filePath 文件所在目录
 */
+ (void)removeFileAtPath:(NSString *)filePath;

/**
 获取文件大小
 */
+ (NSUInteger)fileSize:(NSString *)filePath;

/**
 移动文件
 */
+ (void)moveFile:(NSString *)sourceFilePath toFile:(NSString *)descFilePath;

@end
