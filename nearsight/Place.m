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

#pragma mark NSCoding

#define kIdKey       @"Id"
#define kNameKey       @"Name"

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.id forKey:kIdKey];
    [encoder encodeObject:self.name forKey:kNameKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    self.id = [decoder decodeObjectForKey:kIdKey];
    self.name = [decoder decodeObjectForKey:kNameKey];
    return self;
}

@end
