//
//  RateViewController.m
//  SpotReview
//
//  Created by lion on 10/23/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "RateViewController.h"
#import "CommentViewController.h"
#import "SessionManager.h"

@interface RateViewController () {
    
    IBOutlet UIButton *rateGoodBtn;
    IBOutlet UIButton *rateBadBtn;
}

@end

@implementation RateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"RATE EXPERIENCE";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_backarrow_white"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIButton *senderBtn = (UIButton *)sender;
    
    if ([segue.identifier isEqualToString:@"commentIdentifier"]) {
        CommentViewController *rateController = segue.destinationViewController;
        if (senderBtn == rateGoodBtn) {
            rateController.isGoodRate = YES;
        } else {
            rateController.isGoodRate = NO;
        }
    }
}

#pragma mark - ButtonEvents
- (IBAction)onRate:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button == rateGoodBtn) {
        [SessionManager currentSession].postData.postStatus = SRGoodStatus;
    } else {
        [SessionManager currentSession].postData.postStatus = SRBadStatus;
    }
    [self performSegueWithIdentifier:@"commentIdentifier" sender:sender];
}

@end
