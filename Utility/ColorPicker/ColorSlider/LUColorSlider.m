//
//  LUColorSlider.m
//  LessionUtility
//
//  Created by 256 on 6/3/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import "LUColorSlider.h"
#import "LUColorUtilies.h"
#import "LUColorIndicator.h"
#import "UIView+Center.h"

#define kCornerRadius   10
#define kIndicatorInset 10

@interface  LUColorSlider (Private)
- (CGImageRef) p_hueImage;
- (void) p_buildHueImage;
- (void) positionIndicator_;
@end

static void evaluateShading(void *info, const CGFloat *in, CGFloat *out)
{
    LUColorSlider   *slider = (__bridge LUColorSlider *) info;
    UIColor         *color = slider.color;
    CGFloat         blend = in[0];
    CGFloat         hue, saturation, brightness;
    CGFloat         r1 = 0, g1 = 0, b1 = 0;
    CGFloat         r2 = 0, g2 = 0, b2 = 0;
    CGFloat         r = 0, g = 0, b = 0;
    BOOL            blendRGB = YES;
    
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
    
    if (slider.mode == LUColorSliderModeAlpha) {
        HSVtoRGB(color.hue, color.saturation, color.brightness, &r, &g, &b);
        blendRGB = NO;
    } else if (slider.mode == LUColorSliderModeBrightness) {
        HSVtoRGB(hue, saturation, 0.0, &r1, &g1, &b1);
        HSVtoRGB(hue, saturation, 1.0, &r2, &g2, &b2);
    } else if (slider.mode == LUColorSliderModeSaturation) {
        HSVtoRGB(hue, 0.0, brightness, &r1, &g1, &b1);
        HSVtoRGB(hue, 1.0, brightness, &r2, &g2, &b2);
    } else if (slider.mode == LUColorSliderModeRed) {
        r1 = 0; r2 = 1;
        g1 = g2 = color.green;
        b1 = b2 = color.blue;
    } else if (slider.mode == LUColorSliderModeGreen) {
        r1 = r2 = color.red;
        g1 = 0; g2 = 1;
        b1 = b2 = color.blue;
    } else if (slider.mode == LUColorSliderModeBlue) {
        r1 = r2 = color.red;
        g1 = g2 = color.green;
        b1 = 0; b2 = 1;
    } else if (slider.mode == LUColorSliderModeRedBalance) {
        r1 = 0; r2 = 1;
        g1 = 1; g2 = 0;
        b1 = 1; b2 = 0;
    } else if (slider.mode == LUColorSliderModeGreenBalance) {
        r1 = 1; r2 = 0;
        g1 = 0; g2 = 1;
        b1 = 1; b2 = 0;
    } else if (slider.mode == LUColorSliderModeBlueBalance) {
        r1 = 1; r2 = 0;
        g1 = 1; g2 = 0;
        b1 = 0; b2 = 1;
    }
    
    if (blendRGB) {
        r = (blend * r2) + (1.0f - blend) * r1;
        g = (blend * g2) + (1.0f - blend) * g1;
        b = (blend * b2) + (1.0f - blend) * b1;
    }
    
    out[0] = r;
    out[1] = g;
    out[2] = b;
    out[3] = (slider.mode == LUColorSliderModeAlpha ? in[0] : 1.0f);
}

static void release(void *info) {
}

@implementation LUColorSlider

@synthesize mode = mode_;
@synthesize floatValue = value_;
@synthesize color = color_;
@synthesize reversed = reversed_;
@synthesize indicator = indicator_;

- (void) awakeFromNib
{
    indicator_ = [LUColorIndicator colorIndicator];
    indicator_.sharpCenter = LUCenterOfRect([self bounds]);
    [self addSubview:indicator_];
    
    self.opaque = NO;
    self.backgroundColor = nil;
    self.clearsContextBeforeDrawing = YES;
    self.contentMode = UIViewContentModeRedraw;
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect bounds = CGRectInset(self.bounds, -10, -10);
    return CGRectContainsPoint(bounds, point);
}

- (void) dealloc
{
    if (hueImage_) {
        CGImageRelease(hueImage_);
    }
    
    if (shadingRef_) {
        CGShadingRelease(shadingRef_);
    }
}

- (CGShadingRef) newShadingRef
{
    CGShadingRef        gradient;
    CGFloat             domain[] = {0.0f, 1.0f};
    CGFloat             range[] = {0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f};
    CGFunctionCallbacks callbacks;
    
    callbacks.version = 0;
    callbacks.evaluate = evaluateShading;
    callbacks.releaseInfo = release;
    
    CGPoint start = CGPointMake(0.0, 10.0f);
    CGPoint end = CGPointMake(CGRectGetWidth(self.bounds), 10.0f);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFunctionRef gradientFunction = CGFunctionCreate((__bridge void *)(self), 1, domain, 4, range, &callbacks);
    
    if (self.reversed) {
        gradient = CGShadingCreateAxial(colorspace, end, start, gradientFunction, NO, NO);
    } else {
        gradient = CGShadingCreateAxial(colorspace, start, end, gradientFunction, NO, NO);
    }
    
    CGFunctionRelease(gradientFunction);
    CGColorSpaceRelease(colorspace);
    
    return gradient;
}

- (void) setFrame:(CGRect)frame
{
    BOOL sizeChanged = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    [super setFrame:frame];
    
    if (sizeChanged) {
        CGShadingRelease(shadingRef_);
        shadingRef_ = NULL;
    }
    
    [self positionIndicator_];
}

- (CGShadingRef) shadingRef
{
    if (!shadingRef_) {
        shadingRef_ = [self newShadingRef];
    }
    
    return shadingRef_;
}

- (BOOL) colorChanged:(UIColor *)color
{
    if (!color) {
        return YES;
    }
    
    BOOL hueChanged = color.hue != color_.hue;
    BOOL satChanged = color.saturation != color_.saturation;
    BOOL brightnessChanged = color.brightness != color_.brightness;
    
    switch (mode_) {
        case LUColorSliderModeBrightness:
            return (hueChanged || satChanged);
            break;
        case LUColorSliderModeSaturation:
            return (hueChanged || brightnessChanged);
            break;
        default:
            return (hueChanged || brightnessChanged || satChanged);
            break;
    }
    
    return NO;
}

- (void) setColor:(UIColor *)color
{
    switch (mode_) {
        case LUColorSliderModeAlpha:
            value_ = [color alpha];
            break;
        case LUColorSliderModeHue:
            value_ = [color hue];
            break;
        case LUColorSliderModeBrightness:
            value_ = [color brightness];
            break;
        case LUColorSliderModeSaturation:
            value_ = [color saturation];
            break;
        case LUColorSliderModeRed:
        case LUColorSliderModeRedBalance:
            value_ = [color red];
            break;
        case LUColorSliderModeGreen:
        case LUColorSliderModeGreenBalance:
            value_ = [color green];
            break;
        case LUColorSliderModeBlue:
        case LUColorSliderModeBlueBalance:
            value_ = [color blue];
            break;
        default: break;
    }
    
    if ([self colorChanged:color]) {
        if (mode_ != LUColorSliderModeHue && shadingRef_) {
            CGShadingRelease(shadingRef_);
            shadingRef_ = NULL;
        }
        
        [self setNeedsDisplay];
    }
    
    color_ = color;
    
    [self positionIndicator_];
    
    if (self.reversed) {
        [indicator_ setColor:[color colorWithAlphaComponent:(1.0f - color.alpha)]];
    } else {
        if (mode_ == LUColorSliderModeHue) {
            color = [UIColor colorWithHue:color.hue saturation:1 brightness:1 alpha:1];
        }
        
        [indicator_ setColor:color];
    }
}

- (void) setMode:(LUColorSliderMode)mode
{
    mode_ = mode;
    indicator_.alphaMode = (mode == LUColorSliderModeAlpha);
    
    if (mode_ != LUColorSliderModeHue && shadingRef_) {
        CGShadingRelease(shadingRef_);
        shadingRef_ = NULL;
    }
    
    [self setNeedsDisplay];
}

- (void) setReversed:(BOOL)reversed
{
    reversed_ = reversed;
    [self setNeedsDisplay];
}

- (UIImage *) borderImage
{
    static UIImage *borderImage = nil;
    
    if (borderImage && !CGSizeEqualToSize(borderImage.size, self.bounds.size)) {
        borderImage = nil;
    }
    
    if (!borderImage) {
        borderImage = [UIImage imageNamed:@"slider_border.png"];
        borderImage = [borderImage stretchableImageWithLeftCapWidth:16 topCapHeight:0];
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
        [borderImage drawInRect:[self bounds]];
        borderImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return borderImage;
}

- (void) drawRect:(CGRect)clip
{
    CGContextRef    ctx = UIGraphicsGetCurrentContext();
    CGRect          bounds = [self bounds];
    
    CGContextSaveGState(ctx);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:8];
    [path addClip];
    
    if (mode_ == LUColorSliderModeAlpha) {
        LUDrawCheckersInRect(ctx, bounds, 8);
    }
    
    if (mode_ == LUColorSliderModeHue) {
        CGContextDrawImage(ctx, self.bounds, [self p_hueImage]);
    } else {
        CGContextDrawShading(ctx, [self shadingRef]);
    }
    
    CGContextRestoreGState(ctx);
    
    [[self borderImage] drawInRect:bounds blendMode:kCGBlendModeMultiply alpha:0.5f];
}

- (float) indicatorCenterX_
{
    CGRect  trackRect = CGRectInset(self.bounds, kIndicatorInset, 0);
    
    return roundf(value_ * CGRectGetWidth(trackRect) + CGRectGetMinX(trackRect));
}

- (void) computeValue_:(CGPoint)pt
{
    CGRect  trackRect = CGRectInset(self.bounds, kIndicatorInset, 0);
    float   percentage;
    
    percentage = (pt.x - CGRectGetMinX(trackRect)) / CGRectGetWidth(trackRect);
    percentage = LUClamp(0.0f, 1.0f, percentage);
    
    value_ = percentage;
}

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pt = [touch locationInView:self];
    
    [self computeValue_:pt];
    [self positionIndicator_];
    
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pt = [touch locationInView:self];
    
    [self computeValue_:pt];
    [self positionIndicator_];
    
    return [super continueTrackingWithTouch:touch withEvent:event];
}

@end

@implementation LUColorSlider (Private)

- (CGImageRef) p_hueImage
{
    if (!hueImage_) {
        [self p_buildHueImage];
    }
    
    return hueImage_;
}

- (void) p_buildHueImage
{
    int             x, y;
    float           r,g,b;
    int             width = CGRectGetWidth(self.bounds);
    int             height = CGRectGetHeight(self.bounds);
    int             bpr = width * 4;
    UInt8           *data, *ptr;
    
    ptr = data = calloc(1, sizeof(unsigned char) * height * bpr);
    
    for (x = 0; x < width; x++) {
        float angle = ((float) x) / width;
        HSVtoRGB(angle, 1.0f, 1.0f, &r, &g, &b);
        
        for (y = 0; y < height; y++) {
            ptr[y * bpr + x*4] = 255;
            ptr[y * bpr + x*4+1] = r * 255;
            ptr[y * bpr + x*4+2] = g * 255;
            ptr[y * bpr + x*4+3] = b * 255;
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSInteger kBitmapInfo = kCGImageAlphaPremultipliedFirst;
    CGContextRef ctx = CGBitmapContextCreate(data, width, height, 8, bpr, colorSpace, kBitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    hueImage_ = CGBitmapContextCreateImage(ctx);
    
    // clean up
    free(data);
    CGContextRelease(ctx);
}

- (void) positionIndicator_
{
    indicator_.sharpCenter = CGPointMake([self indicatorCenterX_], indicator_.center.y);
}

@end
