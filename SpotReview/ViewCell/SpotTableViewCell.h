//
//  SpotTableViewCell.h
//  SpotReview
//
//  Created by lion on 10/30/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpotTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *spotImage;
@property (weak, nonatomic) IBOutlet UITextField *spotCompanyName;
@property (weak, nonatomic) IBOutlet UITextField *spotHotRatio;
@property (weak, nonatomic) IBOutlet UITextField *spotColdRation;
@property (nonatomic) BOOL isAnimation;

@property (nonatomic)NSInteger cellIndex;

@end
