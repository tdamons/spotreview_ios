//
//  ProfileEditViewController.h
//  SpotReview
//
//  Created by lion on 11/17/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileEditViewControllerDelegate <NSObject>

- (void)imageUpdated;

@end

@interface ProfileEditViewController : UIViewController

@property (nonatomic, weak) id <ProfileEditViewControllerDelegate> delegate;

@end
