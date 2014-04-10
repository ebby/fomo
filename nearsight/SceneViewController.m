//
//  SceneViewController.m
//  nearsight
//
//  Created by Ebby Amir on 3/31/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "SceneViewController.h"

@interface SceneViewController ()

@end

@implementation SceneViewController {
    UIButton *_deleteButton;
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
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    //self.videoView.layer.cornerRadius = 6.0f;
    //self.videoView.clipsToBounds = YES;
    self.videoView.layer.cornerRadius = 6.0f;
    self.videoView.clipsToBounds = YES;
    
    _deleteButton = [[UIButton alloc] init];
    _deleteButton.frame = CGRectMake(60, 0, 20.0f, 20.0f);
    _deleteButton.alpha = 0.8;
    _deleteButton.clipsToBounds = NO;
    UIImage *closeButtonImage = [UIImage imageNamed:@"circledclose"];
    [_deleteButton setImage:closeButtonImage forState:UIControlStateNormal];
    //[_closeButton addTarget:self action:@selector(_handleCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
