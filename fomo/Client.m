//
//  Client.m
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "Client.h"
#import "Post.h"
#include "TargetConditionals.h"
#import <NSHash/NSString+NSHash.h>
@import CoreLocation;

//static NSString * const BaseURLString = @"http://localhost:8009/";

//#if TARGET_IPHONE_SIMULATOR
//    static NSString * const BaseURLString = @"http://localhost:8009/";
//#else
    static NSString * const BaseURLString = @"http://fomo-app.appspot.com/";
//#endif


@implementation Client

+ (instancetype)sharedClient {
    static Client *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[Client alloc] initWithBaseURL:[NSURL URLWithString:BaseURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    });
    
    return _sharedClient;
}

- (void)getUploadUrl {
    [self GET:@"_postvideo" parameters:nil resultClass:nil resultKeyPath:nil
        completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
            self.uploadUrl = responseObject[@"upload_url"];
            NSLog(@"%@", self.uploadUrl);
        }];
}

- (RACSignal *)loginWithPhone:(NSString *)phone andPassword:(NSString *)password
{
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSDictionary *params = @{@"phone": [phone SHA1],
                                 @"password": [password SHA1]};
        AFHTTPRequestOperation *operation = [self GET:@"_login" parameters:params resultClass:nil resultKeyPath:@""
                                           completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
                                               NSLog(@"Logged in");
                                               if (! error) {
                                                   [subscriber sendNext:responseObject];
                                               }
                                               else {
                                                   [subscriber sendError:error];
                                               }

                                               [subscriber sendCompleted];
                                           }];
        
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }] doError:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (RACSignal *)fetchStreamForProfile:(BOOL)profile {
    return [self fetchStreamWithLast:nil orPast:nil forProfile:profile];
}

- (RACSignal *)updateStream:(NSDate *)lastFetch forProfile:(BOOL)profile
{
    return [self fetchStreamWithLast:lastFetch orPast:nil forProfile:profile];
}

- (RACSignal *)loadMoreStream:(NSDate *)past forProfile:(BOOL)profile
{
    return [self fetchStreamWithLast:nil orPast:past forProfile:profile];
}

- (RACSignal *)fetchStreamWithLast:(NSDate *)lastFetch orPast:(NSDate *)past forProfile:(BOOL)profile
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        if (lastFetch) {
            [params setObject:[NSString stringWithFormat:@"%f", [lastFetch timeIntervalSince1970]] forKey:@"last"];
        }
        if (past) {
            NSLog(@"past: %f", [past timeIntervalSince1970]);
            [params setObject:[NSString stringWithFormat:@"%f", [past timeIntervalSince1970]] forKey:@"past"];
        }
        NSString *endpoint = @"_stream";
        if (profile) {
            endpoint = @"_stream";
        }
        AFHTTPRequestOperation *operation = [self GET:endpoint parameters:params resultClass:Post.class resultKeyPath:@""
                                           completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
                                               NSLog(@"Fetched stream");
                                               if (! error) {
                                                   [subscriber sendNext:responseObject];
                                               }
                                               else {
                                                   [subscriber sendError:error];
                                               }
                                               
                                               [subscriber sendCompleted];
                                           }];

        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }] doError:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}



@end
