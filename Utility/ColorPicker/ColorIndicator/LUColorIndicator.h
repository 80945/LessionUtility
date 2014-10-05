//
//  LUColorIndicator.h
//  LessionUtility
//
//  Created by 256 on 6/1/14.
//  Copyright (c) 2014 256. All rights reserved.
//

/*
 圆形的颜色指示器，带有圆形白边
 */
#import <UIKit/UIKit.h>

@interface LUColorIndicator : UIView

@property (nonatomic, assign) BOOL alphaMode;
@property (nonatomic, strong) UIColor *color;

+ (LUColorIndicator *) colorIndicator;

@end
