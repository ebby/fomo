//
//  UIExtensions.h
//  fomo
//
//  Created by Ebby Amir on 3/28/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ExtendedHitButton : UIButton

+ (instancetype)extendedHitButton;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end
