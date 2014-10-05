//
//  LUColorComparator.m
//  LessionUtility
//
//  Created by 256 on 6/2/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import "LUColorComparator.h"
#import "LUColorUtilies.h"

@implementation LUColorComparator
{
    CGRect  leftCircle_;
    CGRect  rightCircle_;
}
@synthesize target, action, tappedColor;
@synthesize initialColor = initialColor_;
@synthesize currentColor = currentColor_;

- (void) computeCircleRects
{
    CGRect  bounds = CGRectInset([self bounds], 1, 1);
    
    leftCircle_ = bounds;
    leftCircle_.size.width /= 2;
    leftCircle_.size.height /= 2;
    
    float inset = floorf(bounds.size.width * 0.125f);
    rightCircle_ = CGRectInset(bounds, inset, inset);
    rightCircle_ = CGRectOffset(rightCircle_, inset, inset);
}

- (void) buildInsetShadowView
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0f);
    
    CGContextRef    ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    // paint the left shadowed circle
    [self insetCircleInRect:leftCircle_ context:ctx];
    
    // knock out a hole for the right shadowed circle
    [[UIColor whiteColor] set];
    CGContextSetBlendMode(ctx, kCGBlendModeClear);
    CGContextFillEllipseInRect(ctx, CGRectInset(rightCircle_,-3,-3));
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    
    // paint the right shadowed circle
    [self insetCircleInRect:CGRectInset(rightCircle_,1,1) context:ctx];
    
    CGContextRestoreGState(ctx);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:result];
    [self addSubview:imageView];
}

- (void) awakeFromNib
{
    initialColor_ = [UIColor whiteColor];
    currentColor_ = [UIColor whiteColor];
    
    [self computeCircleRects];
    [self buildInsetShadowView];
    
    self.backgroundColor = nil;
    self.opaque = NO;
}


- (void) insetCircleInRect:(CGRect)rect context:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    CGContextAddEllipseInRect(ctx, rect);
    CGContextClip(ctx);
    
    CGContextSetShadow(ctx, CGSizeMake(0,4), 8);
    CGContextAddRect(ctx, CGRectInset(rect, -20, -20));
    CGContextAddEllipseInRect(ctx, CGRectInset(rect, -1, -1));
    CGContextEOFillPath(ctx);
    CGContextRestoreGState(ctx);
}

- (void) paintTransparentColor:(UIColor *)color inRect:(CGRect)rect
{
    CGContextRef    ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    [path addClip];
    
    //UIDrawTransparencyDiamondInRect(ctx, rect);
    LUDrawCheckersInRect(ctx, rect, 8);
    [color set];
    CGContextFillRect(ctx, rect);
    CGContextRestoreGState(ctx);
}

- (void) drawRect:(CGRect)clip
{
    CGContextRef    ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    if (initialColor_.CIColor.alpha < 1.0) {
        [self paintTransparentColor:initialColor_ inRect:leftCircle_];
    } else {
        [[initialColor_ opaqueColor] set];
        CGContextFillEllipseInRect(ctx, leftCircle_);
    }
    
    if (currentColor_.CIColor.alpha < 1.0) {
        [self paintTransparentColor:currentColor_ inRect:rightCircle_];
    } else {
        [[currentColor_ opaqueColor] set];
        CGContextFillEllipseInRect(ctx, rightCircle_);
    }
    
    [[UIColor whiteColor] set];
    CGContextSetLineWidth(ctx, 4);
    CGContextSetBlendMode(ctx, kCGBlendModeClear);
    CGContextStrokeEllipseInRect(ctx, CGRectInset(rightCircle_,-1,-1));
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    
    CGContextRestoreGState(ctx);
}

- (UIColor *) color
{
    return self.tappedColor;
}

- (void) takeColorFrom:(id)sender
{
    [self setCurrentColor:(UIColor *)[sender color]];
}

- (void) setCurrentColor:(UIColor *)color
{
    currentColor_ = color;
    
    [self setNeedsDisplay];
}

- (void) setOldColor:(UIColor *)color
{
    initialColor_ = color;
    
    [self setNeedsDisplay];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    initialTap_ = [touch locationInView:self];
	
    CGRect upperLeft = [self bounds];
    upperLeft.size.width /=  2;
    upperLeft.size.height /= 2;
    
    self.tappedColor = CGRectContainsPoint(upperLeft, initialTap_) ? initialColor_ : currentColor_;
	
    [super touchesBegan:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.moved) {
        [[UIApplication sharedApplication] sendAction:self.action to:self.target from:self forEvent:nil];
        return;
    }
    
    [super touchesEnded:touches withEvent:event];
}

@end
