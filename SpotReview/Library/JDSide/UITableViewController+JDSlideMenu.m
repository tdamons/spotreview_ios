//
//  UITableViewController+JDSlideMenu.m
//  UniQulture
//
//  Created by Yingcheng Li on 9/18/14.
//  Copyright (c) 2014 ss. All rights reserved.
//

#import "UITableViewController+JDSlideMenu.h"

@implementation UITableViewController (JDSideMenu)

- (JDSideMenu*)sideMenuController;
{
    UIViewController *controller = self.parentViewController;
    while (controller) {
        if ([controller isKindOfClass:[JDSideMenu class]]) {
            return (JDSideMenu*)controller;
        }
        controller = controller.parentViewController;
    }
    return nil;
}

@end
