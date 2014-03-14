//
//  PostViewController.h
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "Constants.h"

@interface PostViewController : UIViewController

-(id)initWithPost:(Post *)post;
-(void)play;

@end
