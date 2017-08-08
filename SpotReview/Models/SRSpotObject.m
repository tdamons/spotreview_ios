//
//  SRSpotObject.m
//  SpotReview
//
//  Created by lion on 11/1/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "SRSpotObject.h"

@implementation SRSpotObject

- (id)initWithDictionary:(NSDictionary*)jsonObj {
    self = [super init];
    
    if (self) {
        self.spotCompanyName = [self stringFromDictionary:jsonObj forKey:@"post_title"];
        self.spotDescription = [self stringFromDictionary:jsonObj forKey:@"post_content"];
        self.spotImageUrl = [self stringFromDictionary:jsonObj forKey:@"post_imageurl"];
        self.spotCreatedDate = [self stringFromDictionary:jsonObj forKey:@"created_date"];
        self.goodNumber = [self integerFromDictionary:jsonObj forKey:@"good"];
        self.badNumber = [self integerFromDictionary:jsonObj forKey:@"bad"];
    }
    return self;
}

@end
