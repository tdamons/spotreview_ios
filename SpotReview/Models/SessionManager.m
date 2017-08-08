//
//  SessionManager.m
//  SpotReview
//
//  Created by lion on 10/27/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "SessionManager.h"

@implementation SessionManager

static SessionManager *currentSession;

+ (SessionManager*)currentSession {
    if (currentSession == nil) {
        currentSession = [[SessionManager alloc] init];
    }
    return currentSession;
}

- (void)setUserInfo:(SRUser *)userInfo {
    _userInfo = userInfo;
    
    NSData *archivedUser = [NSKeyedArchiver archivedDataWithRootObject:_userInfo];
    [[NSUserDefaults standardUserDefaults] setObject:archivedUser forKey:SR_CURRENT_USER];
}

- (void)setPostData:(SRPostData *)postData {
    _postData = postData;
}

- (void)setCampaignData:(SRCampaignObject *)campaignData {
    _campaignData = campaignData;
}

- (void)initPostedData {
    self.postData.postedImage = [[UIImage alloc] init];
    self.postData.postedContent = @"";
    self.postData.postedTitle = @"";
    self.postData.postStatus = SRNonStatus;
}

@end
