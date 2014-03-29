//
//  Post.h
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "Mantle.h"

@interface Post : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *media;
@property (nonatomic, strong) NSString *emotion;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSDate *added;

@end
