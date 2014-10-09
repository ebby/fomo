//
//  AddPostViewController.h
//  fomo
//
//  Created by Ebby Amir on 3/14/14.
//  Copyright (c) 2014 Ebby Amir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Draft.h"

@interface AddPostViewController : UIViewController

-(id)initWithVideoPath:(NSString *)videoPath;
-(id)initWithAsset:(AVAsset *)asset andExportPath:(NSString *)exportPath andTimeline:(NSArray *)timeline;
-(id)initWithAsset:(AVAsset *)asset andDraft:(Draft *)draft;

@end
