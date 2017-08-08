//
//  SRConstant.m
//  SpotReview
//
//  Created by lion on 10/22/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRConstant.h"

@implementation SRConstant

//AWS S3
NSString *const kImageBucket = @"spot-logo-usstandard";
NSString *const kAvatarImageBucket = @"spot-avatar-usstandard";
NSString *const kCognitoPoolID = @"us-east-1:445ba5d2-1ea9-44f3-bab5-72d7b2b48edd";
NSString *const kS3ImagePath = @"https://s3.amazonaws.com/spot-logo-usstandard/";
NSString *const kS3AvatarImagePath = @"https://s3.amazonaws.com/spot-avatar-usstandard/";

//Twitter
NSString *const kTwitterConsumerKey = @"70MgLoFi2cNRkeirbHCkDNWKx";
NSString *const kTwitterConsumerSecret = @"gi1BxyYKVu5boQxOOoBqEuKNWxbA6mmhXfHaNbaySQ5f6KWhMg";
NSString *const kTwitterBaseUrl = @"https://api.twitter.com";

+ (void)UIAlertViewShow:(NSString *)message withTitle:(NSString *)title {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

+ (BOOL)NSStringIsValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (BOOL)validatePhone:(NSString *)phoneNumber {
    NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    
    return [phoneTest evaluateWithObject:phoneNumber];
}

@end
