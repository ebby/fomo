//
//  ThumbView.m
//  nearsight
//
//  Created by Ebby Amir on 4/2/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "ThumbView.h"
#import <AVFoundation/AVFoundation.h>
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

@implementation ThumbView {
    AVAsset *_asset;
    UITextView *_caption;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //self.backgroundColor = [UIColor blackColor];
    
    NSString *videoPath = [NSString stringWithFormat:@"%@%@", HOST_URL, self.post.media];
    NSURL *videoURL = [NSURL URLWithString:videoPath];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    _asset = asset;
    
    NSTimeInterval beginning = CMTimeGetSeconds(kCMTimeZero);
    AVAssetImageGenerator *firstImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_asset];
    firstImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    firstImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    CGImageRef firstThumb = [firstImageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(beginning, 600)
                                                        actualTime:NULL
                                                             error:NULL];
    self.thumb = [[UIImage alloc] initWithCGImage:firstThumb];
    CGImageRelease(firstThumb);
    
    UIView *imageHolder = [[UIView alloc] initWithFrame:self.frame];
    imageHolder.backgroundColor = [UIColor blackColor];
    imageHolder.layer.cornerRadius = 6.0f;
    imageHolder.clipsToBounds = YES;
    
    
    UIImageView *thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [thumbView setImageToBlur:self.thumb blurRadius:2 completionBlock:nil];
    thumbView.alpha = .8f;
    thumbView.backgroundColor = [UIColor blackColor];
    [imageHolder addSubview:thumbView];
    [self addSubview:imageHolder];
    
    // Caption
    _caption = [[UITextView alloc] initWithFrame:CGRectMake(1, 1, self.frame.size.width - 1.0f, self.frame.size.height)];
    _caption.text = self.post.caption;
    _caption.backgroundColor = [UIColor clearColor];
    _caption.textColor = [UIColor whiteColor];
    _caption.textAlignment = NSTextAlignmentLeft;
    _caption.alpha = 1;
    _caption.editable = NO;
    _caption.userInteractionEnabled = NO;
    [_caption setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:20]];
    [imageHolder addSubview:_caption];
}

@end
