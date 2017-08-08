//
//  CompanyDetailTableViewCell.m
//  SpotReview
//
//  Created by lion on 11/26/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "CompanyDetailTableViewCell.h"

@implementation CompanyDetailTableViewCell 

- (void)awakeFromNib {
    // Initialization code
    
    self.userAvatarImageView.layer.masksToBounds = YES;
    self.userAvatarImageView.layer.cornerRadius = self.userAvatarImageView.frame.size.width / 2;
    self.userAvatarImageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.userAvatarImageView.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onImageBtn:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickImage:)]) {
        [self.delegate didClickImage:self.cellIndex];
    }
}


#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return NO;
}

@end
