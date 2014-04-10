//
//  ThumbTableViewController.h
//  nearsight
//
//  Created by Ebby Amir on 4/2/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbTableViewController : UITableViewController

@property (nonatomic, readwrite) BOOL profile;
@property (nonatomic, readwrite) BOOL place;

-(id)initForProfile;
-(void)loadStream;

@end
