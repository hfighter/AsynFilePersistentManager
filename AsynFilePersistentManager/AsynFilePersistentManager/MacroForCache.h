//
//  MacroForCache.h
//
//  Created by huihong on 2017/6/8.
//  Copyright © 2017年 hfighter. All rights reserved.
//

#ifndef MacroForCache_h
#define MacroForCache_h

#define File_Path(folder, fileName) [folder stringByAppendingPathComponent:fileName]
#define Cache_Path ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"Cache"])
#define Cache_File_Path(fileName) (File_Path(Cache_Path, fileName))
#define Tmp_File_Path(fileName) (File_Path(Cache_Path, fileName))

#define GetLock() dispatch_semaphore_create(1)
#define Lock(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER)
#define UnLock(lock) dispatch_semaphore_signal(lock)

#define GlobalQueue() (dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))

#define ReadFile(filePath) [NSKeyedUnarchiver unarchiveObjectWithFile:filePath]
#define WriteFile(obj, filePath) [NSKeyedArchiver archiveRootObject:obj toFile:filePath]

#define WeakSelf(self)  __weak typeof(self) weakSelf = self
#define StrongSelf(self) __strong typeof(self) strongSelf = self
#define Big_File_Size (5*1024*1024)

#endif /* MacroForCache_h */
