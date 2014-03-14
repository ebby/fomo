//
//  ViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/11/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "ViewController.h"
#import "PBJViewController.h"
#import "StreamViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSArray *pageViewControllers;
@property (strong, nonatomic) PBJViewController *captureViewController;
@property (strong, nonatomic) StreamViewController *streamViewController;
@property NSInteger pageIndex;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Setup capture view controller
    self.captureViewController = [[PBJViewController alloc] init];
    
    // Setup stream view controller
    self.streamViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StreamViewController"];
    [self.streamViewController loadStream];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    self.pageIndex = 1;
    self.pageViewControllers = @[self.streamViewController, self.captureViewController];
    
    PBJViewController *startingViewController = [self viewControllerAtIndex:self.pageIndex];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (PBJViewController *)viewControllerAtIndex:(NSUInteger)index
{
    return self.pageViewControllers[index];
}

@end
