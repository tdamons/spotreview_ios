//
//  SRPostData.h
//  SpotReview
//
//  Created by lion on 11/5/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SRGoodStatus = 1,
    SRBadStatus = 2,
    SRNonStatus = 0
} SRPostStatus;

@interface SRPostData : NSObject

@property (nonatomic, strong) UIImage *postedImage;
@property (nonatomic, strong) NSString *postedTitle;
@property (nonatomic, strong) NSString *postedContent;
@property (nonatomic) SRPostStatus postStatus;

@end
