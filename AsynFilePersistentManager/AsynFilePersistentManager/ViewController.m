//
//  ViewController.m
//  AsynFilePersistentManager
//
//  Created by hui hong on 2017/6/22.
//  Copyright © 2017年 hui hong. All rights reserved.
//

#import "ViewController.h"
#import "FileManager.h"

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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
