//
//  LUColorSlider.h
//  LessionUtility
//
//  Created by 256 on 6/3/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LUColorIndicator;

typedef enum {
    LUColorSliderModeHue,
    LUColorSliderModeSaturation,
    LUColorSliderModeBrightness,
    LUColorSliderModeRed,
    LUColorSliderModeGreen,
    LUColorSliderModeBlue,
    LUColorSliderModeAlpha,
    LUColorSliderModeRedBalance,
    LUColorSliderModeGreenBalance,
    LUColorSliderModeBlueBalance
} LUColorSliderMode;

@interface LUColorSlider : UIControl
{
    CGImageRef          hueImage_;
    UIColor             *color_;
    float               value_;
    CGShadingRef        shadingRef_;
    LUColorSliderMode   mode_;
    BOOL                reversed_;
}

@property (nonatomic, assign) LUColorSliderMode mode;
@property (nonatomic, readonly) float floatValue;
@property (nonatomic) UIColor *color;
@property (nonatomic, assign) BOOL reversed;
@property (nonatomic, readonly) LUColorIndicator *indicator;
@end
