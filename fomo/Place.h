//
//  Place.h
//  fomo
//
//  Created by Ebby Amir on 3/25/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "Mantle.h"

@interface Place : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *name;

@end
