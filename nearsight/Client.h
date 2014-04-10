//
//  Client.h
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "OVCClient.h"
#import "AFNetworking.h"
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

@interface Client : OVCClient

+ (instancetype)sharedClient;

- (void)getUploadUrl;
- (RACSignal *)fetchStreamForProfile:(BOOL)profile;
- (RACSignal *)updateStream:(NSDate *)lastFetch forProfile:(BOOL)profile;
- (RACSignal *)loadMoreStream:(NSDate *)past forProfile:(BOOL)profile;
- (RACSignal *)fetchPlaces;

@property NSString *uploadUrl;

@end
