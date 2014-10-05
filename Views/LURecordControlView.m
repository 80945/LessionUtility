//
//  LUStatuesView.m
//  LessionUtility
//
//  Created by 256 on 3/29/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import "LURecordControlView.h"
#import "SFTipView.h"
#import "SFSegmentView.h"

@interface UIButton (Color)

@end

@implementation UIButton (Color)

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    UIImage *image = enabled ? [UIImage imageNamed:@"record_bar_unsel"] : nil;
    [self setBackgroundImage:image forState:UIControlStateNormal];
    UIColor *textColor = enabled ? [UIColor yellowColor] : [UIColor lightGrayColor];
    [self setTitleColor:textColor forState:UIControlStateNormal];
}
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

@end

#define StatuesHeight   44

@implementation LURecordControlView
{
    void(^UploadBlock)(void);
    void(^ActionBLock)(void);
    void(^StopBlock)(void);
    void(^StartBlock)(void);
    void(^PlayBlock)(void);
    
    UIButton *btnRecord, *btnUpload, *btnPlay, *btnStop, *btnStart;
    UIButton *btnToggle;
    BOOL isStopped, isRecording, isToggled, isToggleCompleted;
    
    SFSegmentView *segment;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupView];
        
        isStopped = isToggleCompleted = YES;
        isRecording = isToggled = NO;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setupView {
    
    btnStart = [self setupButton];
    [btnStart setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    [btnStart addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];

    btnRecord = [self setupButton];
    [btnRecord setTitle:NSLocalizedString(@"Pause", nil) forState:UIControlStateNormal];
    [btnRecord addTarget:self action:@selector(recordSwitch) forControlEvents:UIControlEventTouchUpInside];

    btnStop = [self setupButton];
    [btnStop setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateNormal];
    [btnStop addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    
    btnPlay = [self setupButton];
    [btnPlay setTitle:NSLocalizedString(@"Play", nil) forState:UIControlStateNormal];
    [btnPlay addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    
    btnUpload = [self setupButton];
    [btnUpload setTitle:NSLocalizedString(@"Upload", nil) forState:UIControlStateNormal];
    [btnUpload addTarget:self action:@selector(upload) forControlEvents:UIControlEventTouchUpInside];
    
    self.type = LUStatueStopped;
    
    btnToggle = [self setupButton];
    btnToggle.backgroundColor = [UIColor greenColor];
    [btnToggle addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupWithButtons:@[btnUpload, btnStart, btnRecord, btnStop, btnPlay, btnToggle]];
    self.image = [UIImage imageNamed:@"record_bar_bg"];
}
#define kIdxUpload  0
#define kIdxStart   1
#define kIdxRecord  2
#define kIdxStop    3
#define kIdxPlay    4
- (void)segmentView {
    segment = [[SFSegmentView alloc]
               initWithFrame:CGRectMake(0, 0, 44*5, 44)
               items:@[
                       @{SegText: NSLocalizedString(@"Upload", nil)},
                       @{SegText: NSLocalizedString(@"Start", nil)},
                       @{SegText: NSLocalizedString(@"Pause", nil)},
                       @{SegText: NSLocalizedString(@"Stop", nil)},
                       @{SegText: NSLocalizedString(@"Play", nil)}
                       ]
               selectionBlock:^(NSUInteger segmentIndex, UIImageView *iconView)
               {
                   switch (segmentIndex)
                   {
                       case kIdxUpload:
                       {
                           [self upload];
                           break;
                       }
                       case kIdxStart:
                       {
                           [self start];
                           break;
                       }
                       case kIdxRecord:
                       {
                           [self recordSwitch];
                           break;
                       }
                       case kIdxStop:
                       {
                           [self stop];
                           break;
                       }
                       case kIdxPlay:
                       {
                           [self play];
                           break;
                       }
                           
                       default:
                           break;
                   }
               }];
    segment.color = [UIColor whiteColor];
    segment.borderWidth = 0.5;
    segment.cornerRadius = 0;
    segment.borderColor = COLOR_HIGHLIGHT;
    segment.selectedColor = COLOR_HIGHLIGHT;
    segment.textAttributes = @{SegFont:[UIFont systemFontOfSize:14], SegColor:COLOR_HIGHLIGHT};
    segment.selectedTextAttributes = @{SegFont:[UIFont systemFontOfSize:14], SegColor:[UIColor whiteColor]};
    segment.currentIndex = -1;
    [self addSubview:segment];

}

- (UIButton *)setupButton {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, StatuesHeight, StatuesHeight)];
    [btn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [btn setBackgroundImage:[UIImage imageNamed:@"record_bar_unsel"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"record_bar_sel"] forState:UIControlStateSelected];
    return btn;
}

- (void)setupWithButtons:(NSArray *)array {
    
//    if (!array || array.count == 0) {
//        return;
//    }
//    
//    for (UIView *view in self.subviews) {
//        [view removeFromSuperview];
//    }
//
//    __block CGFloat offsetX = 0;
//    CGFloat margin = 10;
//    CGFloat width = StatuesHeight+margin;
//    
//    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        UIButton *btn = obj;
//        if (idx > 0) {
//            offsetX += width;
//        }
//        btn.frame = CGRectOffset(btn.frame, offsetX, 0);
//        [self addSubview:btn];
//    }];
//    self.frame = CGRectMake(0, SCREENHEIGHT-60, offsetX+StatuesHeight, StatuesHeight);
    
    [self segmentView];
    [self addSubview:btnToggle];
    btnToggle.frame = CGRectOffset(btnToggle.frame, 44*5, 0);
    self.frame = CGRectMake(0, SCREENHEIGHT-60, StatuesHeight*6, StatuesHeight);
}

- (void)setType:(LUStatue)type {
    _type = type;
    switch (type) {
        case LUStatueRecording:
        {
//            btnStart.enabled = NO;
//            btnRecord.enabled = YES;
//            btnStop.enabled = YES;
//            btnPlay.enabled = NO;
//            [btnRecord setTitle:NSLocalizedString(@"Pause", nil) forState:UIControlStateNormal];
            
            [segment setIndex:kIdxStart invalid:YES];
            [segment setIndex:kIdxRecord invalid:NO];
            [segment setIndex:kIdxStop invalid:NO];
            [segment setIndex:kIdxPlay invalid:YES];
            [segment setTitle:NSLocalizedString(@"Pause", nil) forIndex:kIdxRecord];
            break;
        }
        case LUStatueStopped:
        {
            [segment setIndex:kIdxStart invalid:YES];
            [segment setIndex:kIdxRecord invalid:NO];
            [segment setIndex:kIdxStop invalid:NO];
            [segment setIndex:kIdxPlay invalid:YES];
            [segment setTitle:NSLocalizedString(@"Pause", nil) forIndex:kIdxRecord];
            break;
        }
        case LUStatuePaused:
        {
            [segment setIndex:kIdxStart invalid:NO];
            [segment setIndex:kIdxRecord invalid:YES];
            [segment setIndex:kIdxStop invalid:YES];
            [segment setIndex:kIdxPlay invalid:NO];
            [segment setTitle:NSLocalizedString(@"Resume", nil) forIndex:kIdxRecord];
            break;
        }
        default:
            break;
    }
}
- (void)uploadWith:(void(^)(void))block
{
    UploadBlock = block;
}
- (void)actionWith:(void(^)(void))block {
    ActionBLock = block;
}
- (void)stopWith:(void(^)(void))block {
    StopBlock = block;
}
- (void)startWith:(void (^)(void))block {
    StartBlock = block;
}
- (void)playWith:(void(^)(void))block {
    PlayBlock = block;
}
#pragma mark -
#pragma mark - Action
- (void)recordSwitch {
    btnRecord.selected = YES;
    if (isRecording) {
        self.type = LUStatuePaused;
    } else {
        self.type = LUStatueRecording;
    }
    isRecording = !isRecording;
    if (ActionBLock) {
        ActionBLock();
    }
}
- (void)upload {
    isRecording = NO;
    if (UploadBlock) {
        UploadBlock();
    }
}
- (void)play {
    isRecording = NO;
    if (PlayBlock) {
        PlayBlock();
    }
}
- (void)stop {
    self.type = LUStatueStopped;
    isRecording = NO;
    if (StopBlock) {
        StopBlock();
    }
}
- (void)start {
    self.type = LUStatueRecording;
    isRecording = YES;
    if (StartBlock) {
        StartBlock();
    }
}

- (void)toggle {
    if (!isToggleCompleted) {
        return;
    }
    isToggleCompleted = NO;
    CGFloat offsetX = 0;
    if (isToggled) {
        offsetX = 0;
    } else {
        offsetX = -CGRectGetWidth(self.frame) + CGRectGetWidth(btnToggle.frame);
    }
    [UIView animateWithDuration:.3 animations:^{
        self.frame = CGRectMake(offsetX, SCREENHEIGHT-60, CGRectGetWidth(self.frame), StatuesHeight);
    } completion:^(BOOL finished) {
        if (finished) {
            isToggleCompleted = YES;
            isToggled = !isToggled;
        }
    }];
}

@end
