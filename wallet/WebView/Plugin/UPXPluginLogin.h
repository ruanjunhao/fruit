//
//  UPXPluginLogin.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-9-16.
//
//

#import "CDVPlugin.h"

@interface UPXPluginLogin : CDVPlugin

@property(nonatomic,copy)NSString* callbackId;

- (void)login:(CDVInvokedUrlCommand *)commands;

@end
