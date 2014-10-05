//
//  PointsView.h
//  TestCroping
//
//  Created by Javier Berlana on 20/12/12.
//  Copyright (c) 2012 Mobile one2one. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JBCroppableView : UIView

@property (nonatomic, strong) UIColor *pointColor;
@property (nonatomic, strong) UIColor *lineColor;

- (id)initWithImageView:(UIImageView *)imageView;

- (NSArray *)getPoints;
- (UIImage *)deleteBackgroundOfImage:(UIImageView *)image;

- (void)addPointsAt:(NSArray *)points;
- (void)addPoints:(int)num;

+ (CGPoint)convertPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2;
+ (CGRect)scaleRespectAspectFromRect1:(CGRect)rect1 toRect2:(CGRect)rect2;

@end

/*
 锚点切图
 Sample
 
 self.image.frame = [JBCroppableView scaleRespectAspectFromRect1:CGRectMake(0, 0, self.image.image.size.width, self.image.image.size.height) toRect2:self.image.frame];
 self.pointsView = [[JBCroppableView alloc] initWithImageView:self.image];
 
 //    [self.pointsView addPointsAt:@[[NSValue valueWithCGPoint:CGPointMake(10, 10)],
 //                                    [NSValue valueWithCGPoint:CGPointMake(50, 10)],
 //                                    [NSValue valueWithCGPoint:CGPointMake(50, 50)],
 //                                    [NSValue valueWithCGPoint:CGPointMake(10, 50)]]];
 
 [self.pointsView addPoints:9];
 
 self.image.image = [self.pointsView deleteBackgroundOfImage:self.image];

 */
