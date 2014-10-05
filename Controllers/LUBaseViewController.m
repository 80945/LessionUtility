//
//  LUBaseViewController.m
//  LessionUtility
//
//  Created by 256 on 3/29/14.
//  Copyright (c) 2014 256. All rights reserved.
//

#import "LUBaseViewController.h"

@interface LUBaseViewController ()

@end

@implementation LUBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // iOS 7 and later, UI adjust
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.navigationController.viewControllers.count > 1) {
//        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//        backBtn.backgroundColor = [UIColor orangeColor];
//        [backBtn setTitle:@"<" forState:UIControlStateNormal];
//        [backBtn addTarget:self action:@selector(leftSwiped) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:backBtn];
        UISwipeGestureRecognizer *_swipGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwiped)];
        _swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:_swipGestureRight];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - UI action
- (void)leftSwiped {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
