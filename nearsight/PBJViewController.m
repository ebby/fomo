//
//  PBJViewController.m
//  Vision
//
//  Created by Patrick Piemonte on 7/23/13.
//  Copyright (c) 2013 Patrick Piemonte. All rights reserved.
//

#import "PBJViewController.h"
#import "PBJStrobeView.h"
#import "PBJFocusView.h"
#import "AddPostViewController.h"

#import "PBJVision.h"
#import "PBJVisionUtilities.h"
#import "PBJVideoPlayerController.h"
#import "SceneViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <GLKit/GLKit.h>
#import "Client.h"
#import "UIExtensions.h"
#import <CoreMotion/CoreMotion.h>
#import <float.h>
#import "Draft.h"

static CMMotionManager *sharedMotionManager;

@interface PBJViewController () <
    UIApplicationDelegate,
    UIGestureRecognizerDelegate,
    PBJVisionDelegate,
    UIAlertViewDelegate,
    UIActionSheetDelegate>
{
//    PBJStrobeView *_strobeView;
    UIButton *_doneButton;
    ExtendedHitButton *_captureButton;
    UIButton *_flipButton;
    UIButton *_focusButton;
    UIButton *_onionButton;
    UIButton *_closeButton;
    UIView *_captureDock;

    UIView *_previewView;
    AVCaptureVideoPreviewLayer *_previewLayer;
    PBJFocusView *_focusView;
    GLKViewController *_effectsViewController;
    
    UIProgressView *_progress;
    UIScrollView *_tracksView;
    
    UIView *_gestureView;
    UILongPressGestureRecognizer *_longPressGestureRecognizer;
    UITapGestureRecognizer *_tapGestureRecognizer;
    UITapGestureRecognizer *_tapCaptureGestureRecognizer;
    
    UIActionSheet *_saveSheet;
    
    double _lastPitch;
    double _lastYaw;
    double _lastRoll;
    
    double _pitchDelta;
    double _yawDelta;
    double _rollDelta;
    double _motionDelta;
    
    BOOL _recording;

    ALAssetsLibrary *_assetLibrary;
    __block NSDictionary *_currentPhoto;
    __block NSDictionary *_currentVideo;
}

@property (nonatomic, strong, readwrite) AVMutableComposition *composition;
@property (nonatomic, strong, readwrite) Draft *draft;

@end

@implementation PBJViewController

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - init

- (id) init
{
    self = [super init];
    if (self) {
        self.draft = [Draft getDraft];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    _longPressGestureRecognizer.delegate = nil;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _assetLibrary = [[ALAssetsLibrary alloc] init];
    
    NSString *guid = [[NSUUID new] UUIDString];
    self.draft.outputPath = [NSString stringWithFormat:@"%@video_%@.mp4", NSTemporaryDirectory(), guid];
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);

    // preview and AV layer
    _previewView = [[UIView alloc] initWithFrame:CGRectZero];
    _previewView.backgroundColor = [UIColor blackColor];
    CGRect previewFrame = self.view.frame;
    _previewView.frame = previewFrame;
    _previewLayer = [[PBJVision sharedInstance] previewLayer];
    _previewLayer.frame = _previewView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewView.layer addSublayer:_previewLayer];
    
    // elapsed time and red dot
//    _strobeView = [[PBJStrobeView alloc] initWithFrame:CGRectZero];
//    CGRect strobeFrame = _strobeView.frame;
//    strobeFrame.origin = CGPointMake(15.0f, 15.0f);
//    _strobeView.frame = strobeFrame;
//    [self.view addSubview:_strobeView];
    
    // done button
    _doneButton = [ExtendedHitButton extendedHitButton];
    _doneButton.frame = CGRectMake(viewWidth - 20.0f - 20.0f, 20.0f, 20.0f, 20.0f);
    UIImage *buttonImage = [UIImage imageNamed:@"capture_yep"];
    [_doneButton setImage:buttonImage forState:UIControlStateNormal];
    [_doneButton addTarget:self action:@selector(_handleDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    [_previewView addSubview:_doneButton];
    
    // capture button
    _captureButton = [ExtendedHitButton extendedHitButton];
    _captureButton.frame = CGRectMake(viewWidth/2 - 32.5f, viewHeight - 75.0f, 75.0f, 75.0f);
    UIImage *captureImage = [UIImage imageNamed:@"record"];
    UIImage *recordingImage = [UIImage imageNamed:@"recording"];
    [_captureButton setImage:captureImage forState:UIControlStateNormal];
    [_captureButton setImage:recordingImage forState:UIControlStateSelected];
    _captureButton.adjustsImageWhenHighlighted = NO;
    [_previewView addSubview:_captureButton];
    
    // close button
    _closeButton = [ExtendedHitButton extendedHitButton];
    _closeButton.frame = CGRectMake(8.0f, 10.0f, 40.0f, 40.0f);
    _closeButton.alpha = 0.8;
    UIImage *closeButtonImage = [UIImage imageNamed:@"close"];
    [_closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(_handleCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [_previewView addSubview:_closeButton];
    
    // focus view
    _focusView = [[PBJFocusView alloc] initWithFrame:CGRectZero];
    
    // touch to record
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressGestureRecognizer:)];
    _longPressGestureRecognizer.delegate = self;
    _longPressGestureRecognizer.minimumPressDuration = 0.05f;
    _longPressGestureRecognizer.allowableMovement = 10.0f;
    [_captureButton addGestureRecognizer:_longPressGestureRecognizer];
    
    // tap to focus
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleFocusTapGesterRecognizer:)];
    _tapGestureRecognizer.delegate = self;
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    _tapGestureRecognizer.enabled = NO;
    //[_previewView addGestureRecognizer:_tapGestureRecognizer];
    
    // flip button
    _flipButton = [ExtendedHitButton extendedHitButton];
    UIImage *flipImage = [UIImage imageNamed:@"capture_flip"];
    [_flipButton setImage:flipImage forState:UIControlStateNormal];
    CGRect flipFrame = CGRectMake(10, viewHeight - 20, 20, 16);
    flipFrame.size = flipImage.size;
    _flipButton.frame = flipFrame;
    [_flipButton addTarget:self action:@selector(_handleFlipButton:) forControlEvents:UIControlEventTouchUpInside];
    [_captureDock addSubview:_flipButton];

    _tapGestureRecognizer.enabled = YES;
    _gestureView.hidden = YES;
    
    // Progress
    _progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progress.frame = CGRectMake(0, 0, self.view.frame.size.width, 5);
    _progress.userInteractionEnabled = NO;
    _progress.progress=0.5f;
    _progress.tintColor = [UIColor colorWithRed:46.0f/255 green:204.0f/255 blue:113.0f/255 alpha:1.0];
    [_previewView addSubview:_progress];
    
    // Tracks
    _tracksView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 250, self.view.frame.size.width, 150)];
    _tracksView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
    _tracksView.showsHorizontalScrollIndicator = NO;
    _tracksView.contentSize = CGSizeMake(self.view.frame.size.width, _tracksView.bounds.size.height);
    [_previewView addSubview:_tracksView];
    
    // Action sheet
    _saveSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete draft" otherButtonTitles:@"Save draft", nil];
    
    if (self.draft.restored) {
        [self restoreDraft];
    }
}


- (void)restoreDraft
{
    NSLog(@"Tracks: %@", self.draft.tracks);
    for (NSUInteger i = 0; i < [self.draft.tracks count]; i++) {
        NSLog(@"restored track: %@", self.draft.tracks[i]);
        [self addSceneWithPath:self.draft.tracks[i] atIndex:(i + 1)];
    }
    NSLog(@"Tracks after restore: %@", self.draft.tracks);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // iOS 6 support
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    [self _resetCapture];
    [[PBJVision sharedInstance] startPreview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[PBJVision sharedInstance] stopPreview];
    
    // iOS 6 support
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - private start/stop helper methods

- (void)_startCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [self _displayRecording:TRUE];
    [self beginMotionTracking];
    [[PBJVision sharedInstance] setCameraMode:PBJCameraModeVideo];
    [[PBJVision sharedInstance] startVideoCapture];
}

- (void)_pauseCapture
{
    [self _displayRecording:FALSE];
    [[PBJVision sharedInstance] pauseVideoCapture];
    _effectsViewController.view.hidden = !_onionButton.selected;
}

- (void)_resumeCapture
{
    [UIView transitionWithView:_captureButton
                      duration:.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ _captureButton.selected = YES; }
                    completion:nil];

    
    [[PBJVision sharedInstance] resumeVideoCapture];
    _effectsViewController.view.hidden = YES;
}

- (void)_endCapture
{
    [self _displayRecording:FALSE];
    [self endMotionTracking];
    [self.draft.motionDeltas addObject:[NSNumber numberWithDouble:_motionDelta]];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[PBJVision sharedInstance] endVideoCapture];
    _effectsViewController.view.hidden = YES;
}

- (void)_resetCapture
{
    [[Client sharedClient] getUploadUrl];
//    [_strobeView stop];
    _longPressGestureRecognizer.enabled = YES;

    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;

    if ([vision isCameraDeviceAvailable:PBJCameraDeviceBack]) {
        [vision setCameraDevice:PBJCameraDeviceBack];
        _flipButton.hidden = NO;
        _focusButton.hidden = NO;
    } else {
        [vision setCameraDevice:PBJCameraDeviceFront];
        _flipButton.hidden = YES;
        _focusButton.hidden = YES;
    }

    [vision setCameraMode:PBJCameraModeVideo];
    [vision setCameraOrientation:PBJCameraOrientationPortrait];
    [vision setFocusMode:PBJFocusModeContinuousAutoFocus];
    [vision setOutputFormat:PBJOutputFormatFullscreen];
    [vision setVideoRenderingEnabled:YES];
}

#pragma mark - UIButton

- (void)_handleFlipButton:(UIButton *)button
{
    PBJVision *vision = [PBJVision sharedInstance];
    if (vision.cameraDevice == PBJCameraDeviceBack) {
        _focusButton.hidden = YES;
        [vision setCameraDevice:PBJCameraDeviceFront];
    } else {
        _focusButton.hidden = NO;
        [vision setCameraDevice:PBJCameraDeviceBack];
    }
}

- (void)_handleFocusButton:(UIButton *)button
{
    _focusButton.selected = !_focusButton.selected;
    
    if (_focusButton.selected) {
        _tapGestureRecognizer.enabled = YES;
        _gestureView.hidden = YES;

    } else {
        if (_focusView && [_focusView superview]) {
            [_focusView stopAnimation];
        }
        _tapGestureRecognizer.enabled = NO;
        _gestureView.hidden = NO;
    }
    
    [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _captureButton.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _captureButton.alpha = 1;
        } completion:^(BOOL finished1) {
        }];
    }];
}

- (void)_handleDoneButton:(UIButton *)button
{
    #if TARGET_IPHONE_SIMULATOR
        AddPostViewController *addPostViewController = [[AddPostViewController alloc] initWithVideoPath:@"http://fomo-app.appspot.com/media/AMIfv976SCe-w9WNcTopJL9mnWt1842L6sJkWlMsAOLDlBg9gIgD5l5K_Gv1QT5DOBs1UotZaWNrnGYzx1kRsNLaiIrdFY_JNpYJsNFOsXESdd-W0bxGCZyylVWJqvY-1MNrhi3YwOpGzbp1z9ZUqyEpocWlh6jPaw"];
        [self addChildViewController:addPostViewController];
        [self.navigationController pushViewController:addPostViewController animated:NO];
    #else
        [self _composeVideo];
    #endif
}

- (void)_composeVideo
{
    // Build composition
    AVMutableComposition * composition = [AVMutableComposition composition];
    CMTime current = kCMTimeZero;
    NSError *compositionError = nil;
    AVURLAsset * asset = nil;
    BOOL result = YES;
    
    AVMutableComposition  * mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *compsitionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                  preferredTrackID:kCMPersistentTrackID_Invalid];
    
    for (int i = 0; i < [self.draft.tracks count]; i++) {
        NSString *videoPath = self.draft.tracks[i];
        asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
        
        
        
//        result = result && [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
//                                                          ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] lastObject]
//                                                           atTime:kCMTimeZero
//                                                            error:&compositionError];
//        
//        
//        result = result && [compsitionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
//                                                                ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] lastObject]
//                                                                 atTime:kCMTimeZero
//                                                                  error:&compositionError];
//        
//        double scale = MIN(MAX([self.motionDeltas[i] doubleValue]/10, 1), 4);
//        NSLog(@"Scale: %f", scale);
//        [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(current,
//                                                              CMTimeMakeWithSeconds(CMTimeGetSeconds(current) + CMTimeGetSeconds([asset duration]), current.timescale))
//                                   toDuration:CMTimeMake([asset duration].value * scale, [asset duration].timescale)];
//        [compsitionAudioTrack scaleTimeRange:CMTimeRangeMake(current,
//                                                              CMTimeMakeWithSeconds(CMTimeGetSeconds(current) + CMTimeGetSeconds([asset duration]), current.timescale))
//                                   toDuration:CMTimeMake([asset duration].value * scale, [asset duration].timescale)];
//    
        
        result = result && [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                                           ofAsset:asset
                                            atTime:current
                                             error:&compositionError];
        
        
        if(!result) {
            if(compositionError) {
                // manage the composition error case
            }
        } else {
            current = CMTimeAdd(current, CMTimeMake([asset duration].value, [asset duration].timescale));
            [self.draft.timeline addObject:[NSNumber numberWithFloat:CMTimeGetSeconds(current)]];
        }
    }

//    AddPostViewController *addPostViewController = [[AddPostViewController alloc] initWithAsset:composition
//                                                                                  andExportPath:self.draft.outputPath
//                                                                                    andTimeline:self.draft.timeline];
    AddPostViewController *addPostViewController = [[AddPostViewController alloc] initWithAsset:composition
                                                                                       andDraft:self.draft];
    [self.navigationController pushViewController:addPostViewController animated:NO];
}


- (void)_handleCloseButton:(UIButton *)button
{
    [_saveSheet showInView:self.view];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self _resetCapture];
}

#pragma mark - UIGestureRecognizer

- (void)_handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
      case UIGestureRecognizerStateBegan:
        {
            [self _startCapture];
            break;
        }
      case UIGestureRecognizerStateEnded:
      case UIGestureRecognizerStateCancelled:
      case UIGestureRecognizerStateFailed:
        {
            [self _endCapture];
            break;
        }
      default:
        break;
    }
}

- (void)_handleFocusTapGesterRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:_previewView];

    // auto focus is occuring, display focus view
    CGPoint point = tapPoint;
    
    CGRect focusFrame = _focusView.frame;
#if defined(__LP64__) && __LP64__
    focusFrame.origin.x = rint(point.x - (focusFrame.size.width * 0.5));
    focusFrame.origin.y = rint(point.y - (focusFrame.size.height * 0.5));
#else
    focusFrame.origin.x = rintf(point.x - (focusFrame.size.width * 0.5f));
    focusFrame.origin.y = rintf(point.y - (focusFrame.size.height * 0.5f));
#endif
    [_focusView setFrame:focusFrame];
    
    [_previewView addSubview:_focusView];
    [_focusView startAnimation];

    CGPoint adjustPoint = [PBJVisionUtilities convertToPointOfInterestFromViewCoordinates:tapPoint inFrame:_previewView.frame];
    [[PBJVision sharedInstance] focusAtAdjustedPoint:adjustPoint];
}

- (void)_displayRecording:(BOOL)recording
{
    if (recording) {
        [UIView transitionWithView:_captureButton
                          duration:.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{ _captureButton.selected = YES; }
                        completion:nil];
    } else {
        [UIView transitionWithView:_captureButton
                          duration:.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{ _captureButton.selected = NO; }
                        completion:nil];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2) {
        return;
    }

    if (buttonIndex == 0) {
        [self.draft clear];
        self.draft = [Draft getDraft];
        for (UIView *view in _tracksView.subviews) {
            [view removeFromSuperview];
        }
        [self _resetCapture];
    } else if (buttonIndex == 1) {
        [self.draft save];
    }

    CATransition *transition = [CATransition animation];
    transition.duration = 0.35;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - PBJVisionDelegate

- (void)visionSessionWillStart:(PBJVision *)vision
{
}

- (void)visionSessionDidStart:(PBJVision *)vision
{
    if (![_previewView superview]) {
        [self.view addSubview:_previewView];
        [self.view bringSubviewToFront:_gestureView];
    }
}

- (void)visionSessionDidStop:(PBJVision *)vision
{
    [_previewView removeFromSuperview];
}

- (void)visionModeWillChange:(PBJVision *)vision
{
}

- (void)visionModeDidChange:(PBJVision *)vision
{
}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture
{
}

- (void)visionWillStartFocus:(PBJVision *)vision
{
}

- (void)visionDidStopFocus:(PBJVision *)vision
{
    if (_focusView && [_focusView superview]) {
        [_focusView stopAnimation];
    }
}

// photo

- (void)visionWillCapturePhoto:(PBJVision *)vision
{
}

- (void)visionDidCapturePhoto:(PBJVision *)vision
{
}

- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error
{
    if (error)
        return;
    
    _currentPhoto = photoDict;
    
    NSData *photoData = [_currentPhoto objectForKey:PBJVisionPhotoJPEGKey];
    NSDictionary *metadata = [_currentPhoto objectForKey:PBJVisionPhotoMetadataKey];
    
    // ALAssetsLibrary
    [_assetLibrary writeImageDataToSavedPhotosAlbum:photoData metadata:metadata completionBlock:nil];
}

// video capture

- (void)visionDidStartVideoCapture:(PBJVision *)vision
{
//    [_strobeView start];
    _recording = YES;
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision
{
//    [_strobeView stop];
}

- (void)visionDidResumeVideoCapture:(PBJVision *)vision
{
//    [_strobeView start];
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    _recording = NO;

    if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }

    _currentVideo = videoDict;
    
    NSString *videoPath = [_currentVideo objectForKey:PBJVisionVideoPathKey];
    NSLog(@"before add tracks: %@", self.draft.tracks);
    [self.draft.tracks addObject:videoPath];
    NSLog(@"tracks: %@", self.draft.tracks);
    [self addSceneWithPath:videoPath atIndex:[self.draft.tracks count]];
}

- (void)addSceneWithPath:(NSString *)videoPath atIndex:(NSUInteger)index
{
    NSLog(@"At index: %d", index);
    SceneViewController *videoPlayerController;
    videoPlayerController = [[SceneViewController alloc] initWithDownloadPath:videoPath];
    videoPlayerController.view.frame = CGRectMake(4 + 84*(index - 1), 4, 80, 142);
    [self addChildViewController:videoPlayerController];
    [_tracksView addSubview:videoPlayerController.view];
    _tracksView.contentSize = CGSizeMake(MAX(self.view.frame.size.width + 1, 4 + 84*index), _tracksView.bounds.size.height);
    [videoPlayerController didMoveToParentViewController:self];
    [videoPlayerController setVideoPath:videoPath];
}

// progress

- (void)visionDidCaptureAudioSample:(PBJVision *)vision
{
//    NSLog(@"captured audio (%f) seconds", vision.capturedAudioSeconds);
}

- (void)visionDidCaptureVideoSample:(PBJVision *)vision
{
//    NSLog(@"captured video (%f) seconds", vision.capturedVideoSeconds);
}

- (NSArray *)_metadataArray
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    // device model
    AVMutableMetadataItem *modelItem = [[AVMutableMetadataItem alloc] init];
    [modelItem setKeySpace:AVMetadataKeySpaceCommon];
    [modelItem setKey:AVMetadataCommonKeyModel];
    [modelItem setValue:[currentDevice localizedModel]];
    
    // software
    AVMutableMetadataItem *softwareItem = [[AVMutableMetadataItem alloc] init];
    [softwareItem setKeySpace:AVMetadataKeySpaceCommon];
    [softwareItem setKey:AVMetadataCommonKeySoftware];
    [softwareItem setValue:[NSString stringWithFormat:@"%@ %@ FOMO APP", [currentDevice systemName], [currentDevice systemVersion]]];
    
    // creation date
    AVMutableMetadataItem *creationDateItem = [[AVMutableMetadataItem alloc] init];
    [creationDateItem setKeySpace:AVMetadataKeySpaceCommon];
    [creationDateItem setKey:AVMetadataCommonKeyCreationDate];
    [creationDateItem setValue:[NSString PBJformattedTimestampStringFromDate:[NSDate date]]];
    
    return @[modelItem, softwareItem, creationDateItem];
}

#pragma mark - motion

+ (CMMotionManager*)sharedMotionManager {
    if (!sharedMotionManager) {
        sharedMotionManager = [[CMMotionManager alloc] init];
    }
    return sharedMotionManager;
}

+ (void)setSharedMotionManager:(CMMotionManager*)motionManager {
    sharedMotionManager = motionManager;
}

- (void)beginMotionTracking {

    _lastPitch = 0;
    _lastRoll = 0;
    _lastYaw = 0;
    _pitchDelta = 0;
    _rollDelta = 0;
    _yawDelta = 0;
    _motionDelta = 0;
    
    CMMotionManager *motionManager = [self.class sharedMotionManager];
    if (motionManager.deviceMotionAvailable) {
        [motionManager
         startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
         withHandler: ^(CMDeviceMotion *motion, NSError *error) {
             
             _pitchDelta += fabs(_lastPitch - motion.attitude.pitch) < 500 ? fabs(_lastPitch - motion.attitude.pitch) : 0;
             _rollDelta += fabs(_lastRoll - motion.attitude.roll) < 500 ? fabs(_lastRoll - motion.attitude.roll) : 0;
             _yawDelta += fabs(_lastYaw - motion.attitude.yaw) < 500 ? fabs(_lastYaw - motion.attitude.yaw) : 0;
             
             _lastPitch = motion.attitude.pitch;
             _lastRoll = motion.attitude.roll;
             _lastYaw = motion.attitude.yaw;
         }];
    }
}

- (void)endMotionTracking {
    CMMotionManager *motionManager = [self.class sharedMotionManager];
    if ([motionManager isDeviceMotionActive] == YES) {
        _motionDelta = _pitchDelta + _rollDelta + _yawDelta;
        NSLog(@"Motion delta: %f", _motionDelta);
        [motionManager stopDeviceMotionUpdates];
    }
}

#pragma mark - App NSNotifications

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"app resign active");
    [self.draft save];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"app will terminate");
    [self.draft save];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"app will terminate");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"app did become active");
    [self.draft save];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"app entered background");
    [self.draft save];
}



@end
