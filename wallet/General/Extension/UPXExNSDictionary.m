//
//  UPExNSDictionary.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-5-22.
//
//

#import "UPXExNSDictionary.h"
#import <objc/runtime.h>
#import <objc/message.h>

#import "UPWMarco.h"
#import "UPWAppUtil.h"




@implementation NSDictionary (UPXExtensions)



- (NSString *)description
{
    NSMutableString* descriptionString = [[NSMutableString alloc] init];
    [descriptionString appendString:@"\n{\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        [descriptionString appendFormat:@"\t%@ = %@,\n",[key description],[obj description]];
    }];
    
    NSRange range = [descriptionString rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        [descriptionString replaceOccurrencesOfString:@"," withString:@"" options:NSBackwardsSearch range:range];
    }
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

- (float)floatForKey_upex:(NSString *)keyName
{
    float ret = [[self objectForKey:keyName] floatValue];
    if (UP_ISRETINA)
    {
        ret /= 2.0;
    }
    return ret;
}

- (CGSize)sizeForKey_upex:(NSString *)keyName
{
    CGSize    ret       = CGSizeZero;
    NSString *stringVal = [self objectForKey:keyName];
    NSArray  *componets = [stringVal componentsSeparatedByString:@","];
    if ([componets count] == 2)
    {
        ret = CGSizeMake([[componets objectAtIndex:0] intValue], [[componets objectAtIndex:1] intValue]);
    }
    
    if (UP_ISRETINA)
    {
        ret.width  /= 2.0;
        ret.height /= 2.0;
    }
    return ret;
}

- (CGRect)rectForKey_upex:(NSString *)keyName
{
    CGRect    ret       = CGRectZero;
    NSString *stringVal = [self  objectForKey:keyName];
    NSArray  *componets = [stringVal componentsSeparatedByString:@","];
    if ([componets count] == 4)
    {
        ret = CGRectMake([[componets objectAtIndex:0] intValue], [[componets objectAtIndex:1] intValue],
                         [[componets objectAtIndex:2] intValue], [[componets objectAtIndex:3] intValue]);
    }
    
    if (UP_ISRETINA)
    {
        ret.origin.x    /= 2.0;
        ret.origin.y    /= 2.0;
        ret.size.width  /= 2.0;
        ret.size.height /= 2.0;
    }
    return ret;
}


- (CGRect)rectForKey_upexTheme:(NSString *)keyName
{
    CGRect    ret       = CGRectZero;
    NSString *stringVal = [self  objectForKey:keyName];
    NSArray  *componets = [stringVal componentsSeparatedByString:@","];
    if ([componets count] == 4)
    {
        ret = CGRectMake([[componets objectAtIndex:0] intValue], [[componets objectAtIndex:1] intValue],
						 [[componets objectAtIndex:2] intValue], [[componets objectAtIndex:3] intValue]);
    }
    return ret;
}

- (CGPoint)pointForKey_upex:(NSString *)keyName
{
    CGPoint   ret       = CGPointZero;
    NSString *stringVal = [self  objectForKey:keyName];
    NSArray  *componets = [stringVal componentsSeparatedByString:@","];
    if ([componets count] == 2)
    {
        ret = CGPointMake([[componets objectAtIndex:0] intValue], [[componets objectAtIndex:1] intValue]);
    }
    
    if (UP_ISRETINA)
    {
        ret.x /= 2.0;
        ret.y /= 2.0;
    }
    return ret;
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
    [self setValue:@(value) forKey:keyName];
}

-(void)setInteger_upex:(NSInteger)value forKey:(NSString*)keyName
{
    [self setValue:@(value) forKey:keyName];
}

- (BOOL)writeToFile_upex:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
    return [[NSPropertyListSerialization dataWithPropertyList:self
                                                       format:NSPropertyListBinaryFormat_v1_0
                                                      options:0 error:nil]
            writeToFile:path atomically:useAuxiliaryFile];
}




@end
