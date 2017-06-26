//
//  ViewController.m
//  AsynFilePersistentManager
//
//  Created by hui hong on 2017/6/22.
//  Copyright © 2017年 hui hong. All rights reserved.
//

#import "ViewController.h"
#import "FileManager.h"
#import "DiskFileCache.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Test"];
//    [FileManager createFolderAtPath:path];
    NSString *path1 = [path stringByAppendingPathComponent:@"test1.txt"];
    NSString *path2 = [path stringByAppendingPathComponent:@"test2.txt"];
    [FileManager removeFileAtPath:path2];
    [FileManager createFileAtPath:path1];
    [FileManager removeFileAtPath:path2];
    
    NSLog(@"path is %@", path1);
    NSLog(@"path1 is %@", path2);
    [FileManager moveFile:path1 toFile:path2];
    
    NSInteger a = 10;
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:@(a)];
    NSLog(@"data1 is %@", data1);
//    [DiskFileCache synCoverWrite:data1 toPath:path1];
//    [DiskFileCache synCoverWrite:data1 toPath:path1];
//    [DiskFileCache synCoverWrite:data1 toPath:path1];
//    [DiskFileCache synCoverWrite:data1 toPath:path1];
    NSLog(@"read number is %@", [NSKeyedUnarchiver unarchiveObjectWithData:[DiskFileCache synRead:path1]]);
    [DiskFileCache asynCoverWrite:data1 toPath:path1 finished:nil];
    [DiskFileCache asynCoverWrite:data1 toPath:path1 finished:nil];
//    [DiskFileCache asynCoverWrite:data1 toPath:path1 finished:nil];
//    [DiskFileCache asynCoverWrite:data1 toPath:path1 finished:nil];
//    NSLog(@"read number is %@", [NSKeyedUnarchiver unarchiveObjectWithData:[DiskFileCache synRead:path1]]);
    
    NSString *path3 = [[NSBundle mainBundle] pathForResource:@"QQ_mac_5.5.1" ofType:@"dmg"];
    NSLog(@"path3 is %@", path3);
    
//    NSLog(@"file data is %@", [DiskFileCache synRead:path3]);
//    NSLog(@"\n");
//    [DiskFileCache asynRead:path3 finished:^(NSData *data, BOOL success) {
//        NSLog(@"----data is----- %@", data);
//    }];
//    NSLog(@"----------------\n");
//    [DiskFileCache asynRead:path3 withSize:3000 progress:^(NSData *data, NSUInteger index, BOOL success) {
//        NSLog(@"data is %@, index is %@", data, @(index));
//    } over:^{
//        NSLog(@"read over");
//    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
