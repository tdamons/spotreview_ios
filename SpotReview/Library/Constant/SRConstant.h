//
//  SRConstant.h
//  SpotReview
//
//  Created by lion on 10/22/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ROOT_STORYID                @"rootController"
#define HOME_STORYID                @"mainController"
#define HOMENAV_STORYID             @"homeNavController"
#define MENU_STORYID                @"menuTableController"
#define REGISTER_STORYID            @"registerController"
#define FORGOTPWD_STORYID           @"forgotPasswordController"
#define HOMENAV_STORYID             @"homeNavController"
#define RATE_STORYID                @"rateController"
#define COMMENT_STORYID             @"commentController"
#define COMMENTCHECK_STORYID        @"commentCheckController"
#define CHECKTOP_STORYID            @"checkTopController"
#define CHECKPOST_STORYID           @"postCheckController"
#define TOPSPOTS_STORYID            @"topSpotsController"
#define SPOTDETAIL_STORYID          @"spotDetailController"
#define SPOTIMAGE_CONTROLLER        @"spotImageController"
#define PROFILE_STORYID             @"profileController"
#define REVIEWLIST_STORYID          @"reviewListController"
#define SEARCH_STORYID              @"searchController"
#define ENTERCAMPAIGN_STORYID       @"enterCampaignController"
#define ABOUT_STORYID               @"aboutUsController"
#define CAMPAIGNMODE_STORYID        @"campaignModeController"
#define CONTACTUS_STORYID           @"contactUsController"
#define BUYSERVICE_STORYID          @"buyServiceController"

#define SR_CURRENT_USER             @"savedCurrentUser"
#define LOGIN_USEREMAIL             @"SavedUserEmail"
#define LOGIN_PASSWORD              @"SavedPassword"
#define LOGIN_TWITTER_NAME          @"SavedTwitterName"
#define LOGIN_TWITTER_ID            @"SavedTwitterID"

#define APP_MAIN_COLOR [UIColor colorWithRed:0.0/255.0 green:128.0/255.0 blue:0.0/255.0 alpha:0]

//Server API
#define SERVER_URL @"http://52.32.90.234/api/"
//#define SERVER_URL @"http://172.16.1.61:8080/api/"

#define API_LOGIN               @"publicapi/login"
#define API_REGISTER            @"publicapi/register"
#define API_POST                @"post/addpost"
#define API_GET_TOPSPOTS        @"post/gettopbrands"
#define API_GET_BADSPOTS        @"post/getbadbrands"
#define API_GET_SPOTSBYUSERID   @"post/getbrandsbyuserid"
#define API_GET_BRANDS          @"post/getbrands"
#define API_GET_SEARCHBRANDS    @"post/getsearchbrands"
#define API_FACEBOOK_LOGIN      @"publicapi/facebooklogin"
#define API_TWITTER_LOGIN       @"publicapi/twitterlogin"
#define API_UPDATE_USER         @"user/updateuser"
#define API_GET_CAMPAIGNCODES   @"campaign/getcampaigns"
#define API_GET_SEARCHCAMPAIGNS @"campaign/getsearchcampaigns"
#define API_CHECK_CAMPAIGNCODE  @"campaign/checkcampaigncode"
#define API_GET_COMPANYDETAILS  @"post/getcompanydetails"
#define API_GET_COMPANYDETAILS_FORUSER  @"post/getcompanydetailsforuser"

//Twitter
extern NSString *const kTwitterConsumerKey;
extern NSString *const kTwitterConsumerSecret;
extern NSString *const kTwitterBaseUrl;

@interface SRConstant : NSObject

//AWS S3
extern NSString *const kImageBucket;
extern NSString *const kAvatarImageBucket;

extern NSString *const kCognitoPoolID;
extern NSString *const kS3ImagePath;
extern NSString *const kS3AvatarImagePath;

+ (void)UIAlertViewShow:(NSString *)message withTitle:(NSString *)title;
+ (BOOL)NSStringIsValidEmail:(NSString *)checkString;
+ (BOOL)validatePhone:(NSString *)phoneNumber;

@end
