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
#import "Draft.h"

@interface Client : OVCClient

+ (instancetype)sharedClient;

- (void)getUploadUrl;
- (NSHTTPCookie *)getCookie;
- (RACSignal *)loginWithFacebookId:(NSString *)fbid andAccessToken:(NSString *)accessToken;
- (RACSignal *)signupWithUsername:(NSString *)username phone:(NSString *)phone password:(NSString *)password;
- (RACSignal *)loginWithUsername:(NSString *)username password:(NSString *)password;
- (RACSignal *)fetchStreamForProfile:(BOOL)profile;
- (RACSignal *)updateStream:(NSDate *)lastFetch forProfile:(BOOL)profile;
- (RACSignal *)loadMoreStream:(NSDate *)past forProfile:(BOOL)profile;
- (RACSignal *)fetchPlaces;
- (RACSignal *)uploadDraft:(Draft *)draft;

@property NSString *uploadUrl;

@end
