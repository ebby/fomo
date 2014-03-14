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


- (RACSignal *)fetchStream {
    return [self fetchStreamWithLast:nil orPast:nil];
}

- (RACSignal *)updateStream:(NSDate *)lastFetch
{
    return [self fetchStreamWithLast:lastFetch orPast:nil];
}

- (RACSignal *)loadMoreStream:(NSDate *)past
{
    return [self fetchStreamWithLast:nil orPast:past];
}

- (RACSignal *)fetchStreamWithLast:(NSDate *)lastFetch orPast:(NSDate *)past
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
        AFHTTPRequestOperation *operation = [self GET:@"_stream" parameters:params resultClass:Post.class resultKeyPath:@""
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
