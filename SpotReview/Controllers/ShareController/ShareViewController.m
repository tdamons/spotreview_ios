//
//  ShareViewController.m
//  SpotReview
//
//  Created by lion on 11/6/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "ShareViewController.h"
#import "SessionManager.h"
#import "MBProgressHUD.h"
#import "APIService.h"
#import "FHSTwitterEngine.h"

#import <AWSS3.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

static float IMAGE_WIDTH = 640;

@interface ShareViewController () <FBSDKGraphRequestConnectionDelegate, FHSTwitterEngineAccessTokenDelegate, UIAlertViewDelegate> {
    
    IBOutlet UIButton *facebookBtn;
    IBOutlet UIButton *twitterBtn;

    BOOL isProgressing;
    NSInteger sharingCount;
}

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sharingCount = 0;
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"SHARE";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIImage *backBtnImage = [UIImage imageNamed:@"icon_backarrow_white"];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    if ([SessionManager currentSession].isFacebookOn) {
        [facebookBtn setSelected:YES];
    } else {
        [facebookBtn setSelected:NO];
    }
    
    if ([SessionManager currentSession].isTwitterOn) {
        [twitterBtn setSelected:YES];
    } else {
        [twitterBtn setSelected:NO];
    }
}

- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAccountAlertLabel:(BOOL)isTwitter {
    if (isTwitter) {
        [UIView animateWithDuration:0.5 animations:^{
            [SRConstant UIAlertViewShow:@"You Don't have Twitter account. Please Sign in Twitter" withTitle:nil];
        } completion:^(BOOL finished){
            
        }];
        [twitterBtn setSelected:NO];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            [SRConstant UIAlertViewShow:@"You Don't have Facebook Account to post. Please Sign in Facebook" withTitle:nil];
        } completion:^(BOOL finished){
            
        }];
        [facebookBtn setSelected:NO];
    }
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height {
    
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

#pragma mark - FacebookPost
- (void)postFacebookWithParams {
    if ([FBSDKAccessToken currentAccessToken] == nil) {
        sharingCount --;
        if (sharingCount == 0) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        [self showAccountAlertLabel:NO];
        
    } else {
        NSString *appendString;
        if ([SessionManager currentSession].postData.postStatus == SRGoodStatus) {
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Rated GOOD on SpotReview"];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica Neue Bold" size:19.0] range:NSRangeFromString(@"GOOD")];
            appendString = [attributedString string];
           
        } else {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Rated BAD on SpotReview"];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica Neue Bold" size:19.0] range:NSRangeFromString(@"BAD")];
            appendString = [attributedString string];
        }
        NSString * postMessage = [NSString stringWithFormat:@"%@\n%@", [SessionManager currentSession].postData.postedContent,appendString];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:postMessage forKey:@"message"];
        [params setObject:UIImagePNGRepresentation([SessionManager currentSession].postData.postedImage) forKey:@"picture"];
        FBSDKGraphRequest *fbRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/photos" parameters:params HTTPMethod:@"POST"];
        FBSDKGraphRequestConnection *fbConnection = [[FBSDKGraphRequestConnection alloc] init];
        fbConnection.delegate = self;
        [fbConnection addRequest:fbRequest completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSDictionary * tempObj =(NSDictionary *)result;
                
                NSString * photo_id = [tempObj objectForKey:@"id"];
                NSLog(@"Facebook photo Post ID : %@",photo_id);
            } else {
                NSLog(@"Facebook Photo post Error");
            }
        }];
        [fbConnection start];
    }
}

#pragma mark - FBGraphRequestConnectionDelegate
- (void)requestConnection:(FBSDKGraphRequestConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"RequestConnection Error");
    sharingCount --;
    
    if (sharingCount == 0) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
//    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Facebook Connection Error" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
}

- (void)requestConnectionDidFinishLoading:(FBSDKGraphRequestConnection *)connection {
    NSLog(@"RequestConnection Finish");
    
    sharingCount --;
    if (sharingCount == 0) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [[[UIAlertView alloc] initWithTitle:nil message:@"Shared successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
    }
}

#pragma mark - TwitterPost
- (void)postTwitterWithParams {
    
    NSString *appendString;
    if ([SessionManager currentSession].postData.postStatus == SRGoodStatus) {
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Rated GOOD on SpotReview"];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica Neue Bold" size:19.0] range:NSRangeFromString(@"GOOD")];
        appendString = [attributedString string];
        
    } else {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"Rated BAD on SpotReview"];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica Neue Bold" size:19.0] range:NSRangeFromString(@"BAD")];
        appendString = [attributedString string];
    }
    
    NSString * postMessage = [NSString stringWithFormat:@"%@\n%@", [SessionManager currentSession].postData.postedContent, appendString];
    
    UIImage *imgTaken = [SessionManager currentSession].postData.postedImage;
    CGFloat height = imgTaken.size.height * IMAGE_WIDTH/imgTaken.size.width;
    imgTaken = [self resizeImage:imgTaken toWidth:IMAGE_WIDTH andHeight:height];
    NSData *dataImage = UIImageJPEGRepresentation(imgTaken, 0.25);
    
    if ([[FHSTwitterEngine sharedEngine] isAuthorized]) {
        NSError *error;
        error = [[FHSTwitterEngine sharedEngine] postTweet:postMessage withImageData:dataImage];
        if (error == nil) {
            sharingCount --;
            if (sharingCount == 0) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [[[UIAlertView alloc] initWithTitle:nil message:@"Shared successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        } else {
            sharingCount --;
            if (sharingCount == 0) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        }
    } else {
        [self showAccountAlertLabel:YES];
        sharingCount --;
    }
}

#pragma mark - FHSTwitterEngineAccessTokenDelegate
- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAcce/ssHTTPBody"];
}

- (void)twitterEngineControllerDidCancel {
    [twitterBtn setSelected:NO];
    [SessionManager currentSession].isTwitterOn = NO;
}

#pragma mark - UIButtonEvents
- (IBAction)onSubmit:(id)sender {
    
    if ([facebookBtn isSelected] == YES) {
        sharingCount ++;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        isProgressing = YES;
//        [self postFacebookWithParams];
        [self performSelectorOnMainThread:@selector(postFacebookWithParams) withObject:nil waitUntilDone:NO];
    } else {
        isProgressing = NO;
    }
    
    if ([twitterBtn isSelected]) {
        if (!isProgressing) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        sharingCount ++;
//        [self postTwitterWithParams];
        [self performSelectorOnMainThread:@selector(postTwitterWithParams) withObject:nil waitUntilDone:NO];
    }
//    [self postTwitterWithParams];
}

- (IBAction)onFacebookPost:(id)sender {
    if ([facebookBtn isSelected]) {
        [facebookBtn setSelected:NO];
        [SessionManager currentSession].isFacebookOn = NO;
    } else {
        if ([FBSDKAccessToken currentAccessToken] == nil) {
            // OPEN Session!
            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
            [login logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                
                if (error != nil) {
                    [[[UIAlertView alloc] initWithTitle:@"Facebook Login Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [facebookBtn setSelected:NO];
                    [SessionManager currentSession].isFacebookOn = NO;
                } else if (result.isCancelled) {
                    [facebookBtn setSelected:NO];
                    [SessionManager currentSession].isFacebookOn = NO;
                    return;
                } else {
                    if ([result.grantedPermissions containsObject:@"publish_actions"]) {
                        [facebookBtn setSelected:YES];
                        [SessionManager currentSession].isFacebookOn = YES;
                    } else {
                        [SessionManager currentSession].isFacebookOn = NO;
                    }
                }
            }];
            
        } else {
            [facebookBtn setSelected:YES];
            [SessionManager currentSession].isFacebookOn = YES;
        }
    }
}

- (IBAction)onTwitterPost:(id)sender {
    if ([twitterBtn isSelected]) {
        [twitterBtn setSelected:NO];
        [SessionManager currentSession].isTwitterOn = NO;
    } else {
        if ([[FHSTwitterEngine sharedEngine] isAuthorized]) {
            NSLog(@"Twitter has Authorized");
            [twitterBtn setSelected:YES];
            [SessionManager currentSession].isTwitterOn = YES;
        } else {
            UIViewController *twitterLoginController = [[FHSTwitterEngine sharedEngine] loginControllerWithCompletionHandler:^(BOOL success) {
                
                [self loadAccessToken];
                [twitterBtn setSelected:YES];
                [SessionManager currentSession].isTwitterOn = YES;
            }];
            [self presentViewController:twitterLoginController animated:YES completion:nil];
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)];
    
    [NSThread sleepForTimeInterval:2.0];
    
    exit(0);
}

@end
