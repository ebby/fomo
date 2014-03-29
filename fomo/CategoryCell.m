//
//  CategoryCell.m
//  fomo
//
//  Created by Ebby Amir on 3/27/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "CategoryCell.h"

@implementation CategoryCell

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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(15, 10, 25, 25);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.textLabel.frame = CGRectMake(55, 0, self.frame.size.width - 55, self.frame.size.height);
}

@end
