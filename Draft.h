//
//  Draft.h
//  nearsight
//
//  Created by Ebby Amir on 4/15/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"

@interface Draft : NSObject <NSCoding>

@property (nonatomic, strong, readwrite) NSMutableArray *tracks;
@property (nonatomic, strong, readwrite) NSMutableArray *motionDeltas;
@property (nonatomic, strong, readwrite) NSMutableArray *timeline;
@property (nonatomic, strong, readwrite) NSString *outputPath;
@property (nonatomic, strong, readwrite) NSString *caption;
@property (nonatomic, strong, readwrite) Place *place;

@property (nonatomic, assign) BOOL restored;

+ (instancetype)getDraft;
- (id)init;
- (void)save;
- (void)clear;
- (void)upload;

@end
