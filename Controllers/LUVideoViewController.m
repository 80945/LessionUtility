//
//  LUVideoViewController.m
//  LessionUtility
//
//  Created by 256 on 3/29/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import "LUVideoViewController.h"
#import <MediaPlayer/MPMoviePlayerController.h>

@interface LUVideoViewController ()

@end

@implementation LUVideoViewController

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
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    MPMoviePlayerController *vc = [[MPMoviePlayerController alloc] initWithContentURL:(NSURL *)self.videoPath];

    [self.view addSubview:vc.view];
    [vc play];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
