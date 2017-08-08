//
//  SpotDetailViewController.h
//  SpotReview
//
//  Created by lion on 10/23/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRSpotObject.h"

@interface SpotDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *spotImageView;
@property (nonatomic, strong) SRSpotObject *spotItem;
@property (nonatomic) UIImage *selectedImage;
@property (nonatomic) BOOL isTop;

@end
