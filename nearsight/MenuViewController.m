//
//  MenuViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/26/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "MenuViewController.h"
#import "UIExtensions.h"

@interface MenuViewController ()

@end

@implementation MenuViewController {
    ExtendedHitButton *_closeButton;
    UILabel *_logo;
    UIButton *_homeButton;
    UIButton *_discoverButton;
    UIButton *_profileButton;
    UIButton *_bookmarksButton;
    UIButton *_notificationsButton;
    UIButton *_friendsButton;
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
    _logo = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    _logo.textColor = [UIColor whiteColor];
    _logo.text = @"nearsight";
    _logo.textAlignment = NSTextAlignmentCenter;
    [_logo setFont:[UIFont fontWithName:@"MrsEaves-Italic" size:32]];
    [self.view addSubview:_logo];
    
    // Home button
    _homeButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 100.0f, 200, 40.0f)];
    [_homeButton setTitle:@"Home" forState:UIControlStateNormal];
    _homeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_homeButton.titleLabel setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:32]];
    [self.view addSubview:_homeButton];
    
    // Discover button
    _homeButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 160.0f, 200, 40.0f)];
    [_homeButton setTitle:@"Teleport" forState:UIControlStateNormal];
    _homeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_homeButton.titleLabel setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:32]];
    [self.view addSubview:_homeButton];
    
    // Profile button
    _profileButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 220.0f, 200, 40.0f)];
    [_profileButton setTitle:@"My Profile" forState:UIControlStateNormal];
    _profileButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_profileButton.titleLabel setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:32]];
    [self.view addSubview:_profileButton];
    
    // Bookmarks button
    _bookmarksButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 280.0f, 200, 40.0f)];
    [_bookmarksButton setTitle:@"Bookmarks" forState:UIControlStateNormal];
    _bookmarksButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_bookmarksButton.titleLabel setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:32]];
    [self.view addSubview:_bookmarksButton];
    
    // Notifications button
    _notificationsButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 340.0f, 200, 40.0f)];
    [_notificationsButton setTitle:@"Notifications" forState:UIControlStateNormal];
    _notificationsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_notificationsButton.titleLabel setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:32]];
    [self.view addSubview:_notificationsButton];
    
    // Friends button
    _friendsButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 400.0f, 200, 40.0f)];
    [_friendsButton setTitle:@"Friends" forState:UIControlStateNormal];
    _friendsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_friendsButton.titleLabel setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:32]];
    [self.view addSubview:_friendsButton];
    
    // close button
    _closeButton = [ExtendedHitButton extendedHitButton];
    _closeButton.frame = CGRectMake(self.view.frame.size.width - 48, 20.0f, 40.0f, 40.0f);
    _closeButton.alpha = 0.8;
    UIImage *closeButtonImage = [UIImage imageNamed:@"close"];
    [_closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(_handleCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_handleCloseButton:(UIButton *)button
{
    [self hide];
}

@end
