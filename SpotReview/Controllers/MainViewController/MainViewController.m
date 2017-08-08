//
//  MainViewController.m
//  SpotReview
//
//  Created by lion on 10/22/15.
//  Copyright (c) 2015 lion. All rights reserved.
//
#import "MainViewController.h"

@interface MainViewController () {
    IBOutlet UIView *contentView;
}

@end

@implementation MainViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    [self.frostedViewController panGestureRecognized:sender];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"HOME";
    [self.navigationController.navigationBar setBarTintColor:APP_MAIN_COLOR];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (IBAction)onMenu:(id)sender {
    [self.frostedViewController presentMenuViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ButtonEvents
- (IBAction)onPostReview:(id)sender {
    [self performSegueWithIdentifier:@"postCheckIdentifier" sender:nil];
}

@end
