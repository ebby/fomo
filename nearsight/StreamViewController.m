//
//  StreamViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/20/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "StreamViewController.h"
#import "StreamTableViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface StreamViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) StreamTableViewController *streamTableViewController;

@end

@implementation StreamViewController {
    UIScrollView *_scrollView;
    GMSMapView *_mapView;
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
    
    self.view.backgroundColor = [UIColor blackColor];
    
//    // Map
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
//                                                            longitude:151.2086
//                                                                 zoom:15];
//    _mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) camera:camera];
//    _mapView.settings.scrollGestures = NO;
//    _mapView.settings.zoomGestures = NO;
//    _mapView.settings.tiltGestures = NO;
//    _mapView.settings.rotateGestures = NO;
//    
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = camera.target;
//    marker.snippet = @"Hello World";
//    [self.view addSubview:_mapView];
    
//    // Scroll View
//    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    _scrollView.bounces = YES;
//    _scrollView.alwaysBounceVertical = YES;
//    _scrollView.delegate = self;
//    _scrollView.showsVerticalScrollIndicator = NO;
//    _scrollView.showsHorizontalScrollIndicator = NO;
//    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+200);
//    [_scrollView setBackgroundColor:[UIColor clearColor]];
//    [self.view addSubview:_scrollView];
	
    self.streamTableViewController = [[StreamTableViewController alloc] init];
    self.streamTableViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.streamTableViewController.view];
    [self addChildViewController:self.streamTableViewController];
    //[self.streamTableViewController loadStream];

//    UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20.0f)];
//    statusBar.backgroundColor = [UIColor blackColor];
//    statusBar.alpha = 0.3;
//    [self.view addSubview:statusBar];
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

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _scrollView){
        
        _mapView.frame = CGRectMake(_mapView.frame.origin.x, -150 - scrollView.contentOffset.y*.75, _mapView.frame.size.width, MAX(self.view.frame.size.height - scrollView.contentOffset.y, self.view.frame.size.height));
    }
    self.streamTableViewController.view.userInteractionEnabled = scrollView.contentOffset.y >= 200;
}

@end
