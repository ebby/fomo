//
//  StreamViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/20/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "StreamViewController.h"
#import "StreamTableViewController.h"

@interface StreamViewController ()

@property (strong, nonatomic) StreamTableViewController *streamTableViewController;

@end

@implementation StreamViewController {
    UISegmentedControl *_streamSegment;
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
	
    self.streamTableViewController = [[StreamTableViewController alloc] init];
    self.streamTableViewController.view.frame = self.view.frame;
    [self.view addSubview:self.streamTableViewController.view];
    [self addChildViewController:self.streamTableViewController];
    [self.streamTableViewController loadStream];
    
    _streamSegment = [[UISegmentedControl alloc] initWithItems:@[@"Following", @"Nearby"]];
    _streamSegment.frame = CGRectMake(self.view.frame.size.width/2 - 80, 25, 160, 30.0f);
    _streamSegment.selectedSegmentIndex = 0;
    _streamSegment.tintColor = [UIColor whiteColor];
    _streamSegment.alpha = 0.8;
    [self.view addSubview:_streamSegment];

    UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20.0f)];
    statusBar.backgroundColor = [UIColor blackColor];
    statusBar.alpha = 0.3;
    [self.view addSubview:statusBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadStream
{
    [self.streamTableViewController loadStream];
}

- (void)_handleNotificationButton:(UIButton *)button
{
    //    CATransition *transition = [CATransition animation];
    //    transition.duration = 0.35;
    //    transition.timingFunction =
    //    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //    transition.type = kCATransitionMoveIn;
    //    transition.subtype = kCATransitionFromBottom;
    //
    //    UIView *containerView = self.view.window;
    //    [containerView.layer addAnimation:transition forKey:nil];
    //    [self presentViewController:self.notificationViewController animated:NO completion:nil];
    
//    [self.pageViewController setViewControllers:@[self.notificationViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    
}

@end
