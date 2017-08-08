//
//  TopSpotsViewController.h
//  SpotReview
//
//  Created by lion on 10/23/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRSpotObject.h"

@interface TopSpotsViewController : UIViewController

@property (nonatomic, assign) BOOL isTop;
@property (nonatomic) NSInteger selectedCellIndex;
@property (nonatomic) BOOL isFromReviewList;
@property (nonatomic) BOOL isFromSearch;
@property (nonatomic, strong) SRSpotObject *spotFromReview;

@end
