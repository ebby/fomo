//
//  SignupViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/21/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "SignupViewController.h"

@interface SignupViewController ()

@end

@implementation SignupViewController {
    UIButton *_signupButton;
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
	
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    navBar.barStyle = UIBarStyleBlack;
    [self.view addSubview:navBar];
    
    _signupButton = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth/2 - 100, viewHeight - 100, 200, 60)];
    _signupButton.backgroundColor = [UIColor whiteColor];
    _signupButton.titleLabel.textColor = [UIColor blackColor];
    _signupButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_signupButton setTitle:@"Join" forState:UIControlStateNormal];
    [_signupButton addTarget:self action:@selector(_handleSignupButton:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
