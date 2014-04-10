//
//  Post.m
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "Post.h"
#import "Constants.h"
#import "AFHTTPRequestOperation.h"

@implementation Post

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id": @"id",
             @"media": @"media",
             @"timeline": @"timeline",
             @"caption": @"caption",
             @"added": @"added",
             @"place": @"place"
             };
}

+ (NSOperationQueue *)sharedQueue {
    static NSOperationQueue *_sharedQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedQueue = [[NSOperationQueue alloc] init];
        [_sharedQueue setMaxConcurrentOperationCount:1];
    });
    
    return _sharedQueue;
}

- (void)download
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self getDownloadPath]]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self getVideoPath]]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[self getDownloadPath] append:NO];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.downloaded = YES;
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[self getDownloadPath]] options:nil];
            self.asset = asset;
            [self getLastFrame];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        [[Post sharedQueue] addOperation:operation];
    }
}


- (NSString *)getVideoPath
{
    return [NSString stringWithFormat:@"%@%@", HOST_URL, self.media];
}

- (NSString *)getDownloadPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:[@"Documents/" stringByAppendingString:[NSString stringWithFormat:@"%@.mp4", self.id]]];
}


- (UIImage *)getLastFrame {//completion:(void (^)(UIImage frame))completionBlock {
    if (self.lastFrame) {
        return self.lastFrame;
    } else {
        NSString *path = [NSString stringWithFormat:@"%@%@", HOST_URL, self.media];
        //NSString *path = self.downloaded ? [self getDownloadPath] : [self getVideoPath];
        NSURL *videoURL = [NSURL URLWithString:path];
        self.asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        
        NSTimeInterval duration = CMTimeGetSeconds(self.asset.duration);
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
        imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        CGImageRef thumb = [imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(duration - 0.1, 600)
                                                  actualTime:NULL
                                                       error:NULL];
        self.lastFrame = [[UIImage alloc] initWithCGImage:thumb];
        CGImageRelease(thumb);
        return self.lastFrame;
    }
}

+ (NSValueTransformer *)placeJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSDictionary *placeDict) {
        return [MTLJSONAdapter modelOfClass: Place.class
                         fromJSONDictionary: placeDict
                                      error: nil];
    } reverseBlock:^(Place *place) {
        return [MTLJSONAdapter JSONDictionaryFromModel:place];
    }];
}

+ (NSValueTransformer *)addedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDate *date = [dateFormatter dateFromString:str];
        return [dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}

@end
