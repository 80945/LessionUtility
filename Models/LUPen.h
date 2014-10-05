//
//  LUPen.h
//  LessionUtility
//
//  Created by SFBest on 14-5-6.
//  Copyright (c) 2014年 256. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    LUPenTypeDefault = 0,
    LUPenTypeLine,
    LUPenTypeRect,
    LUPenTypeRectArea,
    LUPenTypeCircle,
    LUPenTypeCircleArea,
    LUPenTypeErease
} LUPenType;

@interface LUPen : NSObject
<
NSCoding
>

@property (nonatomic, assign) LUPenType type;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) float     width;
@property (nonatomic, assign) float     alpha;

@end
