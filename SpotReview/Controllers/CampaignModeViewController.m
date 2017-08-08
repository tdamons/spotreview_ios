//
//  CampaignModeViewController.m
//  SpotReview
//
//  Created by lion on 11/25/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "CampaignModeViewController.h"
#import "REFrostedViewController.h"
#import "MBProgressHUD.h"
#import "SRCampaignObject.h"
#import "APIService.h"
#import "SessionManager.h"

@interface CampaignModeViewController () <UITextFieldDelegate> {
    IBOutlet UIView *commentView;
    IBOutlet UIView *campaignCodeView;
    IBOutlet UITextField *campaignCodeTextField;
}

@end

@implementation CampaignModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    campaignCodeView.layer.borderWidth = 1.0;
    campaignCodeView.layer.borderColor = [UIColor blackColor].CGColor;
    campaignCodeView.layer.cornerRadius = 10.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"CAMPAIGN MODE";
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

- (void)checkCampaignCode {
    NSString *campaignCode = campaignCodeTextField.text;
    
    NSMutableDictionary *infoDic = [[NSMutableDictionary alloc] init];
    [infoDic setObject:campaignCode forKey:@"campaign_code"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [APIService makeApiCallWithMethodUrl:API_CHECK_CAMPAIGNCODE andRequestType:RequestTypePost andPathParams:nil andQueryParams:infoDic resultCallback:^(NSObject *result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
       
        NSDictionary *dic = (NSDictionary*)result;
        BOOL resultFlag = [[dic objectForKey:@"result"] boolValue];
        
        if (resultFlag) {
            NSDictionary *campaignItemDic = [dic objectForKey:@"object"];
            SRCampaignObject *campaignItem = [[SRCampaignObject alloc] initWithDictionary:campaignItemDic];
            [SessionManager currentSession].campaignData = campaignItem;
            [self performSegueWithIdentifier:@"campaignBrandingIdentifier" sender:nil];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid campaign code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    } faultCallback:^(NSError *fault) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view endEditing:NO];
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:[fault localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.4 animations:^{
        commentView.center = CGPointMake(self.view.center.x, self.view.center.y + 32);
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextfieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.4 animations:^{
        commentView.center = CGPointMake(self.view.center.x, self.view.center.y - 80);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.4 animations:^{
        commentView.center = CGPointMake(self.view.center.x, self.view.center.y + 32);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIButtonEvents
- (IBAction)onOk:(id)sender {
    if ([campaignCodeTextField.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Please enter campaign code!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    } else {
        [self.view endEditing:YES];
        [UIView animateWithDuration:0.4 animations:^{
            commentView.center = CGPointMake(self.view.center.x, self.view.center.y + 32);
        }];
        [self checkCampaignCode];
    }
}

@end
