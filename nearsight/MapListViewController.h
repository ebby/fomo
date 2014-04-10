//
//  MapListViewController.h
//  nearsight
//
//  Created by Ebby Amir on 4/2/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@interface MapListViewController : UIViewController

@property (nonatomic, strong) NSArray *places;
- (void)loadPlaces:(NSArray *)places;
@end
