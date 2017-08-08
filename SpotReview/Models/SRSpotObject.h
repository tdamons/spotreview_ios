//
//  SRSpotObject.h
//  SpotReview
//
//  Created by lion on 11/1/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "SRObject.h"

@interface SRSpotObject : SRObject

@property (nonatomic, strong) NSString *spotCompanyName;
@property (nonatomic, strong) NSString *spotImageUrl;
@property (nonatomic, strong) NSString *spotDescription;
@property (nonatomic, strong) NSString *spotCreatedDate;

@property (nonatomic) NSInteger goodNumber;
@property (nonatomic) NSInteger badNumber;

- (id)initWithDictionary:(NSDictionary*)jsonObj;

@end
