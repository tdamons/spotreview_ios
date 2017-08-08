//
//  SessionManager.h
//  SpotReview
//
//  Created by lion on 10/27/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "SRObject.h"
#import "SRUser.h"
#import "SRPostData.h"
#import "SRCampaignObject.h"

typedef enum {
    SRCampaign = 1,
    SRNormal = 2
} SRCampaignMode;

@interface SessionManager : SRObject

+ (SessionManager *)currentSession;

@property (nonatomic, strong) SRUser *userInfo;
@property (nonatomic, strong) SRPostData *postData;
@property (nonatomic) BOOL isFacebookOn;
@property (nonatomic) BOOL isTwitterOn;
@property (nonatomic) SRCampaignMode campaignMode;
@property (nonatomic,strong) SRCampaignObject *campaignData;

- (void)initPostedData;

@end
