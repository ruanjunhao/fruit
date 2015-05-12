//
//  UPXWebAppPayPlugin.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-8-21.
//
//

#import "UPXPluginPay.h"
#import "UPPayPluginPro.h"
#import "AppDelegate.h"
#import "UPWWebViewController.h"
#import "UPWMarco.h"
#import "UPXConstKey.h"
#import "UPXConstStrings.h"
#import "UPXUtils.h"
#import "UPWBussUtil.h"

@implementation UPXPluginPay

@synthesize callbackId;



- (void)pluginInitialize
{
    [super pluginInitialize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoPayPlugin:)
                  name:kUPXNotfifcationWebPluginPayOrderPrehandle
                object:nil];
}

- (void)pay:(CDVInvokedUrlCommand *)command
{
    UPDSTART();
    self.command = command;
    self.callbackId = command.callbackId;
    NSString* arg = [command.arguments firstObject];
    UPDINFO(@"arg %@",arg);
    NSDictionary *params = [UPXUtils dictionaryFromCordovaArgument:arg];
    if (params) {

        UPWWebViewController* viewController = (UPWWebViewController*) self.viewController;
        [viewController gotoPayPluginCode:kUPWebPluginPayToJSResultCodeSuccess message:@""];
    }
    else{
        NSDictionary *userInfo = @{kUPWebPluginPayToJSResultCode: kUPWebPluginPayToJSResultCodeFailed,
                                   kUPWebPluginPayToJSResultMessage: UP_STR(kUPWebPluginPayToJSMessageWrongArgument)};
        CDVPluginResult* rt = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:userInfo];
        [self.commandDelegate sendPluginResult:rt callbackId:self.callbackId];
    }

    UPDEND();
}

-(void)UPPayPluginResult:(NSString*)result
{
    UP_App.isUPPayPluginShow = NO;
    if ([result isEqualToString:kUPPayPluginSuccess]) {
        // 发送posthandle
//        UPWWebViewController* viewController = (UPWWebViewController*) self.viewController;
//        [viewController getOrderPostHandle];
        // 回调给 js
        NSDictionary *userInfo = @{kUPWebPluginPayToJSResultCode: kUPWebPluginPayToJSResultCodeSuccess,
                                   kUPWebPluginPayToJSResultMessage: UP_STR(kUPWebPluginPayToJSMessageSuccess)};
        CDVPluginResult* rt = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:userInfo];
        [self.commandDelegate sendPluginResult:rt callbackId:self.callbackId];
    }
    else if ([result isEqualToString:kUPPayPluginCancel]) {
        NSDictionary *userInfo = @{kUPWebPluginPayToJSResultCode: kUPWebPluginPayToJSResultCodeCancel,
                                   kUPWebPluginPayToJSResultMessage: UP_STR(kUPWebPluginPayToJSMessageCancel)};
        CDVPluginResult* rt = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:userInfo];
        [self.commandDelegate sendPluginResult:rt callbackId:self.callbackId];
    }
    else
    {
        NSDictionary *userInfo = @{kUPWebPluginPayToJSResultCode: kUPWebPluginPayToJSResultCodeFailed,
                                   kUPWebPluginPayToJSResultMessage: UP_STR(kUPWebPluginPayToJSMessageFailed)};
        CDVPluginResult* rt = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:userInfo];
        [self.commandDelegate sendPluginResult:rt callbackId:self.callbackId];
    }

}

// 进入支付插件
- (void)gotoPayPlugin:(NSNotification *)notification
{
    NSString *code = notification.userInfo[kUPWebPluginPayToJSResultCode];
    if ([code isEqualToString:kUPWebPluginPayToJSResultCodeSuccess]) {
        // 成功
        NSString* arg = [self.command.arguments firstObject];
        NSDictionary *params = [UPXUtils dictionaryFromCordovaArgument:arg];
        if (params) {
            NSString* tn = params[@"tn"];
            NSString* mode = params[@"mode"];
            [UPWBussUtil payWithTn:tn mode:mode viewController:self.viewController delegate:self];
            UP_App.isUPPayPluginShow = YES;

            // 进入支付插件 成功，没有回调
        }
    }
    else if ([code isEqualToString:kUPWebPluginPayToJSResultCodeCancel]) {
        // 取消
        NSDictionary *userInfo = @{kUPWebPluginPayToJSResultCode: kUPWebPluginPayToJSResultCodeCancel,
                                   kUPWebPluginPayToJSResultMessage: UP_STR(kUPWebPluginPayToJSMessageCancel)};
        CDVPluginResult* rt = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:userInfo];
        [self.commandDelegate sendPluginResult:rt callbackId:self.callbackId];
    }
    else {
        // 失败
        NSDictionary *userInfo = @{kUPWebPluginPayToJSResultCode: kUPWebPluginPayToJSResultCodeFailed,
                                   kUPWebPluginPayToJSResultMessage: UP_STR(kUPWebPluginPayToJSMessageFailed)};
        CDVPluginResult* rt = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:userInfo];
        [self.commandDelegate sendPluginResult:rt callbackId:self.callbackId];
    }
}

@end
