//
//  DualPostCell.h
//  nearsight
//
//  Created by Ebby Amir on 4/2/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "ThumbView.h"

@interface DualPostCell : UITableViewCell

@property (nonatomic) Post *leftPost;
@property (nonatomic) Post *rightPost;
@property (nonatomic) ThumbView *leftPostView;
@property (nonatomic) ThumbView *rightPostView;

-(id)initWithLeftPost:(Post *)leftPost andRightPost:(Post *)rightPost;
//- (id)setLeftPost:(Post *)leftPost andRightPost:(Post *)rightPost;

@end
