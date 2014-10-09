//
//  User.h
//  nearsight
//
//  Created by Ebby Amir on 4/14/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "Mantle.h"

@interface User : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *username;

@end
