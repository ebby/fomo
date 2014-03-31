//
//  Foursquare.h
//  fomo
//
//  Created by Ebby Amir on 3/25/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "OVCClient.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "Place.h"
@import CoreLocation;

@interface Foursquare : OVCClient

+ (instancetype)sharedClient;
- (RACSignal *)fetchPlaces:(CLLocationCoordinate2D)coordinate;

@end
