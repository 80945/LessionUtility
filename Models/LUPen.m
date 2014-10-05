//
//  LUPen.m
//  LessionUtility
//
//  Created by SFBest on 14-5-6.
//  Copyright (c) 2014年 256. All rights reserved.
//

#import "LUPen.h"

#define kLUPenCodeColor @"kLUPenCodeColor"
#define kLUPenCodeWidth @"kLUPenCodeWidth"
#define kLUPenCodeAlpha @"kLUPenCodeAlpha"
#define kLUPenCodeType  @"kLUPenCodeType"

@implementation LUPen

- (id)init {
    if (self = [super init]) {
        _type = LUPenTypeDefault;
        _color = [UIColor blackColor];
        _alpha = 1;
        _width = 10;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_color forKey:kLUPenCodeColor];
    [aCoder encodeFloat:_width forKey:kLUPenCodeWidth];
    [aCoder encodeFloat:_alpha forKey:kLUPenCodeAlpha];
    [aCoder encodeInteger:_type forKey:kLUPenCodeType];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self) {
        self.color = [aDecoder decodeObjectForKey:kLUPenCodeColor];
        self.width = [aDecoder decodeFloatForKey:kLUPenCodeWidth];
        self.alpha = [aDecoder decodeFloatForKey:kLUPenCodeAlpha];
        self.type = [aDecoder decodeIntegerForKey:kLUPenCodeType];
    }
    return self;
}
@end
