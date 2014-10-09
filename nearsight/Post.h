//
//  Post.h
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "Mantle.h"
#import "Place.h"
#import <AVFoundation/AVFoundation.h>
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>

@interface Post : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *media;
@property (nonatomic, strong) NSString *emotion;
@property (nonatomic, strong) Place *place;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSDate *added;

@property (nonatomic, assign) BOOL downloaded;
@property (nonatomic, assign) BOOL downloading;
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) UIImage *firstFrame;
@property (nonatomic, strong) UIImage *lastFrame;

- (void)downloadWithCompletionBlock:(void (^)(AVAsset *asset))block;
- (NSString *)getVideoPath;
- (NSString *)getDownloadPath;
- (void)getFirstFrame:(void (^)(UIImage *frame))completionBlock;
- (UIImage *)getLastFrame;

@end
