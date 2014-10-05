//
//  LUDragChip.m
//  LessionUtility
//
//  Created by 256 on 6/2/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import "LUColorChipView.h"
#import "LUColorUtilies.h"

@implementation LUColorChipView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
    }
    
    self.opaque = NO;
    self.backgroundColor = nil;
    
    // shadow
    self.layer.shadowOffset = CGSizeMake(0,2);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.25;
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect bounds = CGRectInset(self.bounds, 1, 1);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:5];
    
    if (self.color.CIColor.alpha < 1.0) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        [path addClip];
        LUDrawTransparencyDiamondInRect(ctx, self.bounds);
        CGContextRestoreGState(ctx);
    }
    
    [self.color set];
    [path fill];
    
    [[UIColor whiteColor] set];
    path.lineWidth = 2;
    [path stroke];
}

@end
