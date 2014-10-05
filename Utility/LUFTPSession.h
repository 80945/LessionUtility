//
//  LUFTPSession.h
//  LessionUtility
//
//  Created by SFBest on 14-3-31.
//  Copyright (c) 2014年 256. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LUFTPSession : NSObject

+ (id)sharedInstance;
- (void)ftp:(NSString *)filePath progress:(void(^)(float progress))block;

@end
