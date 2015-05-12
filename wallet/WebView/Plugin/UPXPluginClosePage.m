//
//  UPXPluginClosePage.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-9-10.
//
//

#import "UPXPluginClosePage.h"
#import "UPWWebViewController.h"
#import "UPWMarco.h"
#import "UPWGlobalData.h"
#import "UPXUtils.h"

@implementation UPXPluginClosePage


#define kNewUserName @"newUserName"
#define kNewPassWord @"newPassWord"


- (void)closeWebApp:(CDVInvokedUrlCommand *)command
{
    UPDSTART();
    NSString* arg = [command.arguments firstObject];
    UPDINFO(@"arg %@",arg);
    NSDictionary *params = [UPXUtils dictionaryFromCordovaArgument:arg];

    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    if (params) {
        if (!UP_IS_NIL(params[kNewUserName])) {
            info[@"registerUserName"] = params[kNewUserName];
        }
        if ( !UP_IS_NIL(params[kNewPassWord])) {
            info[@"registerPassWord"] = params[kNewPassWord];

        }
    }
    UPWWebViewController* viewController = (UPWWebViewController*) self.viewController;
    [viewController closeWebApp:info];
    UPDEND();
}


@end
