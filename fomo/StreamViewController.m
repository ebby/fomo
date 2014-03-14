//
//  StreamViewController.m
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "StreamViewController.h"
#import "PostViewController.h"
#import "Client.h"
#import "Post.h"
#import "PostCell.h"
#import <TSMessages/TSMessage.h>

@interface StreamViewController ()

@property (nonatomic, strong, readwrite) NSMutableArray *posts;
@property (nonatomic, strong, readwrite) NSMutableDictionary *cachedCells;
@property (nonatomic, strong, readwrite) NSMutableArray *cells;
@property (nonatomic, strong, readwrite) NSDate *lastFetch;

@end

@implementation StreamViewController


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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.refreshControl addTarget:self action:@selector(updateStream) forControlEvents:UIControlEventValueChanged];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadStream
{
    self.cells = [[NSMutableArray alloc] init];
    self.posts = [[NSMutableArray alloc] init];
    
    [[[[[Client sharedClient] fetchStream]
       doNext:^(NSMutableArray *posts) {
           self.posts = posts;
           for (Post *post in posts) {
               PostCell *cell = [[PostCell alloc] initWithPost:post];
               [self addChildViewController:cell.postView];
               [self.cells addObject:cell];
           }
           [self.tableView reloadData];
           self.lastFetch = [NSDate date];
       }]
      // Now the assignment will be done on the main thread.
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeError:^(NSError *error) {
         [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching the stream: " type:TSMessageNotificationTypeError];
     }];
}

- (void)updateStream
{
    [[[[[Client sharedClient] updateStream:self.lastFetch]
       doNext:^(NSMutableArray *posts) {
           for (Post *post in posts) {
               PostCell *cell = [[PostCell alloc] initWithPost:post];
               [self addChildViewController:cell.postView];
               [self.cells addObject:cell];
               [self.cells insertObject:cell atIndex:0];
           }
           [posts addObjectsFromArray:self.posts];
           self.posts = posts;
           [self.tableView reloadData];
           [self.refreshControl endRefreshing];
       }]
      // Now the assignment will be done on the main thread.
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeError:^(NSError *error) {
         [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching the stream: " type:TSMessageNotificationTypeError];
     }];
}

- (void)loadMore
{
    NSDate* lastPost = ((Post *)[self.posts lastObject]).added;
    NSLog(@"last post: %@", lastPost);
    [[[[[Client sharedClient] loadMoreStream:lastPost]
        doNext:^(NSMutableArray *posts) {
            [self.posts addObjectsFromArray:posts];
            for (Post *post in posts) {
                PostCell *cell = [[PostCell alloc] initWithPost:post];
                [self addChildViewController:cell.postView];
                 [self.cells addObject:cell];
            }
            [self.tableView reloadData];
            self.lastFetch = [NSDate date];
       }]
      // Now the assignment will be done on the main thread.
      deliverOn:RACScheduler.mainThreadScheduler]
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
    if (count > 0) {
        // Add 1 for loading more cell
        count++;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [indexPath indexAtPosition:[indexPath length] - 1];
    if (index < [self.cells count]) {
        if (index == [self.cells count] - 1) {
            [self loadMore];
        }
        PostCell *cell = self.cells[index];
        [cell.postView play];
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
        loadingLabel.text = @"Loading More";
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:loadingLabel];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Determine cell height based on screen
    NSUInteger index = [indexPath indexAtPosition:[indexPath length] - 1];
    if (index < [self.cells count]) {
        return CGRectGetHeight(self.view.frame);
    } else {
        return 44;
    }
}

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

@end
