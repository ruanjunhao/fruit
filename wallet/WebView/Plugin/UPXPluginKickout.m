//
//  UPXPluginKickout.m
//  wallet
//
//  Created by qcao on 15/1/21.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPXPluginKickout.h"
#import "UPWNotificationName.h"
#import "UPWHttpMgr.h"

@implementation UPXPluginKickout


- (void)onKickout:(CDVInvokedUrlCommand *)command
{
    NSString* msg = [command.arguments firstObject];
    
    [UPWHttpMgr instance].hasKey = NO;
    //登录超时或者被踢出,抛出一个通知, 通知 baseViewController 去处理, 弹一个 alert, 点重新登录登录
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginKicked object:msg];
    UPDERROR(@"UPXPluginKickout onKickout");
    CDVPluginResult* result =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
