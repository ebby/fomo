//
//  Client.m
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "Client.h"
#import "Post.h"
#import "User.h"
#import "Constants.h"
#include "TargetConditionals.h"
#import <NSHash/NSString+NSHash.h>
#import "OVCModelResponseSerializer.h"
#import "OVCSocialRequestSerializer.h"
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

- (NSHTTPCookie *)getCookie
{
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[Client sharedClient].baseURL];
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqual:@"uid"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            return cookie;
        }
    }

    NSData *cookiedata = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    if([cookiedata length]) {
        NSHTTPCookie *cookie = [NSKeyedUnarchiver unarchiveObjectWithData:cookiedata];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        return cookie;
    }
    return nil;
}

- (RACSignal *)signupWithUsername:(NSString *)username phone:(NSString *)phone password:(NSString *)password
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSDictionary *params = @{@"username": username,
                                    @"phone": [phone SHA1],
                                 @"password": [password SHA1]};
        
        AFHTTPRequestOperation *operation = [self POST:@"_signup" parameters:params resultClass:User.class resultKeyPath:@""
                                           completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
                                               NSLog(@"Signed up");
                                               if (! error) {
                                                   NSArray* cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[[operation response] allHeaderFields]
                                                                                                             forURL:[Client sharedClient].baseURL];
                                                   
                                                   for (NSHTTPCookie *cookie in cookies) {
                                                       NSLog(@"Cookie: %@", cookie);
                                                       if ([cookie.name isEqual:@"uid"]) {
                                                           [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                                                           NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:cookie];
                                                           [[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:@"uid"];
                                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                                       }
                                                   }
                                                   
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

- (RACSignal *)loginWithUsername:(NSString *)username password:(NSString *)password
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSDictionary *params = @{@"username": username,
                                 @"password": [password SHA1]};
        AFHTTPRequestOperation *operation = [self POST:@"_login" parameters:params resultClass:User.class resultKeyPath:@""
                                            completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
                                                NSLog(@"Signed up");
                                                if (! error) {
                                                    NSArray* cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[[operation response] allHeaderFields]
                                                                                                              forURL:[Client sharedClient].baseURL];
                                                    
                                                    for (NSHTTPCookie *cookie in cookies) {
                                                        NSLog(@"Cookie: %@", cookie);
                                                        if ([cookie.name isEqual:@"uid"]) {
                                                            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                                                            NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:cookie];
                                                            [[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:@"uid"];
                                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                                        }
                                                    }
                                                    
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

- (RACSignal *)loginWithFacebookId:(NSString *)fbid andAccessToken:(NSString *)accessToken
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSDictionary *params = @{@"fbid": fbid,
                                 @"access_token": accessToken};
        NSLog(@"fbid: %@", fbid);
        NSLog(@"token: %@", accessToken);
        AFHTTPRequestOperation *operation = [self POST:@"_login" parameters:params resultClass:User.class resultKeyPath:@""
                                            completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
                                                NSLog(@"Signed up");
                                                if (! error) {
                                                    NSArray* cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[[operation response] allHeaderFields]
                                                                                                              forURL:[Client sharedClient].baseURL];
                                                    
                                                    for (NSHTTPCookie *cookie in cookies) {
                                                        NSLog(@"Cookie: %@", cookie);
                                                        if ([cookie.name isEqual:@"uid"]) {
                                                            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                                                            NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:cookie];
                                                            [[NSUserDefaults standardUserDefaults] setObject:cookieData forKey:@"uid"];
                                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                                        }
                                                    }
                                                    
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
            //NSLog(@"past: %f", [past timeIntervalSince1970]);
            [params setObject:[NSString stringWithFormat:@"%f", [past timeIntervalSince1970]] forKey:@"past"];
        }
        NSString *endpoint = @"_stream";
        if (profile) {
            endpoint = @"_stream";
        }
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BaseURLString]];
        manager.responseSerializer = [OVCModelResponseSerializer serializerWithModelClass:Post.class
                                                                          responseKeyPath:@""];
        NSURLSessionDataTask *task = [manager GET:endpoint parameters:params success:^(NSURLSessionDataTask *task, id responseObject)
         {
             NSLog(@"Fetched stream");
             [subscriber sendNext:responseObject];
             [subscriber sendCompleted];
         }failure:^(NSURLSessionDataTask *task, NSError *error)
         {
             [subscriber sendError:error];
             [subscriber sendCompleted];
         }];
        
//        AFHTTPRequestOperation *operation = [self GET:endpoint parameters:params resultClass:Post.class resultKeyPath:@""
//                                           completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
//                                               NSLog(@"Fetched stream");
//                                               if (! error) {
//                                                   [subscriber sendNext:responseObject];
//                                               }
//                                               else {
//                                                   [subscriber sendError:error];
//                                               }
//                                               
//                                               [subscriber sendCompleted];
//                                           }];

        [task resume];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }] doError:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (RACSignal *)fetchPlaces
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        NSString *endpoint = @"_places";
        AFHTTPRequestOperation *operation = [self GET:endpoint parameters:params resultClass:Place.class resultKeyPath:@""
                                           completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
                                               NSLog(@"Fetched places");
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


- (RACSignal *)uploadDraft:(Draft *)draft
{
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{@"caption": draft.caption,
                                     @"place": draft.place.id,
                                     @"placename": draft.place.name,
                                     @"timeline": [[draft.timeline valueForKey:@"description"] componentsJoinedByString:@","]};
        NSURL *filePath = [NSURL fileURLWithPath:draft.outputPath];
        AFHTTPRequestOperation *operation = [manager POST:[Client sharedClient].uploadUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileURL:filePath name:@"video" error:nil];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
            [draft clear];
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [subscriber sendError:error];
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
