//
//  SRSpotDetailObject.m
//  SpotReview
//
//  Created by lion on 11/26/15.
//  Copyright © 2015 lion. All rights reserved.
//

#import "SRSpotDetailObject.h"

@implementation SRSpotDetailObject

- (id)initWithDictionary:(NSDictionary*)jsonObj {
    self = [super init];
    
    if (self) {
        self.userName = [self stringFromDictionary:jsonObj forKey:@"user_name"];
        self.userAvatarPath = [self stringFromDictionary:jsonObj forKey:@"user_avatarpath"];
        self.companyImagePath = [self stringFromDictionary:jsonObj forKey:@"post_imageurl"];
        self.spotDescription = [self stringFromDictionary:jsonObj forKey:@"post_content"];
        self.spotCreatedDate = [self stringFromDictionary:jsonObj forKey:@"created_date"];
        self.postStatus = [self integerFromDictionary:jsonObj forKey:@"post_status"];
    }
    return self;
}

@end
