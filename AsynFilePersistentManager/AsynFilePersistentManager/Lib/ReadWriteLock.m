//
//  ReadWriteLock.m
//  AsynFilePersistentManager
//
//  Created by hui hong on 2017/6/26.
//  Copyright © 2017年 hui hong. All rights reserved.
//

#import "ReadWriteLock.h"
#import <pthread.h>

@implementation ReadWriteLock
{
    pthread_rwlock_t _lock;
}

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        int result = pthread_rwlock_init(&_lock, NULL);
        if (result != 0) {
            NSLog(@"初始化读写锁失败-%@", @(result));
        }
    }
    return self;
}

- (void)dealloc {
    [self destroyLock];
}

#pragma mark - public methods

- (void)rdLock {
    int result = pthread_rwlock_tryrdlock(&_lock);
    if (result != 0) {
        NSLog(@"加读锁失败-%@", @(result));
    }
}

- (void)wrLock {
    int result = pthread_rwlock_trywrlock(&_lock);
    if (result != 0) {
        NSLog(@"加写锁失败-%@", @(result));
    }
}

- (void)unLock {
    int result = pthread_rwlock_unlock(&_lock);
    if (result != 0) {
        NSLog(@"解锁失败-%@", @(result));
    }
}

- (void)destroyLock {
    int result = pthread_rwlock_destroy(&_lock);
    if (result != 0) {
        NSLog(@"销毁锁失败-%@", @(result));
    }
}

@end
