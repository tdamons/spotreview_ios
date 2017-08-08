//
//  SRObject.h
//  SpotReview
//
//  Created by lion on 10/27/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRObject : NSObject

- (NSString*)stringFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (double)doubleFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (float)floatFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (int)integerFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (long)longFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (long long)longLongFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (BOOL)boolFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (NSDictionary*)dictionaryFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey ;
- (NSArray*)arrayFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;

@end
