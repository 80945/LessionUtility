//
//  UIColor+HSB_RGB.m
//  LessionUtility
//
//  Created by 256 on 6/1/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import "UIColor+HSB_RGB.h"

@implementation UIColor (HSB_RGB)

- (UIColor *)opaqueColor {
    UIColor *color = [self convertRGBColorToHSBColor];
    color = [color colorWithAlphaComponent:1];
    return color;
}

- (UIColor *)convertHSBColorToRGBColor {
    
    UIColor *resultColor = nil;
    CGFloat hue, saturation, brightness, alpha;
    BOOL flag = [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    if (flag) {
        CGFloat red, green, blue;
        HSVtoRGB(hue, saturation, brightness, &red, &green, &blue);
        resultColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    } else {
        NSLog(@"your colorspace is RGB, the convert operation is not needed");
        resultColor = self;
    }
    return resultColor;
}
- (UIColor *)convertRGBColorToHSBColor {
    
    UIColor *resultColor = nil;
    CGFloat r, g, b, alpah;
    BOOL flag = [self getRed:&r green:&g blue:&b alpha:&alpah];
    if (flag) {
        CGFloat hub, saturation, brightness;
        RGBtoHSV(r, g, b, &hub, &saturation, &brightness);
        resultColor = [UIColor colorWithHue:hub saturation:saturation brightness:brightness alpha:alpah];
    } else {
        NSLog(@"your colorspace is RGB, the convert operation is not needed");
        resultColor = self;
    }
    return resultColor;
}

void HSVtoRGB(float h, float s, float v, float *r, float *g, float *b)
{
    if (s == 0) {
        *r = *g = *b = v;
    } else {
        float   f,p,q,t;
        int     i;
        
        h *= 360;
        
        if (h == 360.0f) {
            h = 0.0f;
        }
        
        h /= 60;
        i = floor(h);
        
        f = h - i;
        p = v * (1.0 - s);
        q = v * (1.0 - (s*f));
        t = v * (1.0 - (s * (1.0 - f)));
        
        switch (i) {
            case 0: *r = v; *g = t; *b = p; break;
            case 1: *r = q; *g = v; *b = p; break;
            case 2: *r = p; *g = v; *b = t; break;
            case 3: *r = p; *g = q; *b = v; break;
            case 4: *r = t; *g = p; *b = v; break;
            case 5: *r = v; *g = p; *b = q; break;
        }
    }
}

void RGBtoHSV(float r, float g, float b, float *h, float *s, float *v)
{
    float max = MAX(r, MAX(g, b));
    float min = MIN(r, MIN(g, b));
    float delta = max - min;
    
    *v = max;
    *s = (max != 0.0f) ? (delta / max) : 0.0f;
    
    if (*s == 0.0f) {
        *h = 0.0f;
    } else {
        if (r == max) {
            *h = (g - b) / delta;
        } else if (g == max) {
            *h = 2.0f + (b - r) / delta;
        } else if (b == max) {
            *h = 4.0f + (r - g) / delta;
        }
        
        *h *= 60.0f;
        
        if (*h < 0.0f) {
            *h += 360.0f;
        }
    }
    
    *h /= 360.0f;
}

#pragma mark -
#pragma mark - propertys
- (CGFloat)hue {
    CGFloat hue_ = -1;
    BOOL flag = [[self convertRGBColorToHSBColor] getHue:&hue_ saturation:nil brightness:nil alpha:nil];
    
    NSAssert(flag, @"get hue property failed!");
    
    return hue_;
}
- (CGFloat)saturation {
    CGFloat saturation_ = -1;
    BOOL flag = [[self convertRGBColorToHSBColor] getHue:nil saturation:&saturation_ brightness:nil alpha:nil];
    
    NSAssert(flag, @"get saturation property failed!");
    
    return saturation_;
}
- (CGFloat)brightness {
    CGFloat brightness_ = -1;
    BOOL flag = [[self convertRGBColorToHSBColor] getHue:nil saturation:nil brightness:&brightness_ alpha:nil];
    
    NSAssert(flag, @"get brightness property failed!");
    
    return brightness_;
}
- (CGFloat)red {
    CGFloat red_ = -1;
    BOOL flag = [[self convertHSBColorToRGBColor] getRed:&red_ green:nil blue:nil alpha:nil];
    
    NSAssert(flag, @"get red property failed!");
    
    return red_;
}
- (CGFloat)green {
    CGFloat value = -1;
    BOOL flag = [[self convertHSBColorToRGBColor] getRed:nil green:&value blue:nil alpha:nil];
    
    NSAssert(flag, @"get green property failed!");
    
    return value;
}
- (CGFloat)blue {
    CGFloat value = -1;
    BOOL flag = [[self convertHSBColorToRGBColor] getRed:nil green:nil blue:&value alpha:nil];
    
    NSAssert(flag, @"get blue property failed!");
    
    return value;
}
- (CGFloat)alpha {
    return self.CIColor.alpha;
}
@end
