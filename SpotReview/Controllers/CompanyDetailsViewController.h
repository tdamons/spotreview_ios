//
//  CompanyDetailsViewController.h
//  SpotReview
//
//  Created by lion on 11/26/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRSpotObject.h"
#import "SRSpotDetailObject.h"

@interface CompanyDetailsViewController : UIViewController

@property (nonatomic, strong) SRSpotObject *spotItem;
@property (nonatomic) BOOL isFromReview;

@end
