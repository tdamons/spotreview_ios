//
//  CheckTopViewController.m
//  SpotReview
//
//  Created by lion on 10/23/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "CheckTopViewController.h"
#import "TopSpotsViewController.h"
#import "ASFSharedViewTransition.h"
#import "TopSpotsViewController.h"
#import "SpotDetailViewController.h"

@interface CheckTopViewController () {
    IBOutlet UIButton *topSpotsBtn;
    IBOutlet UIButton *coldSpotsBtn;
}

@end

@implementation CheckTopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"TOP SPOTS";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_menuwhite.png"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 22)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onMenu:(id)sender {
    [self.frostedViewController presentMenuViewController];
}

#pragma mark - ButtonEvents
- (IBAction)onSpots:(id)sender {
    
    [ASFSharedViewTransition addTransitionWithFromViewControllerClass:[TopSpotsViewController class]
                                                ToViewControllerClass:[SpotDetailViewController class]
                                             WithNavigationController:self.navigationController
                                                         WithDuration:0.45f];
    
    [self performSegueWithIdentifier:@"topSpotsIdentifier" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if ([segue.identifier isEqualToString:@"topSpotsIdentifier"]) {
        TopSpotsViewController *controller = segue.destinationViewController;  
    
        if (btn == topSpotsBtn) {
            controller.isTop = YES;
        } else {
            controller.isTop = NO;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
