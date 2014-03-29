//
//  Manager.m
//  fomo
//
//  Created by Ebby Amir on 3/25/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "Manager.h"
#import <TSMessages/TSMessage.h>
#import "Foursquare.h"

@interface Manager ()

@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, assign) BOOL isFirstUpdate;

@end

@implementation Manager

+ (instancetype)sharedClient {
    static Manager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[Manager alloc] init];
    });
    
    return _sharedClient;
}

- (id)init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        NSLog(@"INIT LOCATION");
        [[[[RACObserve(self, currentLocation)
            ignore:nil]
           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               return [self updatePlaces];
           }]
          deliverOn:RACScheduler.mainThreadScheduler]
         subscribeError:^(NSError *error) {
             [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching the latest weather." type:TSMessageNotificationTypeError];
         }];
    }
    return self;
}

- (void)findCurrentLocation {
    self.isFirstUpdate = YES;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    if (location.horizontalAccuracy > 0) {
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}

- (RACSignal *)updatePlaces {
    return [[[Foursquare sharedClient] fetchPlaces:self.currentLocation.coordinate] doNext:^(NSArray *places) {
        self.places = places;
    }];
}

@end
