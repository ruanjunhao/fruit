//
//  UPExNSArray.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 14-3-20.
//
//

#import "UPExNSArray.h"

@implementation NSArray (UPXExtensions)

- (NSString *)description
{
    NSMutableString* descriptionString = [[NSMutableString alloc] init] ;
    [descriptionString appendString:@"\n(\n"];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [descriptionString appendFormat:@"\t%@,\n",[obj description]];

    }];
    NSRange range = [descriptionString rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        [descriptionString replaceOccurrencesOfString:@"," withString:@"" options:NSBackwardsSearch range:range];
    }
    [descriptionString appendString:@")\n"];
    
    return descriptionString;
}

@end
