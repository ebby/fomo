//
//  PlaceViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/28/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "PlaceViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "UIExtensions.h"
#import "StreamTableViewController.h"

@interface PlaceViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) StreamTableViewController *reviewStream;

@end

@implementation PlaceViewController {
    ExtendedHitButton *_backButton;
    UILabel *_title;
    UIScrollView *_scrollView;
    UIView *_info;
    UILabel *_name;
    UILabel *_category;
    UILabel *_address;
    
    UILabel *_hours;
    UIButton *_todaysHours;
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
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIView *streamHolder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    //streamHolder.clipsToBounds = YES;
    [self.view addSubview:streamHolder];
    
    // Review stream
    self.reviewStream = [[StreamTableViewController alloc] init];
    self.reviewStream.view.frame = CGRectMake(0, -150, self.view.frame.size.width, self.view.frame.size.height);
    [streamHolder addSubview:self.reviewStream.view];
    [self addChildViewController:self.reviewStream];
    [self.reviewStream loadStream];

    
    // Scroll View
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height + 20)];
    _scrollView.bounces = YES;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.delegate = self;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_scrollView];
    
    
    
    
    
    UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20.0f)];
    statusBar.backgroundColor = [UIColor blackColor];
    statusBar.alpha = 0.3;
    [self.view addSubview:statusBar];
    

    // Title
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    [_title setFont:[UIFont fontWithName:@"MrsEaves-Italic" size:22]];
    _title.textColor = [UIColor whiteColor];
    _title.alpha = 0.8;
    NSShadow* shadow = [[NSShadow alloc] init];
    //shadow.shadowColor = [UIColor blackColor];
    //shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"Glasslands Gallery"];
    NSRange range = NSMakeRange(0, [attributedTitle length]);
    [attributedTitle addAttribute:NSShadowAttributeName value:shadow range:range];
    _title.attributedText = attributedTitle;
    _title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_title];

    // Back button
    _backButton = [ExtendedHitButton extendedHitButton];
    _backButton.frame = CGRectMake(5.0f, 15.0f, 50.0f, 50.0f);
    _backButton.alpha = 0.8;
    UIImage *backButtonImage = [UIImage imageNamed:@"back"];
    [_backButton setImage:backButtonImage forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(_handleBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    // Info view
    _info = [[UIView alloc] initWithFrame:CGRectMake(0, 300, self.view.frame.size.width, self.view.frame.size.height)];
    _info.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:_info];
    
    // Name
    _name = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, self.view.frame.size.width, 40)];
    [_name setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:22]];
    _name.text = @"Glasslands Gallery";
    [_info addSubview:_name];
    
    // Category
    _category = [[UILabel alloc] initWithFrame:CGRectMake(20, 27, self.view.frame.size.width, 40)];
    [_category setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:14]];
    _category.text = @"Music Venue, Rock Club, Bar";
    [_info addSubview:_category];

    // Address
    _address = [[UILabel alloc] initWithFrame:CGRectMake(20, 47, self.view.frame.size.width, 40)];
    [_address setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:14]];
    _address.text = @"289 Kent St, Brooklyn, New York 11211";
    [_info addSubview:_address];
    
    // Map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:15];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectMake(20, 80, self.view.frame.size.width-40, 100) camera:camera];
    mapView.layer.cornerRadius = 6;
    mapView.clipsToBounds = YES;
    mapView.settings.scrollGestures = NO;
    mapView.settings.zoomGestures = NO;
    mapView.settings.tiltGestures = NO;
    mapView.settings.rotateGestures = NO;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.snippet = @"Hello World";
    
    // Implement GMSTileURLConstructor
    // Returns a Tile based on the x,y,zoom coordinates, and the requested floor
//    GMSTileURLConstructor urls = ^(NSUInteger x, NSUInteger y, NSUInteger zoom) {
//        NSString *url = [NSString stringWithFormat:@"https://stamen-tiles-a.a.ssl.fastly.net/toner/%d/%d/%d.png", zoom, x, y];
//        return [NSURL URLWithString:url];
//    };
//
//    // Create the GMSTileLayer
//    GMSURLTileLayer *layer = [GMSURLTileLayer tileLayerWithURLConstructor:urls];
//    layer.fadeIn = YES;
//    // Display on the map at a specific zIndex
//    layer.zIndex = 100;
//    layer.map = mapView;
    
    [_info addSubview:mapView];
    
    // Hours
    _hours = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, self.view.frame.size.width, 20)];
    [_hours setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:10]];
    _hours.text = @"HOURS";
    _hours.textColor = [UIColor colorWithRed:127.0f/255 green:140.0f/255 blue:141.0f/255 alpha:1.0];
    [_info addSubview:_hours];
    
    _todaysHours = [[UIButton alloc] initWithFrame:CGRectMake(-1, 220, self.view.frame.size.width+2, 40)];
    _todaysHours.layer.borderWidth = 1.0f;
    _todaysHours.layer.borderColor = [[UIColor colorWithRed:236.0f/255 green:240.0f/255 blue:241.0f/255 alpha:1.0] CGColor];
    [_todaysHours.titleLabel setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:14]];
    [_todaysHours setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_todaysHours setTitle:@"Closed Today" forState:UIControlStateNormal];
    _todaysHours.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _todaysHours.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    [_info addSubview:_todaysHours];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)_handleBackButton:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _scrollView){
        
        self.reviewStream.view.frame = CGRectMake(self.reviewStream.view.frame.origin.x, -150 - scrollView.contentOffset.y*.75, self.reviewStream.view.frame.size.width, MAX(self.view.frame.size.height - scrollView.contentOffset.y, self.view.frame.size.height));
        
        return;
    }
    
//    if (pageControlIsChangingPage) {
//        return;
//    }
//    CGFloat pageWidth = imagesScrollView.frame.size.width;
//    NSUInteger page = floor((imagesScrollView.contentOffset.x - pageWidth / 2.0f) / pageWidth) + 1;
//    self.pageControl.currentPage = page;
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView {
//    pageControlIsChangingPage = NO;
//}



@end
