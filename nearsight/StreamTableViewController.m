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
#import "LoadingViewController.h"
#import <TSMessages/TSMessage.h>

#define LOAD_COUNT 6

@interface StreamTableViewController ()


@property (nonatomic, strong, readwrite) NSMutableArray *posts;
@property (nonatomic, strong, readwrite) NSMutableArray *postViews;
@property (nonatomic, strong, readwrite) NSMutableDictionary *cachedCells;
@property (nonatomic, strong, readwrite) NSMutableArray *cells;
@property (nonatomic, strong, readwrite) PostCell *currentCell;
@property (nonatomic, strong, readwrite) PostCell *lastCell;
@property (nonatomic, strong, readwrite) NSDate *lastFetch;
@property (nonatomic, readwrite) NSUInteger index;
@property (nonatomic, readwrite) NSUInteger loadIndex;
@property (nonatomic, readwrite) BOOL finished;
@property (nonatomic, readwrite) BOOL needsReload;
@property (nonatomic, readwrite) BOOL reload;
@property (nonatomic, readwrite) BOOL shouldPlay;

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
    
    self.loadIndex = 0;
    
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
    self.cells = [[NSMutableArray alloc] init];
    self.posts = [[NSMutableArray alloc] init];
    
    [[[[Client sharedClient] fetchStreamForProfile:self.profile]
       doNext:^(NSMutableArray *posts) {
           [[LoadingViewController sharedLoader] hide];
           self.posts = posts;
           for (int i = 0; i < LOAD_COUNT; i++) {
               if (self.loadIndex + i >= [self.posts count]) {
                   break;
               }
               PostCell *cell = [[PostCell alloc] initWithPost:self.posts[i]];
               [self addChildViewController:cell.postView];
               [self.cells addObject:cell];
           }
           self.loadIndex += LOAD_COUNT;
           [self.tableView reloadData];
           self.lastFetch = [NSDate date];
           
       }]
      // Now the assignment will be done on the main thread.
//      deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh]]
     subscribeError:^(NSError *error) {
         [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching the stream: " type:TSMessageNotificationTypeError];
     }];
}

- (void)updateStream
{
    [[[[[Client sharedClient] updateStream:self.lastFetch forProfile:self.profile]
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
           self.lastFetch = [NSDate date];
       }]
      // Now the assignment will be done on the main thread.
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeError:^(NSError *error) {
         [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching the stream: " type:TSMessageNotificationTypeError];
     }];
}

- (void)loadMore
{
    NSLog(@"load more");

    if (self.loadIndex < [self.posts count]) {
        for (int i = 0; i < LOAD_COUNT; i++) {
            if (self.loadIndex + i >= [self.posts count]) {
                break;
            }
            
            PostCell *cell = [[PostCell alloc] initWithPost:self.posts[self.loadIndex + i]];
            [self addChildViewController:cell.postView];
            [self.cells addObject:cell];
        }
        self.needsReload = YES;
//        [self.tableView reloadData];
//        NSLog(@"index: %d, and loadIndex: %d", self.index, self.loadIndex);
//        if (self.index == self.loadIndex - 1) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.index-1 inSection:0];
//            NSLog(@"should scroll");
//            [self.tableView scrollToRowAtIndexPath:indexPath
//                                  atScrollPosition:UITableViewScrollPositionTop
//                                          animated:YES];
//        }
        self.loadIndex += LOAD_COUNT;
        return;
    }
    
    NSDate* lastPost = ((Post *)[self.posts lastObject]).added;
    //NSLog(@"last post: %@", lastPost);
    [[[[[Client sharedClient] loadMoreStream:lastPost forProfile:self.profile]
        doNext:^(NSMutableArray *posts) {
            if ([posts count]) {
                [self.posts addObjectsFromArray:posts];
                for (int i = 0; i < 4; i++) {
                    if (self.loadIndex + i >= [self.posts count]) {
                        break;
                    }
                    PostCell *cell = [[PostCell alloc] initWithPost:self.posts[self.loadIndex + i]];
                    [self addChildViewController:cell.postView];
                    [self.cells addObject:cell];
                }
                self.loadIndex += 4;
            } else {
                self.finished = YES;
//                [self.tableView reloadData];
            }
       }]
      deliverOn:[RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground]]
     subscribeError:^(NSError *error) {
         [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching the stream" type:TSMessageNotificationTypeError];
     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.d
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger count = [self.cells count];
    if (!self.finished && count > 0) {
        // Add 1 for loading more cell
        count++;
    }
    return self.finished ? [self.cells count] : 999;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.lastCell = self.currentCell;
//    if (self.needsReload) {
//        [self.tableView reloadData];
//        self.needsReload = NO;
//    }
    NSUInteger newIndex = [indexPath indexAtPosition:[indexPath length] - 1];
    self.shouldPlay = newIndex > self.index;
    self.index = newIndex;
//    
//    if (((int)self.index - 4) >= 0) {
//        PostCell *cell = self.cells[(int)self.index - 4];
//        [cell.postView eject];
//    }
//    if (self.index + 4 < self.loadIndex) {
//        PostCell *cell = self.cells[self.index + 4];
//        [cell.postView eject];
//    }
    
    if (self.index < [self.cells count]) {
        PostCell *cell = self.cells[self.index];
        self.currentCell = cell;
        return cell;
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [spinner setCenter:CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0)];
        cell.contentView.backgroundColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:spinner];
        [spinner startAnimating];
        self.currentCell = nil;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [indexPath indexAtPosition:[indexPath length] - 1];
    if (index < [self.cells count]) {
        PostCell *cell = self.cells[index];
        [cell.postView stop];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - UIScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    if (self.currentCell) {
//        double delayInSeconds = 0.5;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [self.currentCell.postView play];
//        });
//    }
    
    if (!self.finished && self.index == [self.cells count] - 3) {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadMore];
        //});
    }
    if (self.shouldPlay) {
        [self.currentCell.postView play];
    }
    [self.lastCell.postView eject];
//    if (!self.needsReload) {
//        [self.currentCell.postView play];
//    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Determine cell height based on screen
    return CGRectGetHeight(self.view.frame);
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
