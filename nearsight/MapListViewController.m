//
//  MapListViewController.m
//  nearsight
//
//  Created by Ebby Amir on 4/2/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "MapListViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "PlaceViewController.h"
#import "PlaceCell.h"
#import "Manager.h"
#import "UIExtensions.h"
#import <MapKit/MapKit.h>

#define METERS_PER_MILE 1609.344

@interface MapListViewController () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation MapListViewController {
    UIScrollView *_scrollView;
//    GMSMapView *_mapView;
    MKMapView * _mapView;
    UITableView *_placesTable;
    BOOL _firstLocationUpdate;
    ExtendedHitButton *_closeButton;
    UILabel *_title;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.view.backgroundColor = [UIColor blackColor];

    // Map
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[Manager sharedClient].currentLocation.coordinate.latitude - 1
                                                            longitude:[Manager sharedClient].currentLocation.coordinate.longitude
                                                                 zoom:12];
//    _mapView = [GMSMapView mapWithFrame:CGRectMake(0, -250, self.view.frame.size.width, self.view.frame.size.height + 500) camera:camera];
//    _mapView.settings.scrollGestures = NO;
//    _mapView.settings.zoomGestures = NO;
//    _mapView.settings.tiltGestures = NO;
//    _mapView.settings.rotateGestures = NO;
//    _mapView.myLocationEnabled = YES;
//    // Listen to the myLocation property of GMSMapView.
//    [_mapView addObserver:self
//               forKeyPath:@"myLocation"
//                  options:NSKeyValueObservingOptionNew
//                  context:NULL];
//    [self.view addSubview:_mapView];
    
    
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, -250, self.view.frame.size.width, self.view.frame.size.height + 500)];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [Manager sharedClient].currentLocation.coordinate.latitude - 1;
    zoomLocation.longitude= [Manager sharedClient].currentLocation.coordinate.longitude;
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.3*METERS_PER_MILE, 0.3*METERS_PER_MILE);
    [_mapView setRegion:viewRegion animated:YES];
    [self.view addSubview:_mapView];
    
//    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:@"examples.map-zswgei2n"];
//    
//    _mapView = [[RMMapView alloc] initWithFrame:CGRectMake(0, -500, self.view.frame.size.width, self.view.frame.size.height + 1000) andTilesource:tileSource];
//    _mapView.zoom = 13;
//    _mapView.userTrackingMode = RMUserTrackingModeFollow;
//    //_mapView.centerCoordinate = [Manager sharedClient].currentLocation.coordinate;
//    [self.view addSubview:_mapView];
    
    
    // Scroll View
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 200)];
    _scrollView.bounces = YES;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.delegate = self;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+200);
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_scrollView];
    
    UIView *statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70.0f)];
    statusBar.userInteractionEnabled = NO;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, statusBar.frame.size.width, 70);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:30/255.0f green:30/255.0f blue:30/255.0f alpha:1] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [statusBar.layer insertSublayer:gradient atIndex:0];
    statusBar.alpha = 0.8;
    [self.view addSubview:statusBar];
    
    // Close button
    _closeButton = [ExtendedHitButton extendedHitButton];
    _closeButton.frame = CGRectMake(6, 17.0f, 40.0f, 40.0f);
    _closeButton.alpha = 0.8;
    UIImage *closeButtonImage = [UIImage imageNamed:@"close"];
    [_closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(_handleCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    
    // Title
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    _title.textColor = [UIColor whiteColor];
    _title.text = @"trending nearby";
    _title.textAlignment = NSTextAlignmentCenter;
    [_title setFont:[UIFont fontWithName:@"MrsEaves-Italic" size:28]];
    [self.view addSubview:_title];
    
    // Results table
    _placesTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.height)];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    _placesTable.scrollEnabled = NO;
    _placesTable.alpha = .95f;
    //_placesTable.tableHeaderView = headerView;
    _placesTable.contentInset = UIEdgeInsetsZero;
    _placesTable.backgroundColor = [UIColor colorWithRed:30/255.0f green:30/255.0f blue:30/255.0f alpha:1];
    _placesTable.delegate = self;
    _placesTable.dataSource = self;
    _placesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_scrollView addSubview:_placesTable];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //_mapView.settings.myLocationButton = YES;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_handleCloseButton:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadPlaces:(NSArray *)places
{
    self.places = places;
    [_placesTable reloadData];
    
    for (Place *place in places) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = place.location;
        marker.snippet = place.name;
    }
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!_firstLocationUpdate) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        _firstLocationUpdate = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 0.3*METERS_PER_MILE, 0.3*METERS_PER_MILE);
        [_mapView setRegion:viewRegion animated:YES];
        
//        _mapView.camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude - .04
//                                                      longitude:location.coordinate.longitude
//                                                         zoom:_mapView.camera.zoom];
    }
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _scrollView){
        _mapView.frame = CGRectMake(_mapView.frame.origin.x, MAX(-250 - scrollView.contentOffset.y*.75, -500), _mapView.frame.size.width, MAX(self.view.frame.size.height - scrollView.contentOffset.y, self.view.frame.size.height + 500));
    }
//    _placesTable.userInteractionEnabled = scrollView.contentOffset.y >= 200;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *placeTableCellId = @"PlaceTableCell";
    
    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:placeTableCellId];
    
    if (cell == nil) {
        cell = [[PlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:placeTableCellId];
        cell.backgroundColor = [UIColor colorWithRed:30/255.0f green:30/255.0f blue:30/255.0f alpha:1];
        cell.textLabel.textColor = [UIColor whiteColor];
        [cell.textLabel setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:24]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    Place *place = (Place *)[self.places objectAtIndex:indexPath.row];
    cell.textLabel.text = place.name;
    NSURL *url = [NSURL URLWithString:place.picture];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    [cell.imageView setImage:img];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceViewController *placeViewController = [[PlaceViewController alloc] init];
    [self.navigationController pushViewController:placeViewController animated:YES];
}

@end
