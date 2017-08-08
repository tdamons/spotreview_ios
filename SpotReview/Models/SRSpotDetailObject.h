//
//  SRSpotDetailObject.h
//  SpotReview
//
//  Created by lion on 11/26/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "SRObject.h"
#import "SRPostData.h"

@interface SRSpotDetailObject : SRObject

@property (nonatomic, strong) NSString *userAvatarPath;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic) SRPostStatus postStatus;
@property (nonatomic, strong) NSString *companyImagePath;
@property (nonatomic, strong) NSString *spotDescription;
@property (nonatomic, strong) NSString *spotCreatedDate;

- (id)initWithDictionary:(NSDictionary*)jsonObj;

@end
