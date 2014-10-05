//
//  ACEViewController.m
//  ACEDrawingViewDemo
//
//  Created by Stefano Acerbetti on 1/6/13.
//  Copyright (c) 2013 Stefano Acerbetti. All rights reserved.
//

#import "ACEViewController.h"
#import "ACEDrawingView.h"

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

#import "ScreenCaptureView.h"
#import "NSString+Date.h"
#import "LURecordControlView.h"
#import "LUFTPSession.h"
#import "LUPen.h"
#import "SFDataCache.h"

#define kActionSheetColor       100
#define kActionSheetTool        101

#define MAXWIDTH                44

#define kUDPen  @"kUDPen"

@interface ACEViewController ()
<
UIActionSheetDelegate,
ACEDrawingViewDelegate,
UIAlertViewDelegate,
ScreenCaptureViewDelegate
>

@property (nonatomic, strong) ACEDrawingView *drawingView;
@property (nonatomic, strong) UISlider *lineWidthSlider, *lineAlphaSlider;
@property (nonatomic, strong) UIImageView *previewImageView;

@property (nonatomic, strong) UIView *colorStateusView;
@property (nonatomic, strong) UIView *penStatView;
@property (nonatomic, strong) UIBarButtonItem *undoButton, *redoButton;
@property (nonatomic, strong) UIBarButtonItem *colorButton, *toolButton, *alphaButton;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) ScreenCaptureView *recordView;

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@property (nonatomic, strong) LUPen *pen;

@end

@implementation ACEViewController
{
    NSTimer* timerRecord;
    UIActivityIndicatorView *activityIndicator;
    UILabel *labelTimeElapsed;
    LURecordControlView *actionView;
    
    NSURL *videoOutputPath;
    NSString *videoPath, *audioPath;
    
    BOOL isCurrentRecComplete;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _pen = [[SFDataCache sharedInstance] dataInUserdefaults:kUDPen];
        if (!_pen) {
            _pen = [LUPen new];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.recordView = [[ScreenCaptureView alloc] initWithFrame:CGRectMake(0, 0, VIEWWIDTH, VIEWHEIGHT)];
    self.recordView.delegate = self;
    self.recordView.frameRate = 60;
    [self.view addSubview:self.recordView];

    _drawingView = [[ACEDrawingView alloc] initWithFrame:CGRectMake(0, 0, VIEWWIDTH, VIEWHEIGHT)];
    _drawingView.backgroundColor = [UIColor whiteColor];
    self.drawingView.delegate = self;
    [self.recordView addSubview:self.drawingView];
    self.pen = _pen;// update last pen for draw view
    
#pragma mark - Draw Actions
    UIControl *undoBtn = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    UIImageView *undoImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 40, 34)];
    undoImage.image = [UIImage imageNamed:@"draw_undo"];
    [undoBtn addSubview:undoImage];
    [undoBtn addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
    _undoButton = [[UIBarButtonItem alloc] initWithCustomView:undoBtn];
    UIControl *redoBtn = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    UIImageView *redoImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 40, 34)];
    redoImage.image = [UIImage imageNamed:@"draw_redo"];
    [redoBtn addSubview:redoImage];
    [redoBtn addTarget:self action:@selector(redo:) forControlEvents:UIControlEventTouchUpInside];
    _redoButton = [[UIBarButtonItem alloc] initWithCustomView:redoBtn];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(clear:)];

#pragma mark - color picker action
    UIControl *colorCtrl = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    UIView *colorView = [[UIView alloc] initWithFrame:colorCtrl.bounds];
    _colorStateusView = [[UIView alloc] initWithFrame:CGRectMake(0, 12, 60, 20)];
    [colorCtrl addTarget:self action:@selector(colorChange:) forControlEvents:UIControlEventTouchUpInside];
    [colorView addSubview:_colorStateusView];
    [colorView addSubview:colorCtrl];
    _colorStateusView.backgroundColor = [UIColor blackColor];
    _colorStateusView.layer.borderWidth = 1;
    _colorStateusView.layer.cornerRadius = 5;
    _colorButton = [[UIBarButtonItem alloc] initWithCustomView:colorView];
    
    _toolButton  = [[UIBarButtonItem alloc] initWithTitle:@"绘图工具" style:UIBarButtonItemStyleDone target:self action:@selector(toolChange:)];
#pragma mark - pen alpha action
    UIView *alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    UIButton *alphaBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    alphaBtn.backgroundColor = [UIColor clearColor];
    alphaBtn.frame = alphaView.bounds;
    [alphaBtn addTarget:self action:@selector(toggleAlphaSlider:) forControlEvents:UIControlEventTouchUpInside];
    [alphaBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [alphaBtn setTitle:@"画笔透明度" forState:UIControlStateNormal];
    [alphaView addSubview:alphaBtn];
    _alphaButton = [[UIBarButtonItem alloc] initWithCustomView:alphaView];
    
    _lineAlphaSlider = [[UISlider alloc] initWithFrame:CGRectMake(18, 50, VIEWWIDTH-38, 29)];
    _lineAlphaSlider.value = 1;
    [_lineAlphaSlider addTarget:self action:@selector(alphaChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_lineAlphaSlider];
    _lineAlphaSlider.hidden = YES;
    
#pragma mark - pen size action
    UIView *widthView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    UIButton *widthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [widthBtn setTitle:@"画笔粗细" forState:UIControlStateNormal];
    [widthBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    widthBtn.frame = widthView.bounds;
    [widthBtn addTarget:self action:@selector(toggleWidthSlider:) forControlEvents:UIControlEventTouchUpInside];
    [widthBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    UILabel *widthValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(120-60, 0, 60, 44)];
    widthValueLabel.textAlignment = NSTextAlignmentRight;
    widthValueLabel.backgroundColor = [UIColor clearColor];
    [widthView addSubview:widthValueLabel];
    [widthView addSubview:widthBtn];
    UIBarButtonItem *widthButton = [[UIBarButtonItem alloc] initWithCustomView:widthView];
    
    _lineWidthSlider = [[UISlider alloc] initWithFrame:_lineAlphaSlider.frame];
    [_lineWidthSlider addTarget:self action:@selector(widthChange:) forControlEvents:UIControlEventValueChanged];
    _lineWidthSlider.value = self.drawingView.lineWidth/100;
    [self.view addSubview:self.lineWidthSlider];
    _lineWidthSlider.hidden = YES;
    
    UIBarButtonItem *flexibleButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    UIBarButtonItem *blankItem = [[UIBarButtonItem alloc] initWithCustomView:blankView];
    UIToolbar *topToolsBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, VIEWWIDTH, 44)];
    topToolsBar.items = @[self.undoButton, self.redoButton, clearButton, flexibleButton, self.colorButton, self.toolButton, flexibleButton, widthButton, self.alphaButton, blankItem];
    [self.view addSubview:topToolsBar];
    
#pragma mark - pen statues view
    _penStatView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *penBgView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(topToolsBar.frame)-80, 0, 80, 44)];
    _penStatView.center = penBgView.center;
    penBgView.backgroundColor = [UIColor clearColor];
    [penBgView addSubview:_penStatView];
    [topToolsBar addSubview:penBgView];

    [self updatePenStatView];
    
    // temp non-used
    _previewImageView = [UIImageView new];
    self.previewImageView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.previewImageView.layer.borderWidth = 2.0f;
    
#pragma mark - record action view
    actionView = [[LURecordControlView alloc] initWithFrame:CGRectMake(0, VIEWHEIGHT-60, 98, 44)];
    [actionView actionWith:^{
        [self actionVideoClicked];
    }];
    [actionView startWith:^{
        [self actionStartRecord];
    }];
    [actionView stopWith:^{
        [self actionStopRecord];
    }];
    [actionView playWith:^{
        [self actionPlayVideo];
    }];
    [actionView uploadWith:^{
        [[LUFTPSession sharedInstance] ftp:videoOutputPath.absoluteString progress:^(float progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress:progress animated:YES];
                [labelTimeElapsed setText:[NSString stringWithFormat:@"%.d%%", (NSInteger)(progress*100)]];
            });
        }];
    }];
    [self.view addSubview:actionView];
    
#pragma mark - record statues view
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(20, VIEWHEIGHT-12, 20, 20)];
    [self.view addSubview:activityIndicator];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicator stopAnimating];
    
    labelTimeElapsed = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEWHEIGHT-20, 50, 20)];
    labelTimeElapsed.backgroundColor = [UIColor clearColor];
    [self.view addSubview:labelTimeElapsed];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, VIEWHEIGHT-3, VIEWWIDTH, 5)];
    [self.view addSubview:self.progressView];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                      object:self
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self actionPauseRecord];
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:self
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self actionResumeRecord];
                                                  }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self updateButtonStatus];
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackDidFinishNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [UIView animateWithDuration:.5 animations:^{
            [self.moviePlayer.view removeFromSuperview];
        }];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)addBorder:(UIView *)view {
    view.layer.borderColor = [UIColor darkGrayColor].CGColor;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 5;
}

- (void)setPen:(LUPen *)pen {
    _pen = pen;
    _drawingView.lineAlpha = pen.alpha;
    _drawingView.lineColor = pen.color;
    _drawingView.lineWidth = pen.width;
}
- (void)updatePenStatView {
    _penStatView.frame = CGRectMake(0, 0, 60, self.pen.width);
    _penStatView.backgroundColor = self.pen.color;
    _penStatView.alpha = self.pen.alpha;
    _penStatView.center = CGPointMake(40, 22);
    
    [[SFDataCache sharedInstance] writeData:self.pen toUserDefaultsWithKey:kUDPen];
}

#pragma mark -
#pragma mark - Draw Actions
- (void)updateButtonStatus
{
    self.undoButton.enabled = [self.drawingView canUndo];
    self.redoButton.enabled = [self.drawingView canRedo];
}

- (void)takeScreenshot:(id)sender
{
    // show the preview image
    self.previewImageView.image = self.drawingView.image;
    self.previewImageView.hidden = NO;
    
    // close it after 3 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.previewImageView.hidden = YES;
    });
}

- (void)undo:(id)sender
{
    [self.drawingView undoLatestStep];
    [self updateButtonStatus];
}

- (void)redo:(id)sender
{
    [self.drawingView redoLatestStep];
    [self updateButtonStatus];
}

- (void)clear:(id)sender
{
    [self.drawingView clear];
    [self updateButtonStatus];
}

#pragma mark -
#pragma mark - Settings
- (void)colorChange:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"Selet a color", @"titles of tools bar")
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"Black", nil),
                                  NSLocalizedString(@"Red", nil),
                                  NSLocalizedString(@"Green", nil),
                                  NSLocalizedString(@"Blue", nil), nil
                                  ];
    
    [actionSheet setTag:kActionSheetColor];
    [actionSheet showInView:self.view];
}

- (void)toolChange:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"Selet a tool", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"Pen", nil),
                                  NSLocalizedString(@"Line", nil),
                                  NSLocalizedString(@"Rect (Stroke)", nil),
                                  NSLocalizedString(@"Rect (Fill)", nil),
                                  NSLocalizedString(@"Ellipse (Stroke)", nil),
                                  NSLocalizedString(@"Ellipse (Fill)", nil),
                                  NSLocalizedString(@"Eraser", nil), nil
                                  ];
    
    [actionSheet setTag:kActionSheetTool];
    [actionSheet showInView:self.view];
}

- (void)toggleWidthSlider:(id)sender
{
    // toggle the slider
    self.lineWidthSlider.hidden = !self.lineWidthSlider.hidden;
    self.lineAlphaSlider.hidden = YES;
}


- (void)widthChange:(UISlider *)sender
{
    float width = sender.value * MAXWIDTH;
    self.drawingView.lineWidth = width;
    self.pen.width = width;
    [self updatePenStatView];
}

- (void)toggleAlphaSlider:(id)sender
{
    // toggle the slider
    self.lineAlphaSlider.hidden = !self.lineAlphaSlider.hidden;
    self.lineWidthSlider.hidden = YES;
}

- (void)alphaChange:(UISlider *)sender
{
    self.drawingView.lineAlpha = sender.value;
    self.pen.alpha = sender.value;
    [self updatePenStatView];
}

-(void)updateTimeElapsed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval timeInterval = self.recordView.timeIntervalElapsed;
        NSString *str = nil;
        if (timeInterval < 60) {
            str = [NSString stringWithFormat:@"%d", (NSInteger)timeInterval];
        } else if (timeInterval < 3600) {
            str = [NSString stringWithFormat:@"%d:%d", (NSInteger)timeInterval/60, (NSInteger)timeInterval%60];
        } else {
            str = [NSString stringWithFormat:@"%d:%d:%d", (NSInteger)timeInterval/3600, (NSInteger)timeInterval%3600/60, (NSInteger)timeInterval%3600%60];
        }
        [labelTimeElapsed setText:str];
    });
}

#pragma mark -
#pragma mark - Record Actions
- (void)actionStartRecord {
    self.recordView.userInteractionEnabled = YES;
    
    [self.recordView startRecording];
    
    actionView.type = LUStatueRecording;
    [self.progressView setProgress:0 animated:NO];
    timerRecord = [NSTimer scheduledTimerWithTimeInterval:.5
                                                   target:self
                                                 selector:@selector(updateTimeElapsed)
                                                 userInfo:nil
                                                  repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timerRecord forMode:NSRunLoopCommonModes];
}
- (void)actionStopRecord {
    [self.recordView stopRecording];
    
    actionView.type = LUStatueStopped;
    self.recordView.userInteractionEnabled = NO;
    [timerRecord invalidate];
    [activityIndicator startAnimating];
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:@"视频录制完成，正在处理..."
                              delegate:self
                              cancelButtonTitle:@"知道了"
                              otherButtonTitles:nil, nil];
    alertView.tag = 111;
    [alertView show];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [alertView dismissWithClickedButtonIndex:-1 animated:YES];
    });
}
- (void)actionPauseRecord {
    self.recordView.userInteractionEnabled = YES;
    [self.recordView pause];
    [timerRecord setFireDate:[NSDate distantFuture]];
    [activityIndicator startAnimating];
}
- (void)actionResumeRecord {
    self.recordView.userInteractionEnabled = YES;
    [self.recordView resume];
    [timerRecord setFireDate:[NSDate date]];
    [activityIndicator startAnimating];
}
- (void)actionVideoClicked {
    
    //Resume recording video.
    if (!self.recordView.recording) {
        [self actionResumeRecord];
    }
    //Pause recording video.
    else
    {
        [self actionPauseRecord];
    }
    
}

- (void)actionPlayVideo {
    isCurrentRecComplete = YES;
    if (!_moviePlayer) {
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoOutputPath];
        _moviePlayer.allowsAirPlay = YES;
        [_moviePlayer.view setFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    }
    _moviePlayer.contentURL = videoOutputPath;
    [self.view addSubview:self.moviePlayer.view];
    [_moviePlayer play];
}

#pragma mark -
#pragma mark - ACEDrawing View Delegate
- (void)drawingView:(ACEDrawingView *)view didEndDrawUsingTool:(id<ACEDrawingTool>)tool;
{
    [self updateButtonStatus];
}
#pragma mark -
#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        if (actionSheet.tag == kActionSheetColor) {
            
            self.colorButton.title = [actionSheet buttonTitleAtIndex:buttonIndex];
            switch (buttonIndex) {
                case 0:
                    self.drawingView.lineColor = [UIColor blackColor];
                    break;
                    
                case 1:
                    self.drawingView.lineColor = [UIColor redColor];
                    break;
                    
                case 2:
                    self.drawingView.lineColor = [UIColor greenColor];
                    break;
                    
                case 3:
                    self.drawingView.lineColor = [UIColor blueColor];
                    break;
            }
            _colorStateusView.backgroundColor = self.drawingView.lineColor;
            self.pen.color = self.drawingView.lineColor;
            [self updatePenStatView];
        } else {
            
            self.toolButton.title = [actionSheet buttonTitleAtIndex:buttonIndex];
            switch (buttonIndex) {
                case 0:
                    self.drawingView.drawTool = ACEDrawingToolTypePen;
                    break;
                    
                case 1:
                    self.drawingView.drawTool = ACEDrawingToolTypeLine;
                    break;
                    
                case 2:
                    self.drawingView.drawTool = ACEDrawingToolTypeRectagleStroke;
                    break;
                    
                case 3:
                    self.drawingView.drawTool = ACEDrawingToolTypeRectagleFill;
                    break;
                    
                case 4:
                    self.drawingView.drawTool = ACEDrawingToolTypeEllipseStroke;
                    break;
                    
                case 5:
                    self.drawingView.drawTool = ACEDrawingToolTypeEllipseFill;
                    break;
                    
                case 6:
                    self.drawingView.drawTool = ACEDrawingToolTypeEraser;
                    break;
            }
            
            // if eraser, disable color and alpha selection
            self.colorButton.enabled = self.alphaButton.enabled = buttonIndex != 6;
        }
    }
}


#pragma mark -
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self actionPlayVideo];
    }
}

#pragma mark -
#pragma mark - ScreenCaptureViewDelegate
- (void)recordingFinished:(NSURL *)outputPathOrNil {
    [activityIndicator stopAnimating];
    videoOutputPath = outputPathOrNil;
}

- (void)processFinish:(NSURL *)outputPathOrNil {
    videoOutputPath = outputPathOrNil;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"视频制作完成"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"播放", nil];
    [alert show];
    
}
- (void)processFailed:(NSError *)error {
    // may be private access deny
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"请检查设置"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"知道了", nil];
    [alert show];
}

//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextAddEllipseInRect(ctx, rect);
//    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor blueColor] CGColor]));
//    CGContextFillPath(ctx);
//}
@end
