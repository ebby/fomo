//
//  Draft.m
//  nearsight
//
//  Created by Ebby Amir on 4/15/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "Draft.h"
#import "Client.h"
#import <TSMessages/TSMessage.h>
#define kUserDefaultsKey @"draft"

@implementation Draft

+ (instancetype)getDraft
{
    Draft *draft;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKey];
    if (data) {
        NSLog(@"draft data");
        draft = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        draft.restored = YES;
    } else {
        NSLog(@"new draft");
        draft = [[Draft alloc] init];
    }
    return draft;
}

- (id)init {
    if ((self = [super init])) {
        self.tracks = [[NSMutableArray alloc] init];
        self.timeline = [[NSMutableArray alloc] init];
        self.motionDeltas = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)save {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefaultsKey];
}

- (void)clear {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsKey];
}

- (void)upload
{
    [self uploadDraftWithRetry:0];
}

- (void)uploadDraftWithRetry:(NSUInteger)retryCount
{
    if (retryCount < 4) {
        [[[[[Client sharedClient] uploadDraft:self]
           doNext:^(id responseObject) {
               [self clear];
           }]
          // Now the assignment will be done on the main thread.
          deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh]]
         subscribeError:^(NSError *error) {
             [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem uploading post, trying agian" type:TSMessageNotificationTypeError];
             [self uploadDraftWithRetry:(retryCount + 1)];
         }];
    }
}

#pragma mark NSCoding

#define kTracksKey       @"Tracks"
#define kDeltasKey       @"Deltas"
#define kTimelineKey     @"Timeline"
#define kOutputKey       @"Output"
#define kCaptionKey      @"Caption"
#define kPlaceKey        @"Place"

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.tracks forKey:kTracksKey];
    [encoder encodeObject:self.motionDeltas forKey:kDeltasKey];
    [encoder encodeObject:self.timeline forKey:kTimelineKey];
    [encoder encodeObject:self.outputPath forKey:kOutputKey];
    [encoder encodeObject:self.caption forKey:kCaptionKey];
    [encoder encodeObject:self.place forKey:kPlaceKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    self.tracks = [decoder decodeObjectForKey:kTracksKey];
    self.motionDeltas = [decoder decodeObjectForKey:kDeltasKey];
    self.timeline = [decoder decodeObjectForKey:kTimelineKey];
    self.outputPath = [decoder decodeObjectForKey:kOutputKey];
    self.caption = [decoder decodeObjectForKey:kCaptionKey];
    self.place = [decoder decodeObjectForKey:kPlaceKey];
    return self;
}


@end
