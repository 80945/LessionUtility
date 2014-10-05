//
//  UIColor+HSB_RGB.h
//  LessionUtility
//
//  Created by 256 on 6/1/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HSB_RGB)

@property (nonatomic, readonly) CGFloat hue;
@property (nonatomic, readonly) CGFloat saturation;
@property (nonatomic, readonly) CGFloat brightness;
@property (nonatomic, readonly) CGFloat alpha;
@property (nonatomic, readonly) CGFloat red;
@property (nonatomic, readonly) CGFloat green;
@property (nonatomic, readonly) CGFloat blue;

void HSVtoRGB(float h, float s, float v, float *r, float *g, float *b);
void RGBtoHSV(float r, float g, float b, float *h, float *s, float *v);


- (UIColor *)convertHSBColorToRGBColor;

- (UIColor *)convertRGBColorToHSBColor;

- (UIColor *)opaqueColor;
@end
