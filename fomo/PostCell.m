//
//  PostCell.m
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "PostCell.h"

@implementation PostCell

- (id)initWithPost:(Post *)post
{
    self = [super init];
    if (self) {
        self.post = post;
        self.postView = [[PostViewController alloc] initWithPost:post];
        [self.contentView addSubview:self.postView.view];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
