//
//  PostCell.h
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "PostViewController.h"

@interface PostCell : UITableViewCell

@property (nonatomic) Post *post;
@property (nonatomic) PostViewController *postView;

-(id)initWithPost:(Post *)post;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andPost:(Post *)post;

@end
