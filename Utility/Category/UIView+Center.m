//
//  UIView+Center.m
//  LessionUtility
//
//  Created by 256 on 6/2/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import "UIView+Center.h"
#import "LUColorUtilies.h"

@implementation UIView (Center)

- (void) setSharpCenter:(CGPoint)center
{
    CGRect frame = self.frame;
    
    frame.origin = LUSubtractPoints(center, CGPointMake(CGRectGetWidth(frame) / 2, CGRectGetHeight(frame) / 2));
    frame.origin = LURoundPoint(frame.origin);
    
    self.center = LUCenterOfRect(frame);
}

- (CGPoint) sharpCenter
{
    return self.center;
}

@end
