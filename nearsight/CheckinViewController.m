//
//  CheckinViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/31/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "CheckinViewController.h"

@interface CheckinViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *places;

@end

@implementation CheckinViewController {
    UITableView *_tableView;
    UIView *_searchBar;
    UITextField *_searchInput;
    UIButton *_closeButton;
    UILabel *_title;
}

- (id) initWithPlaces:(NSArray *)places
{
    self = [super init];
    if (self) {
        self.places = places;
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
    
    // Title
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    _title.textColor = [UIColor whiteColor];
    _title.text = @"Where are you?";
    _title.textAlignment = NSTextAlignmentCenter;
    [_title setFont:[UIFont fontWithName:@"MrsEaves-Italic" size:28]];
    [self.view addSubview:_title];
    
    // close button
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(6, 17.0f, 40.0f, 40.0f)];
    _closeButton.alpha = 0.8;
    UIImage *closeButtonImage = [UIImage imageNamed:@"close"];
    [_closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(_handleCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    
    _searchBar = [[UIView alloc] initWithFrame:CGRectMake(35, 70, self.view.frame.size.width-65, 36)];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(15.0f, 34.0f, _searchBar.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f].CGColor;
    [_searchBar.layer addSublayer:bottomBorder];
    [self.view addSubview:_searchBar];
    
    _searchInput = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width-65, 36)];
    _searchInput.textColor = [UIColor whiteColor];
    _searchInput.keyboardAppearance = UIKeyboardAppearanceDark;
    UIColor *color = [UIColor colorWithWhite:1.0f alpha:0.8f];
    _searchInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{NSForegroundColorAttributeName: color}];
    [_searchInput setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:18]];
    [_searchBar addSubview:_searchInput];
    
    // Table
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(35, 105, self.view.frame.size.width - 35, self.view.frame.size.height - 105)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.contentInset = UIEdgeInsetsMake(15, 35, 15, 0);
    _tableView.contentSize = CGSizeMake(_tableView.frame.size.width, _tableView.contentSize.height-30);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];

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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    NSLog(@"Target: %@", [touch view]);
    if ([_searchInput isFirstResponder] && [touch view] != _searchInput) {
        [_searchInput resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:placeTableCellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:placeTableCellId];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        [cell.textLabel setFont:[UIFont fontWithName:@"ProximaNovaCond-Regular" size:18]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = ((Place *)[self.places objectAtIndex:indexPath.row]).name;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_searchInput resignFirstResponder];
    [self.delegate checkInViewPlaceSelected:((Place *)[self.places objectAtIndex:indexPath.row])];
    [self hide];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 100;
//}



@end
