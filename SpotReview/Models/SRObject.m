//
//  SRObject.m
//  SpotReview
//
//  Created by lion on 10/27/15.
//  Copyright (c) 2015 lion. All rights reserved.
//

#import "SRObject.h"

@implementation SRObject

- (NSString*)stringFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(stringValue)]) {
                newObject = [newObject stringValue];
            }
            return newObject;
        }
    }
    
    return @"";
}

- (double)doubleFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(doubleValue)]) {
                return [newObject doubleValue];
            }
        }
    }
    
    return 0.0;
}

- (float)floatFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(floatValue)]) {
                return [newObject floatValue];
            }
        }
    }
    
    return 0.0f;
}

- (int)integerFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(intValue)]) {
                return [newObject intValue];
            }
        }
    }
    
    return 0;
}

- (BOOL)boolFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(boolValue)]) {
                return [newObject boolValue];
            }
        }
    }
    
    return NO;
}

- (long)longFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(longValue)]) {
                return [newObject longValue];
            } else {                if ([newObject respondsToSelector:@selector(integerValue)]) {
                return [newObject integerValue];
            }
            }
        }
    }
    
    return 0;
}

- (long long)longLongFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(longLongValue)]) {
                return [newObject longLongValue];
            }
        }
    }
    
    return 0;
}

- (NSDictionary*)dictionaryFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject isKindOfClass:[NSDictionary class]]) {
                return newObject;
            }
        }
    }
    return [NSDictionary dictionary];
}

- (NSArray*)arrayFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject isKindOfClass:[NSArray class]]) {
                return newObject;
            }
        }
    }
    return [NSArray array];
}

@end
