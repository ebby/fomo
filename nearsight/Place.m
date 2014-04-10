//
//  Place.m
//  fomo
//
//  Created by Ebby Amir on 3/25/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "Place.h"

@implementation Place

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
               @"id": @"id",
             @"name": @"name",
          @"picture": @"picture",
         @"location": @"location",
             };
}

//
//+ (NSValueTransformer *)locationJSONTransformer {
//    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSDictionary *placeDict) {
//        CLLocationCoordinate2D *location = CLLocationCoordinate2DMake([[placeDict objectForKey:@"lat"] floatValue],
//                                                           [[placeDict objectForKey:@"lon"] floatValue]);
//        return location;
//    } reverseBlock:^(Place *place) {
//        return [MTLJSONAdapter JSONDictionaryFromModel:place];
//    }];
//}

+ (NSValueTransformer *)locationJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSDictionary *locationData) {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([[locationData objectForKey:@"lat"] floatValue],
                                                           [[locationData objectForKey:@"lon"] floatValue]);
        return [NSValue value:&location
                 withObjCType:@encode(CLLocationCoordinate2D)];
    } reverseBlock:^(NSValue *location) {
        //NSString *locStr = [NSString stringWithFormat:@"{\"lat\":\"%f\", \"lon\":\"%f\"}", location.longitude, location.longitude];
        return @"";//[locStr to];
    }];
}

@end
