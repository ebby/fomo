//
//  ProfileViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/19/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "ProfileViewController.h"
#import "StreamTableViewController.h"

@interface ProfileViewController ()

@property (strong, nonatomic) StreamTableViewController *streamTableViewController;

@end

@implementation ProfileViewController {
    BOOL _loaded;
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
	// Do any additional setup after loading the view.
    
    self.streamTableViewController = [[StreamTableViewController alloc] initForProfile];
    self.streamTableViewController.view.frame = self.view.frame;
    [self.view addSubview:self.streamTableViewController.view];
    [self addChildViewController:self.streamTableViewController];
    
    UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20.0f)];
    statusBar.backgroundColor = [UIColor blackColor];
    statusBar.alpha = 0.3;
    [self.view addSubview:statusBar];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40.0f)];
    title.text = @"My Moments";
    title.textColor = [UIColor whiteColor];
    title.alpha = 0.8;
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadProfile
{
    if (!_loaded) {
        [self.streamTableViewController loadStream];
        _loaded = YES;
    }
}

@end
