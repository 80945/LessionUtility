//
//  LUInsetView.m
//  LessionUtility
//
//  Created by 256 on 6/3/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import "LUInsetView.h"

@implementation LUInsetView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    self.opaque = NO;
    self.backgroundColor = nil;
    self.userInteractionEnabled = NO;
    
    //    self.clipsToBounds = YES;
    //
    //    CALayer *layer = self.layer;
    //    layer.borderColor = [UIColor whiteColor].CGColor;
    //    layer.borderWidth = 1;
    //    layer.shadowRadius = 6;
    //    layer.shadowOffset = CGSizeMake(0,4);
    //    layer.shadowOpacity = 0.5f;
    //
    //    CGPoint rectCenter = WDCenterOfRect(self.bounds);
    //    CGAffineTransform tX = CGAffineTransformMakeTranslation(rectCenter.x, rectCenter.y);
    //    tX = CGAffineTransformScale(tX, 1, -1);
    //    const CGAffineTransform flip = CGAffineTransformTranslate(tX, -rectCenter.x, -rectCenter.y);
    //
    //    CGMutablePathRef pathRef = CGPathCreateMutable();
    //    CGPathAddRect(pathRef, NULL, self.bounds);
    //    CGPathAddRect(pathRef, &flip, CGRectInset(self.bounds, -10, -10));
    //    layer.shadowPath = pathRef;
    //    CGPathRelease(pathRef);
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, self.bounds);
    
    CGContextSetShadow(ctx, CGSizeMake(0,4), 8);
    CGContextAddRect(ctx, CGRectInset(self.bounds, -20, -20));
    CGContextAddRect(ctx, CGRectInset(self.bounds, -1, -1));
    CGContextEOFillPath(ctx);
    CGContextRestoreGState(ctx);
    
    [[UIColor whiteColor] set];
    UIRectFrame(self.bounds);
}@end
