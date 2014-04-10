//
//  CheckinViewController.h
//  fomo
//
//  Created by Ebby Amir on 3/31/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "BlurViewController.h"
#import "Place.h"

@protocol CheckinViewControllerDelegate;

@interface CheckinViewController : BlurViewController

@property (nonatomic, weak) id<CheckinViewControllerDelegate> delegate;

-(id) initWithPlaces:(NSArray *)places;

@end

@protocol CheckinViewControllerDelegate <NSObject>

@required
- (void)checkInViewPlaceSelected:(Place *)place;

@end