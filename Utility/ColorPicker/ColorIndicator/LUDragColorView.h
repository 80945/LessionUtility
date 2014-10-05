//
//  LUDragColorView.h
//  LessionUtility
//
//  Created by 256 on 6/2/14.
//  Copyright (c) 2014 256. All rights reserved.
//

/*
 1. 封装Color的drag动作
 2. 提供drag的view
 */
#import <UIKit/UIKit.h>

@class LUColorChipView;

@protocol LUColorDragging <NSObject>
@optional
- (void)dragMoved:(UITouch *)touch colorChip:(LUColorChipView *)chip colorSource:(id)source;
- (void)dragExited;
- (BOOL)dragEnded:(UITouch *)touch colorChip:(LUColorChipView *)chip colorSource:(id)source destination:(CGPoint *)flyLoc;
@end


@interface LUDragColorView : UIView
{
    CGPoint     initialTap_;
}

@property (nonatomic, strong) LUColorChipView *dragChip;
@property (nonatomic, strong) id lastTarget;
@property (nonatomic, readonly) BOOL moved;

- (void) dragEnded;
- (UIColor *) color;

@end
