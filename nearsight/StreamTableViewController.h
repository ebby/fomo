//
//  StreamViewController.h
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamTableViewController : UITableViewController

@property (nonatomic, readwrite) BOOL profile;
@property (nonatomic, readwrite) BOOL place;

-(id)initForProfile;
-(void)loadStream;

@end
