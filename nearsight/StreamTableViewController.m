//
//  StreamViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "StreamTableViewController.h"
#import "PostViewController.h"
#import "Client.h"
#import "Post.h"
#import "PostCell.h"
#import "DualPostCell.h"
#import <TSMessages/TSMessage.h>

@interface StreamTableViewController ()


@property (nonatomic, strong, readwrite) NSMutableArray *posts;
@property (nonatomic, strong, readwrite) NSMutableArray *postViews;
@property (nonatomic, strong, readwrite) NSMutableDictionary *cachedCells;
@property (nonatomic, strong, readwrite) NSDate *lastFetch;
@property (nonatomic, strong, readwrite) PostCell *prevCell;
@property (nonatomic, strong, readwrite) PostCell *currentCell;
@property (nonatomic, readwrite) NSUInteger index;
@property (nonatomic, strong, readwrite) PostCell *nextCell;
@property (nonatomic, readwrite) BOOL finished;

@end

@implementation StreamTableViewController

- (id)initForProfile
{
    self = [super init];
    if (self) {
        self.profile = YES;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.view.backgroundColor = [UIColor blackColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.pagingEnabled = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateStream) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadStream
{
    self.posts = [[NSMutableArray alloc] init];
    
    [[[[[Client sharedClient] fetchStreamForProfile:self.profile]
       doNext:^(NSMutableArray *posts) {
           self.posts = posts;
           [self.tableView reloadData];
           self.lastFetch = [NSDate date];
       }]
      // Now the assignment will be done on the main thread.
      deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh]]
     subscribeError:^(NSError *error) {
         [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching the stream: " type:TSMessageNotificationTypeError];
     }];
}

- (void)updateStream
{
    [[[[[Client sharedClient] updateStream:self.lastFetch forProfile:self.profile]
       doNext:^(NSMutableArray *posts) {
           [posts addObjectsFromArray:self.posts];
           self.posts = posts;
           [self.tableView reloadData];
           [self.refreshControl endRefreshing];
           self.lastFetch = [NSDate date];
       }]
      // Now the assignment will be done on the main thread.
      deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh]]
     subscribeError:^(NSError *error) {
         [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching the stream: " type:TSMessageNotificationTypeError];
     }];
}

- (void)loadMore
{
    NSDate* lastPost = ((Post *)[self.posts lastObject]).added;
    NSLog(@"last post: %@", lastPost);
    [[[[[Client sharedClient] loadMoreStream:lastPost forProfile:self.profile]
        doNext:^(NSMutableArray *posts) {
            if ([posts count]) {
                [self.posts addObjectsFromArray:posts];
                [self.tableView reloadData];
            } else {
                self.finished = YES;
                [self.tableView reloadData];
            }
       }]
      // Now the assignment will be done on the main thread.
      deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]]
     subscribeError:^(NSError *error) {
         [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching the stream: " type:TSMessageNotificationTypeError];
     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger count = [self.posts count];
    if (!self.finished && count > 0) {
        // Add 1 for loading more cell
        count++;
    }
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL forward = self.index < [indexPath indexAtPosition:[indexPath length] - 1];
    self.index = [indexPath indexAtPosition:[indexPath length] - 1];
    if (self.index < [self.posts count]) {
        static NSString *streamTableCellId = @"StreamTableCell";
        
        if (self.nextCell) {
            self.prevCell = self.currentCell;
            self.currentCell = self.nextCell;
        }

        if (!self.currentCell) { // First cell
            self.currentCell = [tableView dequeueReusableCellWithIdentifier:streamTableCellId];
            
            if (self.currentCell == nil) {
                self.currentCell = [[PostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:streamTableCellId andPost:self.posts[self.index]];
                [self addChildViewController:self.currentCell.postView];
            } else {
                [self.currentCell setPost:self.posts[self.index]];
            }
        }
        
        
        // Next cell
        if (self.index < [self.posts count] - 1) {
            self.nextCell = [tableView dequeueReusableCellWithIdentifier:streamTableCellId];
            if (self.nextCell == nil) {
                self.nextCell = [[PostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:streamTableCellId andPost:self.posts[self.index + 1]];
                [self addChildViewController:self.nextCell.postView];
            } else {
                [self.nextCell setPost:self.posts[self.index + 1]];
            }
        } else {
            self.nextCell = nil;
        }
        

        if (!self.finished && self.index == [self.posts count] - 1) {
            [self loadMore];
        }
        //self.currentCell = cell;
        
        return self.currentCell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
        loadingLabel.text = @"Loading More";
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:loadingLabel];
        self.currentCell = nil;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [indexPath indexAtPosition:[indexPath length] - 1];
    if (index < [self.posts count]) {
        PostCell *postCell = (PostCell *)cell;
        [postCell.postView stop];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Determine cell height based on screen
    NSUInteger index = [indexPath indexAtPosition:[indexPath length] - 1];
    if (index < [self.posts count]) {
        return CGRectGetHeight(self.view.frame);
    } else {
        return 44;
    }
}

//- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    if (self.currentCell) {
//        [self.currentCell.postView play];
//    }
//}

//- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    if (self.currentCell) {
//        [self.currentCell.postView stop];
//    }
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - App NSNotifications

- (void)_applicationWillResignActive:(NSNotification *)aNotfication
{
    
}

- (void)_applicationWillEnterForeground:(NSNotification *)aNotfication
{

}

- (void)_applicationDidEnterBackground:(NSNotification *)aNotfication
{
   
}

@end
