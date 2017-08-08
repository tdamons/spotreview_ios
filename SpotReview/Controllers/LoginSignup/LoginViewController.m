//
//  ViewController.m
//  SpotReview
//
//  Created by lion on 10/20/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "LoginViewController.h"
#import "SRUser.h"
#import "SessionManager.h"
#import "SVProgressHUD.h"
#import "APIService.h"
#import "FHSTwitterEngine.h"
#import "MBProgressHUD.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController () <UITextFieldDelegate, FHSTwitterEngineAccessTokenDelegate> {
    SRUser *savedUser;
    NSMutableDictionary *fbUserData;
    NSMutableDictionary *twitterUserData;
    IBOutlet UIView *emailView;
    IBOutlet UITextField *emailTextField;
    IBOutlet UIView *passwordView;
    IBOutlet UITextField *passwordField;
    
    IBOutlet UIButton *loginBtn;
    IBOutlet UIButton *loginFbBtn;
    IBOutlet UIButton *loginTwitterBtn;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewLayout];
    
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    
    fbUserData = [[NSMutableDictionary alloc] init];
    twitterUserData = [[NSMutableDictionary alloc] init];
    NSData *archivedUser = [[NSUserDefaults standardUserDefaults] objectForKey:SR_CURRENT_USER];
    if (archivedUser) {
        savedUser = [NSKeyedUnarchiver unarchiveObjectWithData:archivedUser];
    } else {
        savedUser = nil;
    }
    
    if (savedUser != nil) {
        SRUserType savedUserType = savedUser.userType;
        if (savedUserType == SRUserFacebook && [FBSDKAccessToken currentAccessToken]) {
            [self performSelectorOnMainThread:@selector(onFacebookLogin:) withObject:nil waitUntilDone:NO];
        } else if (savedUserType == SRUserEmail) {
            [self performSelectorOnMainThread:@selector(onEmailLogin) withObject:nil waitUntilDone:NO];
        } else if (savedUserType == SRUserTwitter) {
            [self performSelectorOnMainThread:@selector(twitterLoginWithParam) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setBarTintColor:APP_MAIN_COLOR];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
}

- (void)viewLayout {
    [[emailView layer] setBorderWidth:1.0f];
    [[emailView layer] setBorderColor:[UIColor blackColor].CGColor];
    [[passwordView layer] setBorderWidth:1.0f];
    [[passwordView layer] setBorderColor:[UIColor blackColor].CGColor];
    [[loginBtn layer] setBorderWidth:1.0f];
    [[loginBtn layer] setBorderColor:[UIColor blackColor].CGColor];
    [[loginFbBtn layer] setBorderWidth:1.0f];
    [[loginFbBtn layer] setBorderColor:[UIColor blackColor].CGColor];
    [[loginTwitterBtn layer] setBorderWidth:1.0f];
    [[loginTwitterBtn layer] setBorderColor:[UIColor blackColor].CGColor];
}

- (void)onEmailLogin {
    NSString *savedEmail = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_USEREMAIL];
    NSString *savedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_PASSWORD];
    emailTextField.text = savedEmail;
    passwordField.text = savedPassword;
    NSMutableDictionary *loginDic = [[NSMutableDictionary alloc] init];
    [loginDic setObject:savedEmail forKey:@"email"];
    [loginDic setObject:savedPassword forKey:@"password"];
    
    [self loginWithParam:loginDic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)successLogin {
    self.navigationController.navigationBarHidden = YES;
    [self performSegueWithIdentifier:@"rootIdentifier" sender:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)SVProgressShow:(NSString *)showStatus {
    [SVProgressHUD showWithStatus:showStatus];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:(30/255.0f) green:(35/255.0f) blue:(37/255.0f) alpha:0.7f]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD show];
}

- (void)fetchUserData {
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (error != nil) {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 
                 [[[UIAlertView alloc] initWithTitle:@"Facebook Login Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
             } else {
                 [self loginWithFacebookInfo:result];
             }
         }];
    }
}

- (void)loginWithFacebookInfo:(NSDictionary*)user {
    NSString *fbProfilePhoto = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", user[@"id"]];
    
    [fbUserData setObject:user[@"name"] forKey:@"username"];
    [fbUserData setObject:fbProfilePhoto forKey:@"avatarpath"];
    [fbUserData setObject:user[@"id"] forKey:@"facebookid"];
    
    [fbUserData setObject:[NSString stringWithFormat:@"%d", SRUserFacebook] forKey:@"userType"];
    
    [self loginWithFacebook];
}

- (void)loginWithFacebook {
    [APIService makeApiCallWithMethodUrl:API_FACEBOOK_LOGIN andRequestType:RequestTypePost andPathParams:nil andQueryParams:fbUserData resultCallback:^(NSObject *result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSDictionary *dic = (NSDictionary*)result;
        
        NSDictionary *userInfoDic = [dic objectForKey:@"object"];
        SRUser *userInfo = [[SRUser alloc] initWithDictionary:userInfoDic];
        [SessionManager currentSession].userInfo = userInfo;
        
        // Signin Success...
        [self successLogin];
    } faultCallback:^(NSError *fault) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:[fault localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)twitterLoginWithParam {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
//    [self loadAccessToken];
    NSString *savedTwitterName = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_TWITTER_NAME];
    NSString *savedTwitterId = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_TWITTER_ID];
    
    [twitterUserData setObject:savedTwitterName forKey:@"username"];
    [twitterUserData setObject:savedTwitterId forKey:@"twitterid"];
    [twitterUserData setObject:[NSString stringWithFormat:@"%d", SRUserTwitter] forKey:@"userType"];
    
    [self loginWithTwitter];
}

- (void)loginWithTwitter {
    [APIService makeApiCallWithMethodUrl:API_TWITTER_LOGIN andRequestType:RequestTypePost andPathParams:nil andQueryParams:twitterUserData resultCallback:^(NSObject *result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSDictionary *dic = (NSDictionary*)result;
        
        NSDictionary *userInfoDic = [dic objectForKey:@"object"];
        SRUser *userInfo = [[SRUser alloc] initWithDictionary:userInfoDic];
        [SessionManager currentSession].userInfo = userInfo;
        
        // Signin Success...
        [self successLogin];
    } faultCallback:^(NSError *fault) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:[fault localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

- (void)loginWithParam:(NSMutableDictionary *)loginDic {
    [self.view endEditing:YES];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [APIService makeApiCallWithMethodUrl:API_LOGIN andRequestType:RequestTypePost andPathParams:nil andQueryParams:loginDic resultCallback:^(NSObject *result) {
        
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [FBSDKProfile setCurrentProfile:nil];
        
//        [SVProgressHUD dismiss];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSDictionary *dic = (NSDictionary *)result;
        BOOL resultFlag = [[dic objectForKey:@"result"] boolValue];
        if (resultFlag) {
            NSDictionary *userInfoDic = [dic objectForKey:@"object"];
            SRUser *userInfo = [[SRUser alloc] initWithDictionary:userInfoDic];
            [SessionManager currentSession].userInfo = userInfo;
            
            [[NSUserDefaults standardUserDefaults] setObject:emailTextField.text forKey:LOGIN_USEREMAIL];
            [[NSUserDefaults standardUserDefaults] setObject:passwordField.text forKey:LOGIN_PASSWORD];
            
            //Signin Success...
            [self successLogin];
        } else {
            [SRConstant UIAlertViewShow:@"Email or Password does not match!" withTitle:@"Error"];
        }
        
    } faultCallback:^(NSError *fault) {
//        [SVProgressHUD dismiss];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self.view endEditing:NO];
        [[[UIAlertView alloc] initWithTitle:@"Connection Error" message:[fault localizedFailureReason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}

#pragma mark - ButtonEvents
- (IBAction)onLogin:(id)sender {
    NSString *email = emailTextField.text;
    NSString *Password = passwordField.text;
    
    if (!email.length) {
        [SRConstant UIAlertViewShow:@"Email is required." withTitle:@"Error"];
    } else if (!Password.length) {
        [SRConstant UIAlertViewShow:@"Password is required." withTitle:@"Error"];
    } else {
        NSMutableDictionary *loginDic = [[NSMutableDictionary alloc] init];
        [loginDic setObject:email forKey:@"email"];
        [loginDic setObject:Password forKey:@"password"];

        [self loginWithParam:loginDic];
    }
}

- (IBAction)onFacebookLogin:(id)sender {

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if ([FBSDKAccessToken  currentAccessToken]) {
        [self fetchUserData];
    } else {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            
            if (error != nil) {

                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                [[[UIAlertView alloc] initWithTitle:@"Facebook Login Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            } else if (result.isCancelled) {

                [MBProgressHUD hideHUDForView:self.view animated:YES];
                return;
            } else {
                
                if ([result.grantedPermissions containsObject:@"public_profile"]) {
                    [self fetchUserData];
                } else {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    [FBSDKAccessToken setCurrentAccessToken:nil];
                    [FBSDKProfile setCurrentProfile:nil];
                    
                    return;
                }
            }
        }];
    }
}

- (IBAction)onTwitterLogin:(id)sender {
    UIViewController *twitterLoginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
        
        NSString *twitterUserName = [FHSTwitterEngine sharedEngine].authenticatedUsername;
        NSString *twitterId = [FHSTwitterEngine sharedEngine].authenticatedID;
        [[NSUserDefaults standardUserDefaults] setObject:twitterUserName forKey:LOGIN_TWITTER_NAME];
        [[NSUserDefaults standardUserDefaults] setObject:twitterId forKey:LOGIN_TWITTER_ID];
        
        [self twitterLoginWithParam];
        
    }];
    [self presentViewController:twitterLoginController animated:YES completion:nil];
}

- (IBAction)onRegister:(id)sender {
    [self performSegueWithIdentifier:@"registerIdentifier" sender:nil];
}

- (IBAction)onForgotPwd:(id)sender {
    [self performSegueWithIdentifier:@"forgotIdentifier" sender:nil];
}

#pragma mark - FHSTwitterEngineAccessTokenDelegate
- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAcce/ssHTTPBody"];
}

- (void)twitterEngineControllerDidCancel {
    
}

#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == emailTextField) {
        [passwordField becomeFirstResponder];
    } else {
        [passwordField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == passwordField) {
        [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            self.view.center = CGPointMake(self.view.center.x, self.view.center.y - 40);
        } completion:nil];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == passwordField) {
        [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            self.view.center = CGPointMake(self.view.center.x, self.view.center.y + 40);
        } completion:nil];
    }
}

@end
