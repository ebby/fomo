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
- (RACSignal *)fetchStream;
- (RACSignal *)updateStream:(NSDate *)lastFetch;
- (RACSignal *)loadMoreStream:(NSDate *)past;

@property NSString *uploadUrl;

@end
