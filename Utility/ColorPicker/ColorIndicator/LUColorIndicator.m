//
//  LUColorIndicator.m
//  LessionUtility
//
//  Created by 256 on 6/1/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import "LUColorIndicator.h"
#import "LUColorUtilies.h"

@implementation LUColorIndicator

@synthesize alphaMode = alphaMode_;
@synthesize color = color_;

+ (LUColorIndicator *) colorIndicator
{
    LUColorIndicator *indicator = [[LUColorIndicator alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    return indicator;
}

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
    
    if (!self) {
        return nil;
	}
    
    self.color = [UIColor whiteColor];
    self.opaque = NO;
    
    UIView *overlay = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:overlay];
    
    overlay.layer.borderColor = [UIColor whiteColor].CGColor;
    overlay.layer.borderWidth = 3;
    overlay.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2.0f;
    
    overlay.layer.shadowOpacity = 0.5f;
    overlay.layer.shadowRadius = 1;
    overlay.layer.shadowOffset = CGSizeMake(0, 0);
    
	return self;
}

- (void) setColor:(UIColor *)color
{
    if ([color isEqual:color_]) {
        return;
    }
    
    color_ = color;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (![self color]) {
        return;
    }
    
    CGContextRef    ctx = UIGraphicsGetCurrentContext();
    CGRect          bounds = CGRectInset([self bounds], 2, 2);
    
    if (self.alphaMode) {
        CGContextSaveGState(ctx);
        CGContextAddEllipseInRect(ctx, bounds);
        CGContextClip(ctx);
        LUDrawTransparencyDiamondInRect(ctx, bounds);
        CGContextRestoreGState(ctx);
        [[self color] set];
    } else {
        [[[self color] opaqueColor] set];
    }
    
    CGContextFillEllipseInRect(ctx, bounds);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return NO;
}


@end
