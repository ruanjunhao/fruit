//
//  UPXPluginUserInfo.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-9-11.
//
//

#import "UPXPluginUserInfo.h"
#import "UPWMarco.h"
#import "UPWGlobalData.h"
#import "UPXConstStrings.h"
#import "UPXUtils.h"


@implementation UPXPluginUserInfo

- (void)getUserInfo:(CDVInvokedUrlCommand *)command
{
    UPDSTART();
    CDVPluginResult* result = nil;
    NSDictionary* dictionary = nil;
    
    if (UP_SHDAT.hasLogin) {
        if (!UP_IS_NIL(UP_SHDAT.bigUserInfo.userInfo.userId)) {
            NSString* mobile = UP_IS_NIL(UP_SHDAT.bigUserInfo.userInfo.mobilePhone)?@"":UP_SHDAT.bigUserInfo.userInfo.mobilePhone;
            dictionary = @{@"mobilephone":mobile,
                           @"userid":UP_SHDAT.bigUserInfo.userInfo.userId};
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
        }
        else{
            dictionary = @{@"code":@"2",@"desc":UP_STR(kGetUserInfoFailed)};
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dictionary];
        }
    }
    else{
        dictionary = @{@"code":@"1",@"desc":UP_STR(kUserHasNotLogin)};
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dictionary];
    }
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    UPDEND();
}


- (void)clearLoginStatus:(CDVInvokedUrlCommand *)command
{
    
    //清理状态
    [UPXUtils clearLoginStatus];
}



@end
