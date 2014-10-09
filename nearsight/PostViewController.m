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

static void *VideoPlayerObserverContext = &VideoPlayerObserverContext;


@interface PostViewController ()
{
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    UIView *_playerView;
    AVPlayerLayer *_playerLayer;
    PBJVideoPlayerController *_videoPlayerController;
    UIImageView *_playButton;
    UIActivityIndicatorView *_spinner;
    UILabel *_caption;
    UIImageView *_blurredImage;
    UIView *_blurredImageView;
    UIView *_placeView;
    UIButton *_placeButton;
    UILabel *_atLabel;
    CGRect _frame;
}

@property (nonatomic, assign) BOOL shouldPlay;
@property (nonatomic, assign) BOOL loaded;
@property (nonatomic, assign) NSUInteger retry;

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
    
    self.retry = 0;
    
    self.view.backgroundColor = [UIColor blackColor];
    
//    _videoPlayerController = [[PBJVideoPlayerController alloc] init];
//    _videoPlayerController.delegate = self;
//    _videoPlayerController.view.frame = self.view.frame;
//    _videoPlayerController.view.backgroundColor = [UIColor blackColor];
    
    
    _player = [[AVPlayer alloc] init];
    _player.volume = 0.5f;
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = self.view.frame;
    _playerView = [[UIView alloc] initWithFrame:self.view.frame];
    [_playerView.layer addSublayer:_playerLayer];
    [self.view addSubview:_playerView];
    UITapGestureRecognizer *playerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handlePlayerTap:)];
    [_playerView addGestureRecognizer:playerTap];

    [_player addObserver:self forKeyPath:@"status" options:0 context:VideoPlayerObserverContext];
    
    // Spinner
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_spinner setCenter:CGPointMake(viewWidth/2.0, viewHeight/2.0)];
    _spinner.alpha = 0;
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
    _caption = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, self.view.frame.size.height - 40)];
    _caption.text = _post.caption;
    _caption.lineBreakMode = NSLineBreakByWordWrapping;
    _caption.numberOfLines = 0;
    _caption.backgroundColor = [UIColor clearColor];
    _caption.textColor = [UIColor whiteColor];
    _caption.textAlignment = NSTextAlignmentLeft;
    _caption.alpha = .9;
    UIFont *font = [UIFont fontWithName:@"ProximaNovaCond-Regular" size:22];
    [_caption setFont:font];
    [_caption addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    [_blurredImageView addSubview:_caption];
    
    CGSize captionSize = [_caption.text sizeWithFont:font constrainedToSize:_caption.frame.size];
    
    // Place
    _placeView = [[UIView alloc] initWithFrame:CGRectMake(20.0f, (self.view.frame.size.height + captionSize.height)/2 + 10, viewWidth - 40.0f, viewHeight)];
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
    // Application NSNotifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(_applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self setPost:self.post];
//    [[[self.post download]
//      doNext:^(AVAsset *asset) {
//          [self showPoster];
//          [self load];
//      }]
//     subscribeError:^(NSError *error) {
//         NSLog(@"Error downloading post");
//     }];
    
    dispatch_queue_t posterQueue = dispatch_queue_create("com.xylo.nearsight.POSTERS", NULL);
    dispatch_async(posterQueue, ^{
        [self showPoster];
    });
    dispatch_async(dispatch_queue_create("com.xylo.nearsight.LOADER", NULL), ^{
        [self.post downloadWithCompletionBlock:^(AVAsset *asset) {
           [self load];
        }];
    });
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ( context == VideoPlayerObserverContext) {
//        NSLog(@"video status change");
        switch (_player.status) {
            case AVPlayerStatusReadyToPlay:
                self.loaded = YES;
                [_spinner stopAnimating];
                if (self.shouldPlay) {
                    [self play];
                    self.shouldPlay = NO;
                }
                
                break;
            case AVPlayerStatusFailed:
                NSLog(@"asset failed to LOAD");
                break;
            case AVPlayerStatusUnknown:
                NSLog(@"asset failed to LOAD UNKNOWN");
                break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleBlurTap:(UITapGestureRecognizer *)recognizer {
    [self play];
}

- (void)handlePlayerTap:(UITapGestureRecognizer *)recognizer {
    [self stop];
}

-(void)setPost:(Post *)post
{
    _post = post;
 //   _caption.text = post.caption;

    [self setPlace:post.place];
}

-(void)showPoster
{
    [_post getFirstFrame:^(UIImage *frame){
//        NSLog(@"first frame: %@", frame);
        if (frame) {
            [_blurredImage setImageToBlur:frame blurRadius:2 completionBlock:nil];
            [UIView animateWithDuration:0.3f animations:^{
                _blurredImage.alpha = 0.6f;
            } completion:^(BOOL finished) {
            }];
            
//            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
//            dispatch_async(queue, ^{
//                [self load];
//            });
        } else if (self.retry < 3) {
            // Retry
            self.retry++;
            NSLog(@"retrying!");
            [self showPoster];
        }
    }];
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


-(void)load {
    if (self.loaded) {
        return;
    }

    if (!self.post.asset) {
        self.post.asset = self.post.downloaded ? [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[self.post getDownloadPath]] options:nil]
            : [AVURLAsset URLAssetWithURL:[NSURL URLWithString:[self.post getVideoPath]] options:nil];
    }

    if (!_playerItem) {
        _playerItem = [AVPlayerItem playerItemWithAsset:self.post.asset];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_playerItemDidPlayToEndTime:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:_playerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_playerItemFailedToPlayToEndTime:)
                                                     name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                   object:_playerItem];
    }
    
        [_player replaceCurrentItemWithPlayerItem:_playerItem];
}

-(void)play
{
    NSLog(@"should play: %@", self.post.caption);
    
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame = _playerView.frame;
        [_playerView.layer addSublayer:_playerLayer];
        [_player addObserver:self forKeyPath:@"status" options:0 context:VideoPlayerObserverContext];
    }
    
    if (self.loaded) {
        [_player play];
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
                                _blurredImageView.alpha = 0.0f;
                            } completion:^(BOOL finished) {
                                _blurredImageView.hidden = YES;
                            }];

    } else if (_playerItem) {
        self.shouldPlay = YES;
         [_player replaceCurrentItemWithPlayerItem:_playerItem];
    } else {
        self.shouldPlay = YES;
        [self load];
    }
}

-(void)stop
{
    [_player pause];
    _blurredImageView.hidden = NO;
    _blurredImageView.backgroundColor = [UIColor blackColor];
    
    [UIView animateWithDuration:0.3f animations:^{
        _blurredImageView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self eject];
    }];
}

-(void)eject
{
    self.loaded = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_playerItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:_playerItem];
    _playerItem = nil;
    [_player removeObserver:self forKeyPath:@"status" context:VideoPlayerObserverContext];
    [_player replaceCurrentItemWithPlayerItem:nil];
    _player = nil;
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;
}

-(void)_handlePlaceButton:(UIButton *)button
{
    PlaceViewController *placeViewController = [[PlaceViewController alloc] init];
    [self.navigationController pushViewController:placeViewController animated:YES];
}

- (void)_playerItemDidPlayToEndTime:(NSNotification *)aNotification
{
    [_player seekToTime:kCMTimeZero];
    [self stop];
}

- (void)_playerItemFailedToPlayToEndTime:(NSNotification *)aNotification
{
    NSLog(@"error (%@)", [[aNotification userInfo] objectForKey:AVPlayerItemFailedToPlayToEndTimeErrorKey]);
}

#pragma mark - UIViewController status bar

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)receivePauseNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"Pause"]) {
        _blurredImageView.alpha = 1;
        [self stop];
    }
}

#pragma mark - App NSNotifications

- (void)_applicationWillResignActive:(NSNotification *)aNotfication
{

}

- (void)_applicationWillEnterForeground:(NSNotification *)aNotfication
{
    self.loaded = NO;
    [self load];
}

- (void)_applicationDidEnterBackground:(NSNotification *)aNotfication
{

}

@end
