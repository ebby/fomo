//
//  ThumbViewController.h
//  nearsight
//
//  Created by Ebby Amir on 4/2/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "Constants.h"

@interface ThumbViewController : UIViewController

@property (nonatomic, readwrite) BOOL place;

-(id)initWithPost:(Post *)post;
-(void)play;
-(void)stop;

@end
