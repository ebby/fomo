//
//  LoadingViewController.m
//  nearsight
//
//  Created by Ebby Amir on 4/14/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "LoadingViewController.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController {
    UILabel *_logo;
    UIActivityIndicatorView *_spinner;
}


+ (instancetype)sharedLoader {
    static LoadingViewController *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [[LoadingViewController alloc] init];
    });
    
    return _shared;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.live = YES;
    }
    return self;
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

    // Logo
    _logo = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2.0 - 60, self.view.frame.size.width, 40)];
    _logo.textColor = [UIColor whiteColor];
    _logo.text = @"nearsight";
    _logo.textAlignment = NSTextAlignmentCenter;
    [_logo setFont:[UIFont fontWithName:@"MrsEaves-Italic" size:32]];
    [self.view addSubview:_logo];
    
    // Spinner
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_spinner setCenter:CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0)];
    [self.view addSubview:_spinner];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)show {
    [super show];
    
    [_spinner startAnimating];
}

- (void)hide {
    [super hide];
    
    [_spinner stopAnimating];
}

@end
