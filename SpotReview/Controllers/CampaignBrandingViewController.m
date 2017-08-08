//
//  CampaignBrandingViewController.m
//  SpotReview
//
//  Created by lion on 11/24/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "CampaignBrandingViewController.h"
#import "SessionManager.h"
#import "UIImageView+AFNetworking.h"

@interface CampaignBrandingViewController () {
    IBOutlet UIImageView *brandingImageView;
    IBOutlet UIButton *checkBtn;
}

@end

@implementation CampaignBrandingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadBrandingImage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = [SessionManager currentSession].campaignData.campaignCode;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_backarrow_white"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
//    checkBtn.layer.masksToBounds = YES;
//    checkBtn.layer.borderWidth = 1.0;
//    checkBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    checkBtn.layer.cornerRadius = 10.0;
}

- (void)loadBrandingImage {
    NSString *imagepath = [SessionManager currentSession].campaignData.campaignBranding;
    NSURL *imageUrl = [NSURL URLWithString:imagepath];
    [brandingImageView setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIButtonEvents
- (IBAction)onOk:(id)sender {
    [self performSegueWithIdentifier:@"takePictureFromBrandingIdentifier" sender:sender];
}


@end
