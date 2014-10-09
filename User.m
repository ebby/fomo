//
//  User.m
//  nearsight
//
//  Created by Ebby Amir on 4/14/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id": @"id",
             @"username": @"username"
             };
}

@end