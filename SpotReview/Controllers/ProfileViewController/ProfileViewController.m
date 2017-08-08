//
//  ProfileViewController.m
//  SpotReview
//
//  Created by lion on 11/17/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "ProfileViewController.h"
#import "SessionManager.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileViewController () {
    IBOutlet UIImageView *userAvatarImageView;
    IBOutlet UIButton *editBtn;
    IBOutlet UILabel *userNameLabel;
    IBOutlet UILabel *displayNameLabel;
    IBOutlet UILabel *emailLabel;
    IBOutlet UILabel *userTelNumberLabel;
    IBOutlet UILabel *secQuestionLabel;
    IBOutlet UILabel *answerLabel;
    IBOutlet UIView *securityView;
}

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
    
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    [self.frostedViewController panGestureRecognized:sender];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"My Profile";
    [self.navigationController.navigationBar setBarTintColor:APP_MAIN_COLOR];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_menuwhite.png"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 22)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    [self viewLayout];
}

- (void)onMenu:(id)sender {
    [self.frostedViewController presentMenuViewController];
}

- (void)viewLayout {
    userAvatarImageView.layer.masksToBounds = YES;
    userAvatarImageView.layer.cornerRadius = userAvatarImageView.frame.size.width / 2 + 1;
    userAvatarImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    userAvatarImageView.layer.borderWidth = 1.0f;
    userAvatarImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    userAvatarImageView.layer.shouldRasterize = YES;
    userAvatarImageView.clipsToBounds = YES;
    
    editBtn.layer.borderColor = UIColorFromRGB(0xBF0302).CGColor;
    editBtn.layer.borderWidth = 1.0f;
    editBtn.layer.masksToBounds = YES;
    editBtn.layer.cornerRadius = 3.0;
    
    NSURL *avatarUrl = [NSURL URLWithString:[SessionManager currentSession].userInfo.userAvatarPath];;
    
    if ([SessionManager currentSession].userInfo.userType == SRUserEmail) {
        [securityView setHidden:YES];
        userNameLabel.text = [SessionManager currentSession].userInfo.userName;
    } else if ([SessionManager currentSession].userInfo.userType == SRUserTwitter) {
        [securityView setHidden:NO];
        
        userNameLabel.text = [NSString stringWithFormat:@"@%@", [SessionManager currentSession].userInfo.userAvatarPath];
    } else {
        [securityView setHidden:NO];
        userNameLabel.text = [SessionManager currentSession].userInfo.userName;
    }    
    
    [userAvatarImageView setImageWithURL:avatarUrl placeholderImage:[UIImage imageNamed:@"avatar_temp"]];
    displayNameLabel.text = [SessionManager currentSession].userInfo.userName;
    emailLabel.text = [SessionManager currentSession].userInfo.email;
    userTelNumberLabel.text = [SessionManager currentSession].userInfo.userTelNumber;
    secQuestionLabel.text = [SessionManager currentSession].userInfo.userSecQuestion;
    answerLabel.text = [SessionManager currentSession].userInfo.userAnswer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButtonEvents
- (IBAction)onEdit:(id)sender {
    [self performSegueWithIdentifier:@"profileEditIdentifier" sender:sender];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
