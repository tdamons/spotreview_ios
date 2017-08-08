//
//  SRCampaignObject.m
//  SpotReview
//
//  Created by lion on 11/24/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "SRCampaignObject.h"

@implementation SRCampaignObject

- (id)initWithDictionary:(NSDictionary*)jsonObj {
    self = [super init];
    
    if (self) {
        self.campaignId = [self integerFromDictionary:jsonObj forKey:@"campaign_id"];
        self.campaignCode = [self stringFromDictionary:jsonObj forKey:@"campaign_code"];
        self.campaignBranding = [self stringFromDictionary:jsonObj forKey:@"campaign_branding"];
        self.campaignName = [self stringFromDictionary:jsonObj forKey:@"campaign_name"];
    }
    return self;
}

@end
