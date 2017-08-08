//
//  SpotDetailViewController.m
//  SpotReview
//
//  Created by lion on 10/23/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "SpotDetailViewController.h"
#import "SpotImageViewController.h"
#import "ASFSharedViewTransition.h"
#import "UIImageView+AFNetworking.h"

@interface SpotDetailViewController () <UITextViewDelegate, UIScrollViewDelegate,  ASFSharedViewTransitionDataSource> {
    UIScrollView *scaledImageScrollView;
    UIImageView *scaledImageView;
    IBOutlet UITextView *spotContent;
    IBOutlet UITextField *spotTitle;
    IBOutlet UILabel *spotStatus;
    IBOutlet UILabel *dateLabel;
}

@end

@implementation SpotDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self downloadData];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageTap:)];
    [self.spotImageView addGestureRecognizer:tapGesture];
    tapGesture.numberOfTapsRequired = 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_backarrow_white"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    
//    if (self.isTop) {
//        self.navigationItem.title = @"HOT SPOT";
//    } else {
//        self.navigationItem.title = @"COLD SPOT";
//    }
    
//    UIImage *rightBtnImage = [UIImage imageNamed:@"logo_2a"];
//    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
//    rightImageView.image = rightBtnImage;
    
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightImageView];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.selectedImage = nil;
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)downloadData {    
    
    if (self.selectedImage != nil) {
        self.spotImageView.image = self.selectedImage;
    } else {
        NSURL *spotPhotoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kS3ImagePath, self.spotItem.spotImageUrl]];
        [self.spotImageView setImageWithURL:spotPhotoUrl placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    spotContent.text = self.spotItem.spotDescription;
    dateLabel.text = self.spotItem.spotCreatedDate;
    dateLabel.text = [self.spotItem.spotCreatedDate substringWithRange:NSMakeRange(5, 11)];
    spotTitle.text = self.spotItem.spotCompanyName;
    if (self.spotItem.goodNumber > self.spotItem.badNumber) {
        spotStatus.text = @"GOOD";
        self.navigationItem.title = @"HOT SPOT";
        [spotStatus setTextColor:UIColorFromRGB(0x008000)];
    } else {
        spotStatus.text = @"BAD";
        self.navigationItem.title = @"COLD SPOT";
        [spotStatus setTextColor:UIColorFromRGB(0xBF0302)];
    }
}

- (void)onImageTap:(UITapGestureRecognizer *)tapGestureRecognizer {
//    SpotImageViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:SPOTIMAGE_CONTROLLER];
//    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - ButtonEvents
- (IBAction)onSpotImage:(id)sender {
//    SpotImageViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:SPOTIMAGE_CONTROLLER];
//    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - TextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return NO;
}

#pragma mark - ASFSharedViewTransitionDataSource
- (UIView *)sharedView {
    return _spotImageView;
}

@end
