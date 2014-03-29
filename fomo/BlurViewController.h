//
//  MenuViewController.h
//  fomo
//
//  Created by Ebby Amir on 3/26/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlurViewController : UIViewController

@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, copy) dispatch_block_t dismissAction;

-(void)show;
-(void)hide;

@end
