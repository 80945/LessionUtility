//
//  NSString+Date.m
//  SFBestIphone
//
//  Created by SFBest on 14-3-10.
//  Copyright (c) 2014年 sfbest. All rights reserved.
//

#import "NSString+Date.h"

@implementation NSString (Date)

- (NSDate *)date {
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:self];
    return date;
}
- (NSDateComponents *)dateComponent {
    NSDate *date = [self date];
    return [self dateComponent:date];
}
- (NSDateComponents *)dateComponent:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    return comps;
}
- (NSInteger)day {
    NSDateComponents *comps = [self dateComponent];
    return comps.day;
}
- (NSString *)weekDay {
    //int week=0;week1是星期天,week7是星期六;
    NSDateComponents *comps = [self dateComponent];
    NSInteger week = [comps weekday];
    NSString *str = nil;
    switch (week) {
        case 1:
            str = @"星期日";
            break;
        case 2:
            str = @"星期一";
            break;
        case 3:
            str = @"星期二";
            break;
        case 4:
            str = @"星期三";
            break;
        case 5:
            str = @"星期四";
            break;
        case 6:
            str = @"星期五";
            break;
        case 7:
            str = @"星期六";
            break;
            
        default:
            break;
    }
    NSDateComponents *today = [self dateComponent:[NSDate date]];
    if (today.day == comps.day) {
        str = @"今天";
    }
    return str;
}

+ (NSString *)stringDate:(NSInteger)timeInterval {
    NSString *result = nil;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    result = [formatter stringFromDate:date];
    return result;
}
+ (NSString *)stringShortDate:(NSInteger)timeInterval {
    NSString *result = nil;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    result = [formatter stringFromDate:date];
    return result;
}

+ (NSString *)stringTimeScale:(NSInteger)timeInterval {
    NSString *result = nil;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    if (timeInterval < 3600) {
        [formatter setDateFormat:@"mm:ss"];
    } else {
        [formatter setDateFormat:@"HH:mm:ss"];
    }
    result = [formatter stringFromDate:date];
    return result;
}

+ (NSString *)currentTime {
    NSString *result = nil;
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd_HHmmss"];
    result = [formatter stringFromDate:date];
    return result;
}
@end
