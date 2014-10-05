//
//  SFSegmentView.h
//  SFBestIphone
//
//  Created by SFBest on 14-2-12.
//  Copyright (c) 2014年 sfbest. All rights reserved.
//

#define SegText     @"text"
#define SegIcon     @"icon"
#define SegFont     @"font"
#define SegColor    @"color"
#import <UIKit/UIKit.h>

typedef void(^SelectionBlock)(NSUInteger segmentIndex, UIImageView *iconView);
@interface SFSegmentView : UIView

@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic) NSUInteger count;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSDictionary *textAttributes;//SegFont,SegColor
@property (nonatomic, strong) NSDictionary *selectedTextAttributes;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth, cornerRadius;
@property (nonatomic) CGPoint textOffset;// default is (0,0), title label in the center of SegmentCell
@property (nonatomic) CGPoint iconOffset;// default is (0,0), icon view in the center of SegmentCell
@property (nonatomic, strong) UIImage *unSelectedIcon;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, copy) SelectionBlock selectionBlock;

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items selectionBlock:(SelectionBlock)block;
- (void)setTitle:(NSString *)title forIndex:(NSInteger)index;
- (void)setEnabled:(BOOL)flag forIndex:(NSInteger)index;
- (void)unSelectedIcon:(UIImage *)icon index:(NSInteger)index;

- (void)setIndex:(NSUInteger)idx invalid:(BOOL)flag;

@end
