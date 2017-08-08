//
//  AboutUsViewController.m
//  SpotReview
//
//  Created by lion on 11/23/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "AboutUsViewController.h"
#import "REFrostedViewController.h"

@interface AboutUsViewController () <UITextViewDelegate>

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"ABOUT US";
    [self.navigationController.navigationBar setBarTintColor:APP_MAIN_COLOR];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_menuwhite.png"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 22)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

//- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
//    [self.frostedViewController panGestureRecognized:sender];
//}

- (void)onMenu:(id)sender {
    [self.frostedViewController presentMenuViewController];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return NO;
}

@end
