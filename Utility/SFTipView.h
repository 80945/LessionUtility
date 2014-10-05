//
//  SFTipView.h
//  SFBestIphone
//
//  Created by SFBest on 14-3-4.
//  Copyright (c) 2014年 sfbest. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SFTipView : NSObject

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) BOOL isHidden;

+ (id)sharedInstance;

- (void)showMessage:(NSString *)msg;
- (void)showMessage:(NSString *)msg animation:(BOOL)animation;

- (void)hidden;
- (void)hiddenWithAnimation:(BOOL)animation;

@end
