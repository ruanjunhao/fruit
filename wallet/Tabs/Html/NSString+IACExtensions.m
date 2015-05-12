//
//  NSString+IACExtensions.m
//  IACSample
//
//  Created by Antonio Cabezuelo Vivo on 10/02/13.
//  Copyright (c) 2013 Antonio Cabezuelo Vivo. All rights reserved.
//

#import "NSString+IACExtensions.h"

@implementation NSString (IACExtensions)

- (NSDictionary*)parseURLParams {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    NSArray *pairs = [self componentsSeparatedByString:@"&"];
    
    [pairs enumerateObjectsUsingBlock:^(NSString *pair, NSUInteger idx, BOOL *stop) {
        NSArray *comps = [pair componentsSeparatedByString:@"="];
        if ([comps count] == 2) {
            [result setObject:[comps[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:comps[0]];
        }
    }];
    
    return result;
}

- (NSString*)stringByAppendingURLParams:(NSDictionary*)params {
    if([params count] == 0) {
        return self;
    }
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    [result appendString:self];
    
    if ([result rangeOfString:@"?"].location != NSNotFound) {
        if (![result hasSuffix:@"&"])
            [result appendString:@"&"];
    } else {
        [result appendString:@"?"];
    }
    
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *escapedObj = obj;
        if ([obj isKindOfClass:[NSString class]]) {
            escapedObj = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)obj, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
        }
        [result appendFormat:@"%@=%@&", key, escapedObj];
    }];
    
    if([result hasSuffix:@"&"]) {
        [result deleteCharactersInRange:NSMakeRange(result.length - 1, 1)];
    }
    
    return result;
}

- (NSString *)stringByAppendingSubUrl:(NSString *)subUrl
{
    if(subUrl.length == 0) {
        return self;
    }
    
    NSString * url;
    if([[NSURL URLWithString:subUrl] scheme].length == 0) {
        // subUrl是短字段。
        url = self;
        
        // 去除重复"//"
        if([url hasSuffix:@"/"]) {
            url = [self substringToIndex:(url.length - 1)];
        }
        
        if([subUrl hasPrefix:@"/"]) {
            subUrl = [subUrl substringFromIndex:1];
        }
        
        url = [url stringByAppendingFormat:@"/%@", subUrl];
    }
    else {
        // subUrl是全URL。
        url = subUrl;
    }
    
    return url;
}
@end
