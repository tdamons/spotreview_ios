//
//  SRCampaignObject.h
//  SpotReview
//
//  Created by lion on 11/24/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "SRObject.h"

@interface SRCampaignObject : SRObject

@property (nonatomic) NSInteger campaignId;
@property (nonatomic, strong) NSString *campaignCode;
@property (nonatomic, strong) NSString *campaignBranding;
@property (nonatomic, strong) NSString *campaignName;
@property (nonatomic, strong) NSString *created_date;

- (id)initWithDictionary:(NSDictionary*)jsonObj;

@end
