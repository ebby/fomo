//
//  Place.h
//  fomo
//
//  Created by Ebby Amir on 3/25/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "Mantle.h"
#import <CoreLocation/CoreLocation.h>

@interface Place : MTLModel <MTLJSONSerializing, NSCoding>

@property (nonatomic) NSNumber *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, assign) CLLocationCoordinate2D location;

@end
