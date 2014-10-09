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

- (void)downloadWithCompletionBlock:(void (^)(AVAsset *asset))block
{
    AFHTTPRequestOperation *operation;
    if (!self.asset && !self.downloading && ![[NSFileManager defaultManager] fileExistsAtPath:[self getDownloadPath]]) {
        NSLog(@"DOWNLOADING: %@", self.caption);
        self.downloading = YES;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self getVideoPath]]];
        operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[self getDownloadPath] append:NO];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.downloaded = YES;
            self.downloading = NO;
            self.asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[self getDownloadPath]] options:nil];
             NSLog(@"DOWNLOADED: %@", self.caption);
            block(self.asset);
            //[self getLastFrame];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            NSError *deleteError = nil;
            [[NSFileManager defaultManager] removeItemAtPath:[self getDownloadPath] error:&deleteError];
        }];
        
        self.downloading = YES;
        [[Post sharedQueue] addOperation:operation];
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:[self getDownloadPath]]) {
//        NSLog(@"ALREADY DOWNLOADED");
        self.downloaded = YES;
        self.asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[self getDownloadPath]] options:nil];
        block(self.asset);
    } else {
//        NSLog(@"ALREADY DOWNLOADED");
        block(self.asset);
    }
}

//- (RACSignal *)download
//{
//    self.downloaded = NO;
//    self.downloading = NO;
//    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        AFHTTPRequestOperation *operation;
//        if (!self.asset && !self.downloading && ![[NSFileManager defaultManager] fileExistsAtPath:[self getDownloadPath]]) {
//            NSLog(@"DOWNLOADING");
//            self.downloading = YES;
//            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self getVideoPath]]];
//            operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[self getDownloadPath] append:NO];
//            
//            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//                self.downloaded = YES;
//                self.downloading = NO;
//                self.asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[self getDownloadPath]] options:nil];
//                [subscriber sendNext:self.asset];
//                //[self getLastFrame];
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSLog(@"Error: %@", error);
//                NSError *deleteError = nil;
//                [[NSFileManager defaultManager] removeItemAtPath:[self getDownloadPath] error:&deleteError];
//                [subscriber sendError:error];
//            }];
//            
//            self.downloading = YES;
//            [[Post sharedQueue] addOperation:operation];
//        } else if ([[NSFileManager defaultManager] fileExistsAtPath:[self getDownloadPath]]) {
//            NSLog(@"ALREADY DOWNLOADED");
//            self.downloaded = YES;
//            self.asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[self getDownloadPath]] options:nil];
//            [subscriber sendNext:self.asset];
//        } else {
//            NSLog(@"ALREADY DOWNLOADED");
//            [subscriber sendNext:self.asset];
//        }
//        [subscriber sendCompleted];
//        return [RACDisposable disposableWithBlock:^{
//            if (operation) {
//                [operation cancel];
//            }
//        }];
//    }] doError:^(NSError *error) {
//        NSLog(@"%@",error);
//    }];
//}


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
//        NSString *path = [NSString stringWithFormat:@"%@%@", HOST_URL, self.media];
//        //NSString *path = self.downloaded ? [self getDownloadPath] : [self getVideoPath];
//        NSURL *videoURL = [NSURL URLWithString:path];
//        self.asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        
        NSTimeInterval duration = CMTimeGetSeconds(self.asset.duration);
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:(self.asset ? self.asset
                                                                                              : [AVURLAsset URLAssetWithURL:[NSURL URLWithString:[self getVideoPath]] options:nil])];
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

- (void)getFirstFrame:(void (^)(UIImage *frame))completionBlock {
    if (self.firstFrame) {
        completionBlock(self.firstFrame);
    } else {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self getDownloadPath]]) {
            [self downloadWithCompletionBlock:^(AVAsset *asset) {
                NSTimeInterval beginning = CMTimeGetSeconds(kCMTimeZero);
                self.firstFrame = [self getFrameAt:beginning asset:asset];
                completionBlock(self.firstFrame);
            }];
            return;
        }
        AVAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:[self getVideoPath]] options:nil];
        NSArray *keys = [NSArray arrayWithObject:@"playable"];
        [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
            NSError *error = nil;
            AVKeyValueStatus status = [asset statusOfValueForKey:@"playable" error:&error];
            switch (status) {
                case AVKeyValueStatusLoaded:{
                    NSTimeInterval beginning = CMTimeGetSeconds(kCMTimeZero);
                    self.firstFrame = [self getFrameAt:beginning asset:asset];
                    completionBlock(self.firstFrame);
                    }
                    break;
                case AVKeyValueStatusFailed:
                    NSLog(@"couldn't load asset for generating thumbnail");
                    break;
                case AVKeyValueStatusCancelled:
                    // Do whatever is appropriate for cancelation.
                    break;
            }
        }];
    }
}

- (UIImage *)getFrameAt:(NSTimeInterval)time asset:(AVAsset *)asset {
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    CGImageRef thumb = [imageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(time, 600)
                                              actualTime:NULL
                                                   error:NULL];
    UIImage *image = [[UIImage alloc] initWithCGImage:thumb];
    CGImageRelease(thumb);
    return image;
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
