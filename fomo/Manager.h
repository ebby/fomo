//
//  Manager.h
//  fomo
//
//  Created by Ebby Amir on 3/25/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
@import CoreLocation;

@interface Manager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) NSArray *places;

+ (instancetype)sharedClient;
- (void)findCurrentLocation;

@end
