//
//  UPWCryptUtil.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-28.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWCryptUtil.h"
#import "UPXCryptUtil.h"
#import "UPXProguardUtil.h"
#import "UPXClientCryptWrapper.h"
#include "UPXHexCode.h"

@implementation UPWCryptUtil

+ (void)printCode
{
    const char* key = "2202465287396787740046150200454790595461883994349983118431469053274840629443021672044537096208353611767096784757388899449148893671901756950946127258780796349627375674784682003051529912304373190150173261324063843903777946696348841848795101238805644358663970719225127556664544047889006996922741991688156131115776960463851906243979512343101498905754033417368929985054431986769713429427297586946088694869977087824551271992473597324241191676895655715160504443185688893690023264376038983301404250197187093830120985146034950958662618063316705658393083863144095326132167865725892510094752079806312089025385118369612422836033";
    
    UPXProguardUtil* utl = new UPXProguardUtil(EProjectClientV3);
    char* res = NULL;
    utl->encryptData(key,&res);
    UPDINFO(@"res = %s",res);
    
    UPXCryptUtil* cy = new UPXCryptUtil();
    cy->setPublicKey(key);
    char* output = NULL;
    cy->rsaEncryptMsg("hello world", &output);
    printf("cy = %s\n",output);
    
    char* des = NULL;
    utl->decryptData(res,&des);
    
    int r = strcmp(des, key);
    UPDINFO(@"cmp  = %d",r);
    delete []res;
    delete []des;
    
    
    delete utl;
    
}

+ (void)setKey:(NSString*)key
{
    UPXClientCryptWrapper* wrapper = UPXClientCryptWrapper::instance();
    char* out = NULL;
    wrapper->desDecryptMsg([key UTF8String], &out);
//    char* hex = NULL;
//    UPClientV3Ex::UPXHexDecode((unsigned char *)out,(int)strlen(out),&hex);
    printf("setkey %s",out);
    wrapper->setSessionKey(out);
//    free(hex);
    free(out);
}

#pragma mark -
#pragma mark 加解密报文

+ (NSString*)encryptMessage:(NSString*)msg
{
    NSString * result = nil;
    
    @synchronized(self)
    {
        char* tmp = NULL;
        UPXClientCryptWrapper* wrapper = UPXClientCryptWrapper::instance();
        bool res = wrapper->desEncryptMsg([msg UTF8String], &tmp);
        if (res) {
            result = [NSString stringWithUTF8String:tmp];
            free(tmp);
        }
    };
    return result;
}

+ (NSString*)decryptMessage:(NSString*)msg
{
    NSString * result = nil;
    @synchronized(self)
    {
        char* tmp = NULL;
        UPXClientCryptWrapper* wrapper = UPXClientCryptWrapper::instance();
        bool res = wrapper->desDecryptMsg([msg UTF8String], &tmp);
        if (res) {
            result = [NSString stringWithUTF8String:tmp];
            free(tmp);
        }
    }
    return result;
}


#pragma mark - 生成密钥

+ (NSString*)generateSessionKey
{
    char* encSessionKey = NULL;
    UPXClientCryptWrapper* wrapper = UPXClientCryptWrapper::instance();
    wrapper->rsaEncryptSessionKey(&encSessionKey);
    return [NSString stringWithCString:encSessionKey encoding:NSUTF8StringEncoding];
}



@end
