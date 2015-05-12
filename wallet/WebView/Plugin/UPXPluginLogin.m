//
//  UPXPluginLogin.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-9-16.
//
//

#import "UPXPluginLogin.h"
#import "UPWBaseViewController.h"
#import "UPWMarco.h"
#import "UPXConstStrings.h"
#import "UPXConstKey.h"
#import "UPWGlobalData.h"
#import "UPWLoginViewController.h"
#import "UPWBussUtil.h"

@implementation UPXPluginLogin


- (void)login:(CDVInvokedUrlCommand *)commands
{
    UPDSTART();
    self.callbackId = commands.callbackId;
    
    if (UP_SHDAT.hasLogin) {
        //用户已经登录, 不应该再调起登录界面
        NSDictionary* dictionary = @{@"code":@"1",
                                     @"desc":UP_STR(kUserHasLogin)};
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dictionary];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
    else{
        [UPWBussUtil showLoginWithSuccessBlock:nil cancelBlock:nil completion:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginStatusChanged) name:kNCLoginStatusChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCancel) name:kNCLoginCancel object:nil];
    }
    UPDEND();
}


- (void)removeAllObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNCLoginStatusChanged object:nil];
    //当前“kNCLoginCancel”事件同时被用于UPWWelcomeViewController类用于监听取消事件，且UPWWelcomeViewController为rootViewController，因此在该类中取消事件。Modified by wll.
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNCLoginCancel object:nil];
}



- (void)loginStatusChanged
{
    [self removeAllObserver];

    CDVPluginResult* result = nil;
    
    if (!UP_IS_NIL(UP_SHDAT.bigUserInfo.userInfo.username)
        && !UP_IS_NIL(UP_SHDAT.bigUserInfo.userInfo.userId)) {
        NSDictionary* dictionary  = @{@"username":UP_SHDAT.bigUserInfo.userInfo.username,
                                      @"userid":UP_SHDAT.bigUserInfo.userInfo.userId};
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
    }
    else{
        //程序判断已登录, 但是缺少username和userid字段
        NSDictionary* dictionary = @{@"code":@"3",@"desc":UP_STR(kLoginFailed)};
        result  = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dictionary];
    }
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}


- (void)loginCancel
{
    [self removeAllObserver];
    //用户取消登录
    NSDictionary* dictionary = @{@"code":@"2",
                                 @"desc":UP_STR(kLoginCancel)};
    CDVPluginResult* result  = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dictionary];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}



@end
