//
//  PostViewController.h
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "Post.h"
#import "Constants.h"

@interface PostViewController : UIViewController

@property (nonatomic, readwrite) Place *place;
@property (nonatomic, readwrite) Post *post;

-(id)initWithPost:(Post *)post;
-(id)initWithPost:(Post *)post andFrame:(CGRect)frame;
-(void)play;
-(void)stop;

@end
