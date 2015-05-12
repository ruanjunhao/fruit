//
//  UPXPluginUserInfo.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-9-11.
//
//

#import "CDVPlugin.h"

@interface UPXPluginUserInfo : CDVPlugin

- (void)getUserInfo:(CDVInvokedUrlCommand *)command;
- (void)clearLoginStatus:(CDVInvokedUrlCommand *)command;

@end
