//
//  PlaceCell.m
//  nearsight
//
//  Created by Ebby Amir on 4/3/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import "PlaceCell.h"

@implementation PlaceCell

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
    self.imageView.frame = CGRectMake(0, 1, 58, 58);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.textLabel.frame = CGRectMake(65, 0, self.frame.size.width - 65, self.frame.size.height);
}

@end
