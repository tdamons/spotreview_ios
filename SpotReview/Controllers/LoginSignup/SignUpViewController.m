//
//  SignUpViewController.m
//  SpotReview
//
//  Created by lion on 10/22/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "SignUpViewController.h"
#import "SVProgressHUD.h"
#import "MBProgressHUD.h"
#import "APIService.h"
#import "SRUser.h"
#import "SessionManager.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface SignUpViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate> {
    UIView *securityDropView;
    UITableView *securityTableView;
    NSArray *questionArray;
    IBOutlet UIView *commentView;
    IBOutlet UIView *nameView;
    IBOutlet UITextField *nameTextField;
    IBOutlet UIView *emailView;
    IBOutlet UITextField *emailTextField;
    IBOutlet UIView *pwdView;
    IBOutlet UITextField *pwdTextField;
    IBOutlet UIView *mobileNumberView;
    IBOutlet UITextField *mobileNumberTextField;
    IBOutlet UIView *secQuestionView;
    IBOutlet UITextField *secQuestionTextField;
    IBOutlet UIView *answerView;
    IBOutlet UITextField *answerTextField;
    
    IBOutlet UIButton *registerBtn;
    
    UISwipeGestureRecognizer *swipeRecognizer;
}

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"REGISTER";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.navigationController setNavigationBarHidden:NO];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_backarrow_white"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    securityDropView = [[UIView alloc] init];
    securityTableView = [[UITableView alloc] init];
    
    securityTableView.delegate = self;
    securityTableView.dataSource = self;
    questionArray =  @[@"Your pet's name?", @"Your mother's name?", @"Your favorite animal?", @"Your favorite food?", @"Your favorite car?"];
    [securityDropView setFrame:CGRectMake(secQuestionView.frame.origin.x, secQuestionView.frame.origin.y, secQuestionView.frame.size.width, 101)];
    [securityDropView setBackgroundColor:[UIColor whiteColor]];
    securityDropView.layer.borderWidth = 1;
    securityDropView.layer.borderColor = [[UIColor blackColor] CGColor];
    [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, 0)];
    [commentView addSubview:securityDropView];
    [securityDropView addSubview:securityTableView];
    [securityDropView setHidden:YES];
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewLayout {
    
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipfFrom:)];
    swipeRecognizer.delegate = self;
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [commentView addGestureRecognizer:swipeRecognizer];
    
    [[nameView layer] setBorderWidth:1.0f];
    [[nameView layer] setBorderColor:[UIColor blackColor].CGColor];
    [[emailView layer] setBorderWidth:1.0f];
    [[emailView layer] setBorderColor:[UIColor blackColor].CGColor];
    [[pwdView layer] setBorderWidth:1.0f];
    [[pwdView layer] setBorderColor:[UIColor blackColor].CGColor];
    [[mobileNumberView layer] setBorderWidth:1.0f];
    [[mobileNumberView layer] setBorderColor:[UIColor blackColor].CGColor];
    [[secQuestionView layer] setBorderWidth:1.0f];
    [[secQuestionView layer] setBorderColor:[UIColor blackColor].CGColor];
    [[answerView layer] setBorderWidth:1.0f];
    [[answerView layer] setBorderColor:[UIColor blackColor].CGColor];
    
    [[registerBtn layer] setBorderWidth:1.0f];
    [[registerBtn layer] setBorderColor:[UIColor blackColor].CGColor];
}

- (void)registerUser:(NSMutableDictionary *)signUpDic {

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [APIService makeApiCallWithMethodUrl:API_REGISTER andRequestType:RequestTypePost andPathParams:nil andQueryParams:signUpDic resultCallback:^(NSObject *result) {
        
        [[NSUserDefaults standardUserDefaults] setObject:emailTextField.text forKey:LOGIN_USEREMAIL];
        [[NSUserDefaults standardUserDefaults] setObject:pwdTextField.text forKey:LOGIN_PASSWORD];

        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSDictionary *dic = (NSDictionary *)result;
        NSLog(@"%@", dic);
        
        BOOL resultFlag = [[dic objectForKey:@"result"] boolValue];
        
        if (resultFlag) {
            [FBSDKAccessToken setCurrentAccessToken:nil];
            [FBSDKProfile setCurrentProfile:nil];
            
            NSDictionary *userInfoDic = [dic objectForKey:@"object"];
            SRUser *userInfo = [[SRUser alloc] initWithDictionary:userInfoDic];
            [SessionManager currentSession].userInfo = userInfo;
            
            // Signup Success...
            [self successRegister];
        } else {
            
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Username or E-mail already assigned to another user account. Please try another Username or E-mail address to continue" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    } faultCallback:^(NSError *fault) {

        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [[[UIAlertView alloc] initWithTitle:@"Server Error" message:[fault localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)successRegister {
    self.navigationController.navigationBarHidden = YES;
    [self performSegueWithIdentifier:@"rootFromRegisterIdentifier" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == secQuestionTextField) {
        [self.view endEditing:YES];
        [self showQuestions:textField];
        return NO;
    } else {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == pwdTextField) {
        [UIView animateWithDuration:0.4 animations:^{
            commentView.center = CGPointMake(self.view.center.x, self.view.center.y - 35);
        }];
    } else if (textField == mobileNumberTextField) {
        [UIView animateWithDuration:0.4 animations:^{
            commentView.center = CGPointMake(self.view.center.x, self.view.center.y - 80);
        }];
    } else if (textField == secQuestionTextField) {
//        [UIView animateWithDuration:0.4 animations:^{
//            commentView.center = CGPointMake(commentView.center.x, commentView.center.y - 70);
//        }];
        
    } else if (textField == answerTextField) {
        [UIView animateWithDuration:0.4 animations:^{
            commentView.center = CGPointMake(self.view.center.x, self.view.center.y - 180);
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == nameTextField) {
        [emailTextField becomeFirstResponder];
    } else if (textField == emailTextField) {
        [pwdTextField becomeFirstResponder];
    } else if (textField == pwdTextField) {
        [mobileNumberTextField becomeFirstResponder];
    } else if (textField == mobileNumberTextField) {
        [self.view endEditing:YES];
        [self showQuestions:secQuestionTextField];
    } else if (textField == secQuestionTextField) {
        [answerTextField becomeFirstResponder];
    } else {
        [answerTextField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if  (textField == answerTextField) {
        [UIView animateWithDuration:0.4 animations:^{
            commentView.center = CGPointMake(self.view.center.x, self.view.center.y + 32);
        } completion:^(BOOL finished) {
            NSLog(@"Comment Finished");
        }];
    }
    
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [securityDropView setFrame:CGRectMake(secQuestionView.frame.origin.x, secQuestionView.frame.origin.y + 36, secQuestionView.frame.size.width, 0)];
        [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, 0)];
    } completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [securityDropView setFrame:CGRectMake(secQuestionView.frame.origin.x, secQuestionView.frame.origin.y + 36, secQuestionView.frame.size.width, 0)];
        [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, 0)];
        commentView.center = CGPointMake(self.view.center.x, self.view.center.y + 32);
    } completion:nil];
}

- (void)showQuestions:(UITextField *)textField {
    
    [securityDropView setHidden:NO];
    [securityDropView setFrame:CGRectMake(secQuestionView.frame.origin.x, secQuestionView.frame.origin.y + 35, secQuestionView.frame.size.width, 0)];
    [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, 0)];
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [securityDropView setFrame:CGRectMake(secQuestionView.frame.origin.x, secQuestionView.frame.origin.y + 35, secQuestionView.frame.size.width, 101)];
        [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, securityDropView.frame.size.height)];
        commentView.center = CGPointMake(self.view.center.x, self.view.center.y + 32);
    } completion:nil];
}

- (void)handleSwipfFrom:(id)sender {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.4 animations:^{
        commentView.center = CGPointMake(self.view.center.x, self.view.center.y + 32);
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return questionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"QuestionCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [questionArray objectAtIndex:indexPath.row];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    secQuestionTextField.text = [questionArray objectAtIndex:indexPath.row];
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [securityDropView setFrame:CGRectMake(secQuestionView.frame.origin.x, secQuestionView.frame.origin.y + 36, secQuestionView.frame.size.width, 0)];
        [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, 0)];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.view endEditing:YES];
}

#pragma mark - UIGestureDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"Touch");
    return YES;
}

#pragma mark - UIButtonEvents
- (IBAction)onRegister:(id)sender {
    
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [securityDropView setFrame:CGRectMake(secQuestionView.frame.origin.x, secQuestionView.frame.origin.y + 36, secQuestionView.frame.size.width, 0)];
        [securityTableView setFrame:CGRectMake(0, 0, securityDropView.frame.size.width, 0)];
        commentView.center = CGPointMake(self.view.center.x, self.view.center.y + 32);
        [self.view endEditing:YES];
    } completion:nil];
    
    NSString *userName = nameTextField.text;
    NSString *email = emailTextField.text;
    NSString *password = pwdTextField.text;
    NSString *phoneNumber = mobileNumberTextField.text;
    NSString *secQuestion = secQuestionTextField.text;
    NSString *answer = answerTextField.text;
    
    if (!userName.length) {
        [SRConstant UIAlertViewShow:@"Please enter valid username." withTitle:@"Error"];
    } else if (!email.length) {
        [SRConstant UIAlertViewShow:@"Please enter email." withTitle:@"Error"];
    } else if (!password.length) {
        [SRConstant UIAlertViewShow:@"Please enter password." withTitle:@"Error"];
    } else if (!phoneNumber.length) {
        [SRConstant UIAlertViewShow:@"Please enter mobile number." withTitle:@"Error"];
    } else if (!secQuestion.length) {
        [SRConstant UIAlertViewShow:@"Security Question is required." withTitle:@"Error"];
    } else if (!answer.length) {
        [SRConstant UIAlertViewShow:@"Answer is required." withTitle:@"Error"];
    } else if (![SRConstant NSStringIsValidEmail:email]) {
        [SRConstant UIAlertViewShow:@"Please enter valid email." withTitle:@"Error"];
    } else {
        NSMutableDictionary *signupDic = [[NSMutableDictionary alloc] init];
        [signupDic setObject:userName forKey:@"username"];
        [signupDic setObject:email forKey:@"email"];
        [signupDic setObject:password forKey:@"password"];
        [signupDic setObject:phoneNumber forKey:@"phone"];
        [signupDic setObject:secQuestion forKey:@"question"];
        [signupDic setObject:answer forKey:@"answer"];
        [signupDic setObject:[NSString stringWithFormat:@"%d", SRUserEmail] forKey:@"usertype"];
        
        [self registerUser:signupDic];
    }
}

@end
