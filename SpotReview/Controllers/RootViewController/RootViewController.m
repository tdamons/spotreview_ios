//
//  RootViewController.m
//  SpotReview
//
//  Created by lion on 10/28/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)awakeFromNib {
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:HOMENAV_STORYID];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:MENU_STORYID];
}

@end
