//
//  DualPostCell.m
//  nearsight
//
//  Created by Ebby Amir on 4/2/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "DualPostCell.h"

@implementation DualPostCell

- (id)initWithLeftPost:(Post *)leftPost andRightPost:(Post *)rightPost
{
    self = [super init];
    if (self) {
        self.leftPost = leftPost;
        self.rightPost = rightPost;

        self.leftPostView = [[ThumbView alloc] initWithFrame:CGRectMake(1, 1, 157, 280)];
        self.rightPostView = [[ThumbView alloc] initWithFrame:CGRectMake(80.5, 1, 157, 280)];
        self.leftPostView.post = leftPost;
        self.rightPostView.post = rightPost;

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.leftPostView];
        [self.contentView addSubview:self.rightPostView];
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

//- (id)setLeftPost:(Post *)leftPost andRightPost:(Post *)rightPost
//{
//    self.leftPost = leftPost;
//    self.rightPost = rightPost;
//    return self;
//}

-(void)layoutSubViews
{
    // Basically the viewDidAppear
    //[self.postView play];
}

@end
