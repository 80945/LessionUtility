//
//  LUColorComparator.h
//  LessionUtility
//
//  Created by 256 on 6/2/14.
//  Copyright (c) 2014 256. All rights reserved.
//

/*
 颜色比较器，用于对比两个颜色
    一般用于向用户提供 已选择的颜色 和 当前正在选择的颜色的对比功能
 */
#import "LUDragColorView.h"

@interface LUColorComparator : LUDragColorView

@property (nonatomic, assign) SEL action;
@property (nonatomic, weak) id target;
@property (nonatomic) UIColor *initialColor;
@property (nonatomic) UIColor *currentColor;
@property (nonatomic, weak) UIColor *tappedColor;
@end
