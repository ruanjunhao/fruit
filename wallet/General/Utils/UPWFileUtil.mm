//
//  UPWFileUtil.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-30.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWFileUtil.h"
#import "UPXProguardUtil.h"
#import "UPXCryptUtil.h"

@implementation UPWFileUtil

+ (void)writeContent:(id)content path:(NSString*)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
    {
        [fileManager removeItemAtPath:path error:nil];
    }
    
    NSString* utf8String = [self UTF8Encode:content];

    UPXProguardUtil* utl = new UPXProguardUtil(EProjectClientV3);
    char* res = NULL;
    utl->encryptData([utf8String UTF8String],&res);
    NSString* result = [NSString stringWithUTF8String:res];
    delete utl;
    
    NSError* err = nil;
    BOOL success = [result writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err];
    if (!success) {
        UPDERROR(@"writeContent %@ failed = %@",path,err);
    }
}

+ (id)readContent:(NSString*)path
{
    NSError* err = nil;
    NSString* utf8String = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    if (err) {
        UPDERROR(@"readContent %@ failed = %@",path,err);
        return nil;

    }
    id content;
    if (utf8String) {
        
        UPXProguardUtil* utl = new UPXProguardUtil(EProjectClientV3);
        char* des = NULL;
        utl->decryptData([utf8String UTF8String],&des);
        NSString *resultStr= [NSString stringWithUTF8String:des];
        content = [self UTF8Decode:resultStr];
    }
    return content;
}

+ (void)removeFile:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
    {
        [fileManager removeItemAtPath:path error:nil];
    }
}


+ (NSString*)UTF8Encode:(id)obj
{
    NSData* data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    NSString* encodedMsg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return encodedMsg;
}

+ (id)UTF8Decode:(NSString*)utf8String
{
    NSData* data = [utf8String dataUsingEncoding:NSUTF8StringEncoding];
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    return obj;
}



@end
