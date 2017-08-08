//
//  SRUser.h
//  SpotReview
//
//  Created by lion on 10/27/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "SRObject.h"

typedef enum {
    SRUserEmail = 0,
    SRUserFacebook = 1,
    SRUserTwitter = 2
} SRUserType;

@interface SRUser : SRObject

@property (nonatomic) NSInteger userId;
@property (nonatomic) SRUserType userType;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userAvatarPath;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *userTelNumber;
@property (nonatomic, strong) NSString *userSecQuestion;
@property (nonatomic, strong) NSString *userAnswer;
@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) NSString *twitterId;

- (id)initWithDictionary:(NSDictionary*)jsonObj;

@end
