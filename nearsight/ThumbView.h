//
//  ThumbView.h
//  nearsight
//
//  Created by Ebby Amir on 4/2/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "Constants.h"

@interface ThumbView : UIView

@property (nonatomic) Post *post;
@property (nonatomic, strong) UIImage *thumb;

@end
