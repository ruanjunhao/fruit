//
//  NSDictionary+UPEx.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-26.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "NSDictionary+UPEx.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSDictionary (UPEx)


- (NSString *)description
{
    NSMutableString* descriptionString = [[NSMutableString alloc] init];
    [descriptionString appendString:@"\n{\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        [descriptionString appendFormat:@"\t%@ = %@,\n",[key description],[obj description]];
    }];
    
    NSRange range = [descriptionString rangeOfString:@"," options:NSBackwardsSearch];
    [descriptionString replaceOccurrencesOfString:@"," withString:@"" options:NSBackwardsSearch range:range];
    [descriptionString appendString:@"}\n"];
    
    return descriptionString;
}




- (BOOL)boolForKey_upex:(NSString *)keyName
{
    return [[self objectForKey:keyName] boolValue];
}

- (NSInteger)integerForKey_upex:(NSString *)keyName
{
    return [[self objectForKey:keyName] intValue];
}

- (float)floatForKey_upex_st:(NSString *)keyName
{
    return  [[self objectForKey:keyName] floatValue];
}



- (NSString *)stringForKey_upex:(NSString *)keyName
{
    NSString *ret = [self objectForKey:keyName];
    return ret ? ret : [NSString string];
}

- (NSDictionary *)dictionaryForKey_upex:(NSString *)keyName
{
    return [self objectForKey:keyName];
}

-(void)setBool_upex:(BOOL)value forKey:(NSString*)keyName
{
    [self setValue:[NSNumber numberWithBool:value] forKey:keyName];
}

-(void)setInteger_upex:(NSInteger)value forKey:(NSString*)keyName
{
    [self setValue:[NSNumber numberWithInteger:value] forKey:keyName];
}

- (BOOL)writeToFile_upex:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
    return [[NSPropertyListSerialization dataWithPropertyList:self
                                                       format:NSPropertyListBinaryFormat_v1_0
                                                      options:0 error:nil]
            writeToFile:path atomically:useAuxiliaryFile];
}



@end
