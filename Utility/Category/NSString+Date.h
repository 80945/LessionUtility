//
//  NSString+Date.h
//  SFBestIphone
//
//  Created by SFBest on 14-3-10.
//  Copyright (c) 2014年 sfbest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Date)

// only yyyy-MM-dd supported
- (NSDate *)date;
- (NSDateComponents *)dateComponent;
- (NSString *)weekDay;
- (NSInteger)day;
+ (NSString *)stringDate:(NSInteger)timeInterval;
+ (NSString *)stringShortDate:(NSInteger)timeInterval;
+ (NSString *)stringTimeScale:(NSInteger)timeInterval;
+ (NSString *)currentTime;
@end
