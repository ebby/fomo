//
//  SearchViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/27/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "SearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CategoryCell.h"

@implementation UITableViewCell (Category)

-(void)layoutSubViews
{
    [super layoutSubviews];
    self.imageView.bounds = CGRectMake(23, 23, 24, 24);
    self.imageView.frame = CGRectMake(23, 23, 24, 24);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

@end

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSDictionary *categoryImages;

@end

@implementation SearchViewController {
    UITextField *_searchInput;
    UIView *_searchBar;
    UIButton *_closeButton;
    UITableView *_resultsTable;
}

- (id)init {
    self = [super init];
    if (self) {
        self.categories = @[@"Popular", @"Food", @"Nightlife", @"Coffee", @"Shopping", @"Sights", @"Outdoors", @"Arts"];
        self.categoryImages = @{@"Popular":@"star",
                                @"Food": @"burger",
                                @"Nightlife":@"nightlife",
                                @"Coffee":@"coffee",
                                @"Shopping":@"shopping",
                                @"Sights":@"sights",
                                @"Outdoors":@"outdoors",
                                @"Arts":@"arts"};
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
	// Do any additional setup after loading the view.
    
    _searchBar = [[UIView alloc] initWithFrame:CGRectMake(50, 20, self.view.frame.size.width-65, 36)];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 34.0f, _searchBar.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f].CGColor;
    [_searchBar.layer addSublayer:bottomBorder];
    [self.view addSubview:_searchBar];
    
    _searchInput = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-65, 36)];
    _searchInput.textColor = [UIColor whiteColor];
    _searchInput.placeholder = @"Search nearby";
    [_searchInput setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:20]];
    [_searchBar addSubview:_searchInput];
    
    // close button
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(6, 17.0f, 40.0f, 40.0f)];
    _closeButton.alpha = 0.8;
    UIImage *closeButtonImage = [UIImage imageNamed:@"close"];
    [_closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(_handleCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    
    // Results table
    _resultsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 55, self.view.frame.size.width, self.view.frame.size.height - 55)];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    _resultsTable.scrollEnabled = NO;
    _resultsTable.tableHeaderView = headerView;
    _resultsTable.backgroundColor = [UIColor clearColor];
   // _resultsTable.delegate = self;
    _resultsTable.dataSource = self;
    _resultsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_resultsTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_handleCloseButton:(UIButton *)button
{
    [_searchInput resignFirstResponder];
    [self hide];
}

- (void)show {
    [super show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *categoryTableCellId = @"CategoryTableCell";
    
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:categoryTableCellId];
    
    if (cell == nil) {
        cell = [[CategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:categoryTableCellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        [cell.textLabel setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:24]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [self.categories objectAtIndex:indexPath.row];
    [cell.imageView setImage:[UIImage imageNamed:[self.categoryImages objectForKey:cell.textLabel.text]]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

@end
