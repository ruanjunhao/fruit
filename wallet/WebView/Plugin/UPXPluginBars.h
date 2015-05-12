//
//  UPXPluginBars.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-10-9.
//
//

#import "CDVPlugin.h"

@interface UPXPluginBars : CDVPlugin

- (void)setBarStatus:(CDVInvokedUrlCommand *)command;
- (void)setNavigationBarTitle:(CDVInvokedUrlCommand *)command;

@end
