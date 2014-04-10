//
//  ViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/11/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "MainViewController.h"
#import "PBJViewController.h"
#import "StreamViewController.h"
#import "PBJVision.h"
#import "ProfileViewController.h"
#import "NotificationViewController.h"
#import "WelcomeViewController.h"
#import "MenuViewController.h"
#import "SearchViewController.h"
#import "MapListViewController.h"
#import "Manager.h"
#import "UIExtensions.h"
#import "Client.h"
#import <TSMessages/TSMessage.h>



@interface MainViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (strong, nonatomic) NSArray *pageViewControllers;

@property (strong, nonatomic) PBJViewController *captureViewController;
@property (strong, nonatomic) StreamViewController *streamViewController;
@property (strong, nonatomic) ProfileViewController *profileViewController;
@property (strong, nonatomic) NotificationViewController *notificationViewController;
@property (strong, nonatomic) WelcomeViewController *welcomeViewController;
@property (strong, nonatomic) MenuViewController *menuViewController;
@property (strong, nonatomic) MapListViewController *trendingViewController;
@property (strong, nonatomic) SearchViewController *searchViewController;
@property (strong, nonatomic) UINavigationController *addFlowViewController;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property NSInteger pageIndex;

@end

@implementation MainViewController {
    ExtendedHitButton *_addButton;
    ExtendedHitButton *_menuButton;
    ExtendedHitButton *_notificationHomeButton;
    ExtendedHitButton *_searchButton;
    UISegmentedControl *_streamSegment;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Init the manager
    [[Manager sharedClient] findCurrentLocation];
    
    //[self loggedOut];
    [self loggedIn];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loggedOut
{
    self.welcomeViewController = [[WelcomeViewController alloc] init];
    [self addChildViewController:self.welcomeViewController];
    [self.view addSubview:self.welcomeViewController.view];
}

- (void)loggedIn
{
    // Initiate Recorder
    [PBJVision sharedInstance];
    
    // Setup capture view controller
    self.captureViewController = [[PBJViewController alloc] init];
    self.addFlowViewController = [[UINavigationController alloc] initWithRootViewController:self.captureViewController];
    self.addFlowViewController.navigationBarHidden = YES;
    
    // Setup stream view controller
    self.streamViewController = [[StreamViewController alloc] init];
    [self.streamViewController loadStream];
    [self addChildViewController:self.streamViewController];
    [self.view addSubview:self.streamViewController.view];
    
    // Trending View controller
    self.trendingViewController = [[MapListViewController alloc] init];
    [self addChildViewController:self.trendingViewController];
    [self.view addSubview:self.trendingViewController.view];
    
    [[[[[Client sharedClient] fetchPlaces]
       doNext:^(NSMutableArray *places) {
           [self.trendingViewController loadPlaces:places];
       }]
      // Now the assignment will be done on the main thread.
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeError:^(NSError *error) {
         [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching the stream: " type:TSMessageNotificationTypeError];
     }];
    
//    // Setup profile view controller
//    self.profileViewController = [[ProfileViewController alloc] init];
//    [self addChildViewController:self.profileViewController];
//    [self.view addSubview:self.profileViewController.view];
//    
//    // Notification View Controller
//    self.notificationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
//    [self addChildViewController:self.notificationViewController];
//    [self.view addSubview:self.notificationViewController.view];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    self.pageIndex = 0;
    self.pageViewControllers = @[self.trendingViewController, self.streamViewController];
    
    UIViewController *startingViewController = [self viewControllerAtIndex:self.pageIndex];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    
    // BUTTONS
    
    // Add button
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    _addButton = [ExtendedHitButton extendedHitButton];
    _addButton.frame = CGRectMake(viewWidth/2 - 37.5f, viewHeight - 75.0f, 75.0f, 75.0f);
    _addButton.alpha = 0.8;
    UIImage *addButtonImage = [UIImage imageNamed:@"add"];
    [_addButton setImage:addButtonImage forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(_handleAddButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addButton];
    
    // Menu button
    _menuButton = [ExtendedHitButton extendedHitButton];
    _menuButton.frame = CGRectMake(viewWidth - 40.0f, 27.0f, 27.0f, 27.0f);
    _menuButton.alpha = 0.8;
    UIImage *menuImage = [UIImage imageNamed:@"menu"];
    [_menuButton setImage:menuImage forState:UIControlStateNormal];
    [_menuButton addTarget:self action:@selector(_handleMenuButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_menuButton];
    
    // Search button
    _searchButton = [ExtendedHitButton extendedHitButton];
    _searchButton.frame = CGRectMake(15, 28, 25, 25);
    _searchButton.alpha = 0.8;
    UIImage *searchImage = [UIImage imageNamed:@"search"];
    [_searchButton setImage:searchImage forState:UIControlStateNormal];
    [_searchButton addTarget:self action:@selector(_handleSearchButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchButton];
    
    _streamSegment = [[UISegmentedControl alloc] initWithItems:@[@"Trending", @"Following"]];
    _streamSegment.frame = CGRectMake(self.view.frame.size.width/2 - 80, 25, 160, 30.0f);
    _streamSegment.selectedSegmentIndex = 0;
    _streamSegment.tintColor = [UIColor whiteColor];
    _streamSegment.alpha = 0.8;
    [_streamSegment addTarget:self action:@selector(changeStream:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_streamSegment];

    // Menu view controller
    self.menuViewController = [[MenuViewController alloc] init];
    [self.view addSubview:self.menuViewController.view];
    [self addChildViewController:self.menuViewController];
    
    // Search view controller
    self.searchViewController = [[SearchViewController alloc] init];
    [self.view addSubview:self.searchViewController.view];
    [self addChildViewController:self.searchViewController];
}

- (void)_handleAddButton:(UIButton *)button
{
    [[Manager sharedClient] findCurrentLocation];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.35;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    [self presentViewController:self.addFlowViewController  animated:NO completion:nil];
}

- (void)_handleMenuButton:(UIButton *)button
{
    [self.menuViewController show];
}

- (void)_handleSearchButton:(UIButton *)button
{
    [self.searchViewController show];
}

- (void)_handleNotificationHomeButton:(UIButton *)button
{
    [self.pageViewController setViewControllers:@[self.streamViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

-(void)changeStream:(id)sender
{
    NSInteger index = [_streamSegment selectedSegmentIndex];
    UIPageViewControllerNavigationDirection direction = index == 1 ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    //[self.pageViewController setViewControllers:@[self.pageViewController[index]] direction:direction animated:YES completion:nil];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pageViewControllers indexOfObject:viewController];
    _streamSegment.selectedSegmentIndex = 0;
    if (index == 0) {
        return nil;
    }
    return [self viewControllerAtIndex:--index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pageViewControllers indexOfObject:viewController];
    _streamSegment.selectedSegmentIndex = 1;
    if (index == [self.pageViewControllers count] - 1) {
        return nil;
    }
    return [self viewControllerAtIndex:++index];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    return self.pageViewControllers[index];
}

@end
