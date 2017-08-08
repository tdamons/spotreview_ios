//
//  SRUser.m
//  SpotReview
//
//  Created by lion on 10/27/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "SRUser.h"

@implementation SRUser

- (id)initWithDictionary:(NSDictionary*)jsonObj {
    self = [super init];
    
    if (self) {
        self.userId = [self integerFromDictionary:jsonObj forKey:@"user_id"];
        self.userName = [self stringFromDictionary:jsonObj forKey:@"user_name"];
        self.email = [self stringFromDictionary:jsonObj forKey:@"user_email"];
        self.userTelNumber = [self stringFromDictionary:jsonObj forKey:@"user_mobilenumber"];
        self.userSecQuestion = [self stringFromDictionary:jsonObj forKey:@"user_secquestion"];
        self.userAnswer = [self stringFromDictionary:jsonObj forKey:@"user_answer"];
        self.userType = [self integerFromDictionary:jsonObj forKey:@"user_type"];
        self.facebookId = [self stringFromDictionary:jsonObj forKey:@"facebook_id"];
        self.twitterId = [self stringFromDictionary:jsonObj forKey:@"twitter_id"];
        self.userAvatarPath = [self stringFromDictionary:jsonObj forKey:@"user_avatarpath"];
    }
    return self;
}


#pragma mark - NSCodingMethods
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.userId forKey:@"userID"];
    [encoder encodeInt:self.userType forKey:@"userType"];
    [encoder encodeObject:self.userName forKey:@"userName"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.userTelNumber forKey:@"user_mobilenumber"];
    [encoder encodeObject:self.userSecQuestion forKey:@"user_secquestion"];
    [encoder encodeObject:self.userAnswer forKey:@"user_answer"];
    [encoder encodeObject:self.facebookId forKey:@"facebookId"];
    [encoder encodeObject:self.twitterId forKey:@"twitterId"];
    [encoder encodeObject:self.userAvatarPath forKey:@"userAvatarPath"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.userId = [decoder decodeIntegerForKey:@"userID"];
        self.userType = [decoder decodeIntForKey:@"userType"];
        self.userName = [decoder decodeObjectForKey:@"userName"];
        self.userAvatarPath = [decoder decodeObjectForKey:@"userAvatarPath"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.userTelNumber = [decoder decodeObjectForKey:@"user_mobilenumber"];
        self.userSecQuestion = [decoder decodeObjectForKey:@"user_secquestion"];
        self.userAnswer = [decoder decodeObjectForKey:@"user_answer"];
        self.facebookId = [decoder decodeObjectForKey:@"facebookId"];
        self.twitterId = [decoder decodeObjectForKey:@"twitterId"];
    }
    return self;
}

@end
