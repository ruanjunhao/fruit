//
//  UPWEnvMgr.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWEnvMgr.h"
#import "UPWEnv.h"

@implementation UPWEnvMgr

#pragma mark -
#pragma mark "获取生产、PM、测试、Debug环境的URL地址"

+ (NSString*)appServerUrl
{
    NSDictionary* urlDict = @{kEnvDebug:kDebugAppUrl,
                              kEnvPM:kPMAppUrl,
                              kEnvTest:kTestAppUrl,
                              kEnvProduct:kProductAppUrl,
                              kEnvLocalWebDebug:kLocalWebDebugAppUrl};
    
    return [[NSString alloc] initWithString:urlDict[kWalletEnv]];
}



+ (NSString*)chspServerUrl
{
    NSDictionary* urlDict = @{kEnvDebug:kDebugChspUrl,
                              kEnvPM:kPMChspUrl,
                              kEnvTest:kTestChspUrl,
                              kEnvProduct:kProductChspUrl,
                              kEnvLocalWebDebug:kLocalWebDebugChspUrl};
    
    return [[NSString alloc] initWithString:urlDict[kWalletEnv]];
}




+ (NSString*)chspImgServerUrl
{
    NSDictionary* urlDict = @{kEnvDebug:kDebugChspImgUrl,
                              kEnvPM:kPMChspImgUrl,
                              kEnvTest:kTestChspImgUrl,
                              kEnvProduct:kProductChspImgUrl,
                              kEnvLocalWebDebug:kLocalWebDebugChspImgUrl};
    
    return [[NSString alloc] initWithString:urlDict[kWalletEnv]];
}

+ (NSString*)gwjServerURL
{
    NSDictionary* urlDict = @{kEnvDebug:kDebugGWJUrl,
                              kEnvPM:kPMGWJUrl,
                              kEnvTest:kTestGWJUrl,
                              kEnvProduct:kProductGWJUrl,
                              kEnvLocalWebDebug:kLocalWebDebugGWJUrl};
    
    return [[NSString alloc] initWithString:urlDict[kWalletEnv]];
}


+ (NSString*)payPluginMode
{
    NSDictionary* urlDict = @{kEnvDebug:kDebugPayPluginMode,
                              kEnvPM:kPMPayPluginMode,
                              kEnvTest:kTestPayPluginMode,
                              kEnvProduct:kProductPayPluginMode,
                              kEnvLocalWebDebug:kLocalWebDebugPayPluginMode};
    
    return [[NSString alloc] initWithString:urlDict[kWalletEnv]];
}

+ (NSString*)trackAppID
{
    NSDictionary* urlDict = @{kEnvDebug:kDebugTrackAppID,
                              kEnvPM:kPMTrackAppID,
                              kEnvTest:kTestTrackAppID,
                              kEnvProduct:kProductTrackAppID,
                              kEnvLocalWebDebug:kLocalWebDebugTrackAppID};
    
    return [[NSString alloc] initWithString:urlDict[kWalletEnv]];
}

+ (NSString*)userAgentMode
{
    NSDictionary* urlDict = @{kEnvDebug:kDebugUserAgentMode,
                              kEnvPM:kPMUserAgentMode,
                              kEnvTest:kTestUserAgentMode,
                              kEnvProduct:kProductUserAgentMode,
                              kEnvLocalWebDebug:kLocalWebDebugUserAgentMode};
    
    return [[NSString alloc] initWithString:urlDict[kWalletEnv]];
}


+ (NSString*)cryptKey
{
    NSDictionary* urlDict = @{kEnvDebug:kDebugCryptKey,
                              kEnvPM:kPMCryptKey,
                              kEnvTest:kTestCryptKey,
                              kEnvProduct:kProductCryptKey,
                              kEnvLocalWebDebug:kLocalWebCryptKey};
    
    return [[NSString alloc] initWithString:urlDict[kWalletEnv]];
}




@end
