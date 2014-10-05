//
//  LUScreenViewController.m
//  LessionUtility
//
//  Created by SFBest on 14-3-31.
//  Copyright (c) 2014年 256. All rights reserved.
//

#import "LUScreenViewController.h"
#import "ScreenCaptureView.h"
#import "LUVideoViewController.h"
#import "NSString+Date.h"
#import "LURecordControlView.h"
#import "LUFTPSession.h"
//#import "MZCroppableView.h"
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <MediaPlayer/MPMoviePlayerController.h>

@interface LUScreenViewController ()
<
UIAlertViewDelegate,
ScreenCaptureViewDelegate
>
@property (nonatomic, strong)   UIProgressView *progressView;
@property (nonatomic, strong)   ScreenCaptureView *drawView;

@end

@implementation LUScreenViewController
{
    NSDate* recordStartTime;
    NSTimer* timerRecord;
    UIActivityIndicatorView *activityIndicator;
    UILabel *labelTimeElapsed;
    LURecordControlView *actionView;
    
    NSURL *videoOutputPath;
    NSString *videoPath, *audioPath;
    
    BOOL isRecording;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    CGFloat offset = - ABS(SCREENHEIGHT-SCREENWIDTH) * .5;
//    CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), offset, offset);
	// Do any additional setup after loading the view.
    self.drawView = [[ScreenCaptureView alloc] initWithFrame:CGRectMake(0, 0, VIEWHEIGHT, VIEWWIDTH)];
//    self.drawView.transform = transform;
    self.drawView.delegate = self;
    [self.view addSubview:self.drawView];
    self.view.backgroundColor = [UIColor blackColor];
    
//    MZCroppableView *view = [[MZCroppableView alloc] initWithFrame:CGRectMake(0, 0, VIEWHEIGHT, VIEWWIDTH)];
//    view.backgroundColor = [UIColor whiteColor];
//    view.transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), -offset, -offset);
//    [self.drawView addSubview:view];
//    [view viewDrawed:^{
//        [self.drawView setNeedsDisplay];
//    }];
//    [UIView commitAnimations];
    
    actionView = [[LURecordControlView alloc] initWithFrame:CGRectMake(VIEWHEIGHT-98-20, VIEWWIDTH-60, 98, 44)];
    [actionView actionWith:^{
        [self startRecordingClicked];
    }];
    [actionView uploadWith:^{
        [[LUFTPSession sharedInstance] ftp:videoOutputPath.absoluteString progress:^(float progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressView setProgress:progress animated:YES];
                [labelTimeElapsed setText:[NSString stringWithFormat:@"%.d%%", (NSInteger)(progress*100)]];
            });
        }];
    }];
    [actionView stopWith:^{
        
    }];
    [self.view addSubview:actionView];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(20, VIEWWIDTH-12, 20, 20)];
    [self.view addSubview:activityIndicator];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicator stopAnimating];
    
    labelTimeElapsed = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 50, 20)];
    labelTimeElapsed.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:labelTimeElapsed];
    
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, VIEWWIDTH-3, VIEWHEIGHT, 3)];
    [self.view addSubview:self.progressView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    labelTimeElapsed.text = nil;
    self.progressView.progress = 0;
    actionView.type = LUStatueStopped;
    isRecording = NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)updateTimeElapsed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:recordStartTime];
        [labelTimeElapsed setText:[NSString stringWithFormat:@"%d s", (int)timeInterval]];
    });
}


- (void)startRecordingClicked {//:(UIButton *)sender
    
    //Start recording video.
    if (!isRecording) {
        self.drawView.userInteractionEnabled = YES;

//        [self.drawView startRecording];
        [self.drawView performSelector:@selector(startRecording) withObject:nil afterDelay:0];

        actionView.type = LUStatueRecording;
        isRecording = YES;
        [self.progressView setProgress:0 animated:NO];
        recordStartTime = [NSDate date];
        timerRecord = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeElapsed) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timerRecord forMode:NSRunLoopCommonModes];
    }
    //End recording video.
    else
    {
//        [self.drawView stopRecording];
        [self.drawView performSelector:@selector(stopRecording) withObject:nil afterDelay:0];

        actionView.type = LUStatueStopped;
        self.drawView.userInteractionEnabled = NO;
        [timerRecord invalidate];
        [activityIndicator startAnimating];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"视频录制完成，正在处理..." delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        alertView.tag = 111;
        [alertView show];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [alertView dismissWithClickedButtonIndex:-1 animated:YES];
        });
        
    }
    
}
#pragma mark -
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        LUVideoViewController *videoPlayViewController = [[LUVideoViewController alloc] init];
        videoPlayViewController.videoPath = videoOutputPath.absoluteString;
        [self.navigationController pushViewController:videoPlayViewController animated:YES];
    }
}

#pragma mark -
#pragma mark - ScreenCaptureViewDelegate
- (void)recordingFinished:(NSURL *)outputPathOrNil {
    [activityIndicator stopAnimating];
    videoOutputPath = outputPathOrNil;

//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                    message:@"视频制作完成"
//                                                   delegate:self
//                                          cancelButtonTitle:@"取消"
//                                          otherButtonTitles:@"播放", nil];
//    [alert show];
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
@end
