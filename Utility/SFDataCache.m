//
//  SFDataCache.m
//  SFBestIphone
//
//  Created by SFBest on 13-12-25.
//  Copyright (c) 2013年 sfbest. All rights reserved.
//

#import "SFDataCache.h"

@implementation SFDataCache
{
    
}
+ (id)sharedInstance {
    static SFDataCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[SFDataCache alloc] init];
    });
    return cache;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}

- (void)copyFileToDictoryWithName:fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *regionInfoFilePath = [self directoryWithFileName:fileName];
    if ([fileManager fileExistsAtPath:regionInfoFilePath] == NO)
    {
        NSString *regionResourcePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        BOOL isSuccess = [fileManager copyItemAtPath:regionResourcePath toPath:regionInfoFilePath error:&error];
        if (isSuccess)
        {
            NSLog(@"copy %@ info success!", fileName);
        }
        else
        {
            NSLog(@"error: %@", error);
        }
    }
}


#pragma mark -
#pragma mark - File
- (NSString *)directoryWithFileName:(NSString *)fileName
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:fileName];
    return path;
}

- (BOOL)writeData:(id)data toFile:(NSString *)fileName
{
    NSString *fullPath = [self directoryWithFileName:fileName];
    NSData *tmpData = [NSKeyedArchiver archivedDataWithRootObject:data];
    NSError *error = nil;
    BOOL flag = [tmpData writeToFile:fullPath options:NSDataWritingAtomic error:&error];
    NSAssert(flag, @"%s", __FUNCTION__);
    return flag;
}

- (id)dataInFile:(NSString *)fileName
{
    NSString *fullPath = [self directoryWithFileName:fileName];
    
    id data = nil;
    @try
    {
        data = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
    }
    @catch (NSException *exception)
    {
        if ([exception isKindOfClass:[NSInvalidArgumentException class]])
        {
            data = nil;
        }
    }
    @finally
    {
        
    }
        
    return data;
}
- (id)dataInPath:(NSString *)path {
    id data = nil;
    @try
    {
        data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    @catch (NSException *exception)
    {
        if ([exception isKindOfClass:[NSInvalidArgumentException class]])
        {
            data = nil;
        }
    }
    @finally
    {
        
    }
    
    return data;
}

#pragma mark -
#pragma mark - NSUserDefaults
- (BOOL)writeData:(id)data toUserDefaultsWithKey:(NSString *)key {
    NSData *tmpData = [NSKeyedArchiver archivedDataWithRootObject:data];
    [[NSUserDefaults standardUserDefaults] setObject:tmpData forKey:key];
    BOOL flag = [[NSUserDefaults standardUserDefaults] synchronize];
    NSAssert(flag, @"%s", __FUNCTION__);
    return flag;
}
- (id)dataInUserdefaults:(NSString *)key {
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}
@end
