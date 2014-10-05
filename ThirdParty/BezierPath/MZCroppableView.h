//
//  MZCroppableView.h
//  MZCroppableView
//
//  Created by macbook on 30/10/2013.
//  Copyright (c) 2013 macbook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZCroppableView : UIView
{
    
}
@property(nonatomic, strong) UIBezierPath *croppingPath;
@property(nonatomic, strong) UIColor *lineColor;
@property(nonatomic, assign) float lineWidth;

- (id)initWithImageView:(UIImageView *)imageView;

- (void)clear;

+ (CGPoint)convertPoint:(CGPoint)point1 fromRect1:(CGSize)rect1 toRect2:(CGSize)rect2;
+ (CGRect)scaleRespectAspectFromRect1:(CGRect)rect1 toRect2:(CGRect)rect2;

- (UIImage *)deleteBackgroundOfImage:(UIImageView *)image;

- (void)viewDrawed:(void(^)(void))block;

@end

/*
 Sample:
 - (void)viewDidLoad
 {
     [super viewDidLoad];
 // Do any additional setup after loading the view, typically from a nib.
 
     [croppingImageView setImage:[UIImage imageNamed:@"cropping_sample.jpg"]];
     CGRect rect1 = CGRectMake(0, 0, croppingImageView.image.size.width, croppingImageView.image.size.height);
     CGRect rect2 = croppingImageView.frame;
     [croppingImageView setFrame:[MZCroppableView scaleRespectAspectFromRect1:rect1 toRect2:rect2]];
     
     [self setUpMZCroppableView];
 }
 #pragma mark - My Methods -
 - (void)setUpMZCroppableView
 {
     [mzCroppableView removeFromSuperview];
     mzCroppableView = [[MZCroppableView alloc] initWithImageView:croppingImageView];
     [self.view addSubview:mzCroppableView];
 }
 #pragma mark - My IBActions -
 - (IBAction)resetButtonTapped:(UIBarButtonItem *)sender
 {
     [self setUpMZCroppableView];
 }
 - (IBAction)cropButtonTapped:(UIBarButtonItem *)sender
 {
     UIImage *croppedImage = [mzCroppableView deleteBackgroundOfImage:croppingImageView];
     
     NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/final.png"];
     [UIImagePNGRepresentation(croppedImage) writeToFile:path atomically:YES];
     
     NSLog(@"cropped image path: %@",path);
 }
 */