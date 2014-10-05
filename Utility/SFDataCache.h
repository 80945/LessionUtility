//
//  SFDataCache.h
//  SFBestIphone
//
//  Created by SFBest on 13-12-25.
//  Copyright (c) 2013年 sfbest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFDataCache : NSObject

+ (id)sharedInstance;

- (BOOL)writeData:(id)data toFile:(NSString *)fileName;
- (id)dataInFile:(NSString *)fileName;
- (id)dataInPath:(NSString *)path;

- (BOOL)writeData:(id)data toUserDefaultsWithKey:(NSString *)key;
- (id)dataInUserdefaults:(NSString *)key;

@end
