//
//  UPXPluginNativeInfo.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 14-8-5.
//
//

#import "UPXPluginNativeInfo.h"
#import "UPWWebViewController.h"
#import "UPWAppInfoModel.h"

@implementation UPXPluginNativeInfo

- (void)getAppInfo:(CDVInvokedUrlCommand *)command
{
    UPWWebViewController* viewController = (UPWWebViewController*) self.viewController;
    NSDictionary* result = [viewController.appInfo copy];
    CDVPluginResult* rt = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
    [self.commandDelegate sendPluginResult:rt callbackId:command.callbackId];
}
@end
