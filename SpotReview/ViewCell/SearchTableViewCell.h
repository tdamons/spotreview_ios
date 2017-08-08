//
//  SearchTableViewCell.h
//  SpotReview
//
//  Created by lion on 11/20/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *brandColdRation;
@property (weak, nonatomic) IBOutlet UITextField *brandGoodRation;

@end
