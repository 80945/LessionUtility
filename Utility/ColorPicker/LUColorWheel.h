//
//  LUColorWheel.h
//  LessionUtility
//
//  Created by 256 on 6/3/14.
//  Copyright (c) 2014 256. All rights reserved.
//

/*
 拾取颜色的圆环
 */
#import <UIKit/UIKit.h>

@interface LUColorWheel : UIControl

@property (nonatomic) UIColor *color;
@property (nonatomic, readonly) int radius;
@property (nonatomic, assign) float hue;


@end
