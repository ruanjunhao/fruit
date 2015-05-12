//
//  UPWEnvMgr.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPWEnvMgr : NSObject

//app 服务器地址
+ (NSString*)appServerUrl;

//chsp 服务器地址
+ (NSString*)chspServerUrl;

//chsp 图片服务器地址，以及3.0姜昆那边的WEB页面
+ (NSString*)chspImgServerUrl;

//缴费验证码
+ (NSString*)gwjServerURL;

//支付控件模式
+ (NSString*)payPluginMode;

//信息收集的 app ID
+ (NSString*)trackAppID;

//web 端 User Agent
+ (NSString*)userAgentMode;

+ (NSString*)cryptKey;

@end
