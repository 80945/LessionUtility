//
//  SFTipView.m
//  SFBestIphone
//
//  Created by SFBest on 14-3-4.
//  Copyright (c) 2014年 sfbest. All rights reserved.
//

#define SHOWRECT        CGRectMake(0, 0, SCREENHEIGHT, SCREENWIDTH)
#define MINHEIGHT       40

#import "SFTipView.h"
//#import <CoreText/CoreText.h>

@interface SFTipView()

@property (nonatomic, strong)   UIView *bgView;
@property (nonatomic, strong)   UILabel *messageLabel;
@property (nonatomic, strong)   UIActivityIndicatorView *indicator;

@end

@implementation SFTipView
{

}

- (id)init
{
    if (self = [super init]) {
        [self initOperations];
    }
    return self;
}

- (void)initOperations
{
    _bgView = [[UIView alloc] initWithFrame:SHOWRECT];
    _bgView.hidden = YES;
    _font = [UIFont systemFontOfSize:15];
    _color = [UIColor whiteColor];
    // Initialization code
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageLabel = messageLabel;
    messageLabel.backgroundColor = HEXACOLOR(0x000000, .8);
    messageLabel.font = _font;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.textColor = _color;
    [_bgView addSubview:messageLabel];
    _isHidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:_bgView];
}
+ (id)sharedInstance
{
    static SFTipView *tipView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tipView = [[SFTipView alloc] init];
    });
    return tipView;
}
- (void)setFont:(UIFont *)font
{
    _font = font;
    self.messageLabel.font = _font;
}
- (void)setColor:(UIColor *)color
{
    _color = color;
    self.messageLabel.textColor = _color;
}
- (void)showMessage:(NSString *)msg
{
    [self showMessage:msg animation:NO];
}
- (void)showMessage:(NSString *)msg animation:(BOOL)animation
{
    self.isHidden = NO;
    if (![[UIApplication sharedApplication].keyWindow.subviews containsObject:_bgView]) {
        [[UIApplication sharedApplication].keyWindow addSubview:_bgView];
    }
    self.messageLabel.text = msg;
    CGSize size = [msg sizeWithFont:_font];
    size.height = MAX(size.height, MINHEIGHT);
    size.width += 40;
    CGRect rect = self.messageLabel.frame;
    rect.size = size;
    self.messageLabel.frame = rect;
    self.messageLabel.center = [UIApplication sharedApplication].keyWindow.center;
    
    self.bgView.hidden = NO;
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:.3 animations:^{
            self.bgView.hidden = YES;
        }];
    });
}
- (void)hidden
{
    [self hiddenWithAnimation:YES];
}
- (void)hiddenWithAnimation:(BOOL)animation
{
    float duration = .5;
    if (!animation) {
        duration = 0;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:duration animations:^{
            self.bgView.frame = SHOWRECT;
        } completion:^(BOOL finished) {
            if (finished) {
                self.isHidden = YES;
            }
        }];
    });
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
//+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
//    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
//}
//+ (int)getHeightWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color width:(int)width
//{
//    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:string];
//    [titleStr addAttribute:(NSString *)kCTForegroundColorAttributeName
//                     value:(id)color.CGColor
//                     range:NSMakeRange(0, string.length)];
//    [titleStr addAttribute:(NSString *)kCTFontAttributeName
//                     value:(id)CFBridgingRelease(CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL))
//                     range:NSMakeRange(0, string.length)];
//    
//    int total_height = 0;
//    
//    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);    //string 为要计算高度的NSAttributedString
//    CGRect drawingRect = CGRectMake(0, 0, width, 1000);  //这里的高要设置足够大
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRect(path, NULL, drawingRect);
//    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
//    CGPathRelease(path);
//    CFRelease(framesetter);
//    
//    NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
//    
//    CGPoint origins[[linesArray count]];
//    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
//    
//    int line_y = (int) origins[[linesArray count] -1].y;  //最后一行line的原点y坐标
//    
//    CGFloat ascent;
//    CGFloat descent;
//    CGFloat leading;
//    
//    CTLineRef line = (__bridge CTLineRef) [linesArray objectAtIndex:[linesArray count]-1];
//    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
//    
//    total_height = 1000 - line_y + (int) descent +1;    //+1为了纠正descent转换成int小数点后舍去的值
//    
//    CFRelease(textFrame);
//    
//    return MAX(total_height, MINHEIGHT);
//    
//}
@end
