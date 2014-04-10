//
//  PostCell.m
//  fomo
//
//  Created by Ebby Amir on 3/12/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "PostCell.h"

@implementation PostCell

//@synthesize post = _post;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andPost:(Post *)post
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.post = post;
        self.postView = [[PostViewController alloc] initWithPost:post];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.postView.view];
    }
    return self;
}

- (id)initWithPost:(Post *)post
{
    self = [super init];
    if (self) {
        self.post = post;
        self.postView = [[PostViewController alloc] initWithPost:post];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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

-(void)setPost:(Post *)post
{
    _post = post;
    [self.postView setPost:post];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubViews
{
    // Basically the viewDidAppear
    //[self.postView play];
}

@end
