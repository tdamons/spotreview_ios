//
//  CompanyDetailTableViewCell.h
//  SpotReview
//
//  Created by lion on 11/26/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CompanyDetailTableViewCellDelegate <NSObject>

- (void)didClickImage:(NSInteger)index;

@end

@interface CompanyDetailTableViewCell : UITableViewCell <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *userAvatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *ratingLabel;
@property (nonatomic, weak) IBOutlet UIImageView *companyImageView;
@property (nonatomic, retain) IBOutlet UITextView *commentTextView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@property (nonatomic) NSInteger cellIndex;
@property (nonatomic, weak) id <CompanyDetailTableViewCellDelegate> delegate;

@end
