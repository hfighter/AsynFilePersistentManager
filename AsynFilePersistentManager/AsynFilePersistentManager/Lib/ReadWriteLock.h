//
//  ReadWriteLock.h
//  AsynFilePersistentManager
//
//  Created by hui hong on 2017/6/26.
//  Copyright © 2017年 hui hong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadWriteLock : NSObject

// 读锁
- (void)rdLock;
// 写锁
- (void)wrLock;
// 解锁
- (void)unLock;
// 销毁锁
- (void)destroyLock;

@end
