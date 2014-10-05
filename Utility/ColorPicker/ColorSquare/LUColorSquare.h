//
//  LUColorSquare.h
//  LessionUtility
//
//  Created by 256 on 6/3/14.
//  Copyright (c) 2014 256. All rights reserved.
//

/*
 用于拾取颜色的颜色方阵
 */
#import <UIKit/UIKit.h>

@class LUColorIndicator;
@class LUShader;
@interface LUColorSquare : UIControl
{
    // the pixel dimensions of the backbuffer
    GLint               backingWidth;
    GLint               backingHeight;
    
    GLuint              colorRenderbuffer;
    GLuint              defaultFramebuffer;
    
    LUColorIndicator    *indicator_;
}

@property (nonatomic) EAGLContext *context;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, readonly) float saturation;
@property (nonatomic, readonly) float brightness;
@property (nonatomic, assign) GLuint quadVAO;
@property (nonatomic, assign) GLuint quadVBO;
@property (nonatomic) LUShader *colorShader;
@end
