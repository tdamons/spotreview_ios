//
//  BuyServiceViewController.m
//  SpotReview
//
//  Created by lion on 12/4/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "BuyServiceViewController.h"
#import "ContactUsViewController.h"
#import "REFrostedViewController.h"

@interface BuyServiceViewController ()

@end

@implementation BuyServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"Buy Services";
    [self.navigationController.navigationBar setBarTintColor:APP_MAIN_COLOR];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_menuwhite.png"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 22)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)onMenu:(id)sender {
    [self.frostedViewController presentMenuViewController];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"buyToContactIdentifier"]) {
        ContactUsViewController *controller = segue.destinationViewController;
        controller.isFromBuy = YES;
    }
}

- (IBAction)onContactUs:(id)sender {
    [self performSegueWithIdentifier:@"buyToContactIdentifier" sender:sender];
}

@end
