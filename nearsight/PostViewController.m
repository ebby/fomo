//
//  PostViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "PostViewController.h"
#import "PBJVideoPlayerController.h"
#import "UIERealTimeBlurView.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import <QuartzCore/QuartzCore.h>
#import "AddPostViewController.h"
#import "PlaceViewController.h"

@interface PostViewController () <PBJVideoPlayerControllerDelegate>
{
    PBJVideoPlayerController *_videoPlayerController;
    UIImageView *_playButton;
    UIActivityIndicatorView *_spinner;
    UITextView *_caption;
    UIImageView *_blurredImage;
    UIView *_blurredImageView;
    UIView *_placeView;
    UIButton *_placeButton;
    UILabel *_atLabel;
    CGRect _frame;
}


@end

@implementation PostViewController

@synthesize post = _post;
@synthesize place = _place;


- (id)initWithPost:(Post *)post
{
    self = [super init];
    if (self) {
        self.post = post;
    }
    return self;
}

- (id)initWithPost:(Post *)post andFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.post = post;
        _frame = frame;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //if (_frame) {
    //    self.view.frame = _frame;
    //}
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _videoPlayerController = [[PBJVideoPlayerController alloc] init];
    _videoPlayerController.delegate = self;
    _videoPlayerController.view.frame = self.view.frame;
    _videoPlayerController.view.backgroundColor = [UIColor blackColor];
    
    [self addChildViewController:_videoPlayerController];
    [self.view addSubview:_videoPlayerController.view];
    [_videoPlayerController didMoveToParentViewController:self];
    
    // Spinner
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_spinner setCenter:CGPointMake(viewWidth/2.0, viewHeight/2.0)];
    [self.view addSubview:_spinner];
    
    _playButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_button"]];
    _playButton.center = self.view.center;
    [self.view addSubview:_playButton];
    [self.view bringSubviewToFront:_playButton];
    
    // Blurred Image
    _blurredImageView = [[UIView alloc] initWithFrame:self.view.frame];
    _blurredImageView.backgroundColor = [UIColor blackColor];
    _blurredImageView.alpha = 1;
    _blurredImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    _blurredImage.alpha = 0;
    //_blurredImage.contentMode = UIViewContentModeScaleAspectFit;
    [_blurredImageView addSubview:_blurredImage];
    [self.view addSubview:_blurredImageView];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleBlurTap:)];
    [_blurredImageView addGestureRecognizer:singleFingerTap];
    
//    _parallaxView = [[ACParallaxView alloc] initWithFrame:self.view.frame];
//    _parallaxView.parallax = YES;
//    _parallaxView.refocusParallax = YES;
//    [self.view addSubview:_parallaxView];
    
    // Caption
    _caption = [[UITextView alloc] initWithFrame:CGRectMake(20.0f, 0, viewWidth - 40.0f, viewHeight)];
    _caption.backgroundColor = [UIColor clearColor];
    _caption.textColor = [UIColor whiteColor];
    _caption.textAlignment = NSTextAlignmentLeft;
    _caption.alpha = .9;
    _caption.editable = NO;
    _caption.userInteractionEnabled = NO;
    [_caption setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:22]];
    [_caption addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    [_blurredImageView addSubview:_caption];
    
    // Place
    _placeView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 0, viewWidth - 40.0f, viewHeight)];
    _placeView.backgroundColor = [UIColor clearColor];
    _placeView.alpha = .9;
    
    _atLabel = [[UILabel alloc] init];
    _atLabel.text = @"— At";
    _atLabel.backgroundColor = [UIColor clearColor];
    _atLabel.textColor = [UIColor whiteColor];
    [_atLabel setFont:[UIFont fontWithName:@"MrsEaves-Italic" size:22]];
    [_placeView addSubview:_atLabel];

    _placeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 40.0f)];
    _placeButton.userInteractionEnabled = YES;
    _placeButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    

    [_placeButton addTarget:self action:@selector(_handlePlaceButton:) forControlEvents:UIControlEventTouchUpInside];
    _placeButton.titleLabel.font = [UIFont fontWithName:@"MrsEaves-Italic" size:22];
    
    [_placeView addSubview:_placeButton];
    [_blurredImageView addSubview:_placeView];

    
    
    [_spinner startAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePauseNotification:)
                                                 name:@"Pause"
                                               object:nil];
    
    [self setPost:self.post];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    float newY = viewHeight/4 - [_caption contentSize].height/2;
    [_caption setFrame:CGRectMake(20.0f, newY, self.view.frame.size.width - 40.0f, [_caption contentSize].height)];
    [_placeView setFrame:CGRectMake(20.0f, newY + [_caption contentSize].height + 10.0f, self.view.frame.size.width - 40.0f, 40.0f)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleBlurTap:(UITapGestureRecognizer *)recognizer {
    [self play];
}

-(void)setPost:(Post *)post
{
    _post = post;
    _caption.text = post.caption;

    [self setPlace:post.place];
    
    //NSString *downloadPath = [NSHomeDirectory() stringByAppendingPathComponent:[@"Documents/" stringByAppendingString:[NSString stringWithFormat:@"%@.mp4", self.post.id]]];
    
    [_blurredImage setImageToBlur:[post getLastFrame] blurRadius:2 completionBlock:nil];
    [UIView animateWithDuration:0.3f animations:^{
        _blurredImage.alpha = 0.6f;
    } completion:^(BOOL finished) {
    }];
    
    if (post.asset) {
        [_videoPlayerController setAsset:post.asset];
    } else {
        NSString *videoPath = post.downloaded ? [post getDownloadPath] : [post getVideoPath];
        [_videoPlayerController setVideoPath:videoPath];
    }
    
    
}

-(void)setPlace:(Place *)place
{
    _place = place;
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                         NSForegroundColorAttributeName: [UIColor whiteColor]};

    if (self.post.place) {
        NSString *placeName = self.post.place.name ? self.post.place.name : (self.post.emotion ? self.post.emotion : @"Glasslands Gallery");
        [_placeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:placeName attributes:underlineAttribute] forState:UIControlStateNormal];
    } else if (self.post.emotion) {
        [_placeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:self.post.emotion attributes:underlineAttribute] forState:UIControlStateNormal];
    }
    
    CGSize stringsize = [_placeButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_placeButton.titleLabel.font}];
    float newWidth = stringsize.width + 10;
    float newHeight = stringsize.height + 10;

    _placeButton.frame = CGRectMake(viewWidth - newWidth - 40.0f, 5.0f, newWidth, newHeight);
    _atLabel.frame = CGRectMake(viewWidth - newWidth - 80.0f, 0, viewWidth, 40.0f);

}

-(void)play
{
    [_videoPlayerController playFromBeginning];
}

-(void)stop
{
    [_videoPlayerController stop];
}

-(void)_handlePlaceButton:(UIButton *)button
{
    PlaceViewController *placeViewController = [[PlaceViewController alloc] init];
    [self.navigationController pushViewController:placeViewController animated:YES];
}

#pragma mark - UIViewController status bar

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    [_spinner stopAnimating];
    
    
//    if (videoPlayer.lastFrame) {
//        [_blurredImage setImageToBlur:videoPlayer.lastFrame blurRadius:2 completionBlock:nil];
//        [UIView animateWithDuration:0.3f animations:^{
//            _blurredImage.alpha = 0.6f;
//        } completion:^(BOOL finished) {
//        }];
//    }
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    if (videoPlayer.playbackState == PBJVideoPlayerPlaybackStatePlaying) {
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
            _blurredImageView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _blurredImageView.hidden = YES;
        }];
    } else if (videoPlayer.playbackState == PBJVideoPlayerPlaybackStatePaused
               || videoPlayer.playbackState == PBJVideoPlayerPlaybackStateStopped) {
        _blurredImageView.hidden = NO;
        _blurredImageView.backgroundColor = [UIColor blackColor];
        
        [UIView animateWithDuration:0.3f animations:^{
            _blurredImageView.alpha = 1.0f;
        } completion:^(BOOL finished) {
        }];

    }
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    _blurredImageView.hidden = NO;
    _blurredImageView.backgroundColor = [UIColor blackColor];
    
    [UIView animateWithDuration:0.3f animations:^{
        _blurredImageView.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
}

- (void)receivePauseNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"Pause"]) {
        _blurredImageView.alpha = 1;
        [_videoPlayerController pause];
    }
}

@end
