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
#import "Manager.h"
#import "UIExtensions.h"


@interface MainViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (strong, nonatomic) NSArray *pageViewControllers;

@property (strong, nonatomic) PBJViewController *captureViewController;
@property (strong, nonatomic) StreamViewController *streamViewController;
@property (strong, nonatomic) ProfileViewController *profileViewController;
@property (strong, nonatomic) NotificationViewController *notificationViewController;
@property (strong, nonatomic) WelcomeViewController *welcomeViewController;
@property (strong, nonatomic) MenuViewController *menuViewController;
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
    
    // Setup profile view controller
    self.profileViewController = [[ProfileViewController alloc] init];
    [self addChildViewController:self.profileViewController];
    [self.view addSubview:self.profileViewController.view];
    
    // Notification View Controller
    self.notificationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    [self addChildViewController:self.notificationViewController];
    [self.view addSubview:self.notificationViewController.view];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    self.pageIndex = 1;
    self.pageViewControllers = @[self.notificationViewController, self.streamViewController, self.profileViewController];
    
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
    _addButton.frame = CGRectMake(viewWidth/2 - 32.0f, viewHeight - 75.0f, 75.0f, 75.0f);
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
    [self.streamViewController.view addSubview:_menuButton];
    
    // Search button
    _searchButton = [ExtendedHitButton extendedHitButton];
    _searchButton.frame = CGRectMake(15, 28, 25, 25);
    _searchButton.alpha = 0.8;
    UIImage *searchImage = [UIImage imageNamed:@"search"];
    [_searchButton setImage:searchImage forState:UIControlStateNormal];
    [_searchButton addTarget:self action:@selector(_handleSearchButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.streamViewController.view addSubview:_searchButton];
    
    // Notification-Home button
    _notificationHomeButton = [ExtendedHitButton extendedHitButton];
    _notificationHomeButton.frame = CGRectMake(viewWidth - 30.0f, 28.0f, 19.0f, 27.0f);
    _notificationHomeButton.alpha = 0.8;
    UIImage *logoImage = [UIImage imageNamed:@"logo"];
    [_notificationHomeButton setImage:logoImage forState:UIControlStateNormal];
    [_notificationHomeButton addTarget:self action:@selector(_handleNotificationHomeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.notificationViewController.view addSubview:_notificationHomeButton];
    
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

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pageViewControllers indexOfObject:viewController];
    if (index == 0) {
        return nil;
    }
    
    return [self viewControllerAtIndex:--index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pageViewControllers indexOfObject:viewController];
    if (index == [self.pageViewControllers count] - 1) {
        return nil;
    }
    return [self viewControllerAtIndex:++index];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (index == 2) {
        // if it's the profile
        [self.profileViewController loadProfile];
    }
    return self.pageViewControllers[index];
}

@end
