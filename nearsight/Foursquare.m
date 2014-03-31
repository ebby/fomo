//
//  Foursquare.m
//  fomo
//
//  Created by Ebby Amir on 3/25/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "Foursquare.h"

NSString *const FOURSQUARE_URL = @"https://api.foursquare.com";
NSString *const SEARCH_ENDPOINT = @"/v2/venues/search";
NSString *const CLIENT_ID = @"FKLM3IISZB4N4FTQYR3F4BYDLBYNTA5DCD2MEQYGC25IE4GY";
NSString *const CLIENT_SECRET = @"IA3PQKIOS22XJOEPI3YQ3L02O4TQJTID2TWNUOFVN4MLLK0R";
NSString *const VERSION = @"20140320";

@implementation Foursquare

+ (instancetype)sharedClient {
    static Foursquare *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[Foursquare alloc] initWithBaseURL:[NSURL URLWithString:FOURSQUARE_URL]];
    });
    
    return _sharedClient;
}

- (RACSignal *)fetchPlaces:(CLLocationCoordinate2D)coordinate {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:CLIENT_ID forKey:@"client_id"];
        [params setObject:CLIENT_SECRET forKey:@"client_secret"];
        [params setObject:VERSION forKey:@"v"];
        [params setObject:[[NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"ll"];
        NSLog(@"Fetching places");
        AFHTTPRequestOperation *operation = [self GET:SEARCH_ENDPOINT
                                           parameters:params
                                          resultClass:Place.class
                                        resultKeyPath:@"response.venues"
                                           completion:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
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
