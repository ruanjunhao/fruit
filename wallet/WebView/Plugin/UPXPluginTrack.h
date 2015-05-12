//
//  UPXPluginTrack.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-15.
//
//

#import "CDVPlugin.h"

@interface UPXPluginTrack : CDVPlugin

- (void)logEvent:(CDVInvokedUrlCommand *)command;

- (void)logPageBegin:(CDVInvokedUrlCommand *)command;

- (void)logPageEnd:(CDVInvokedUrlCommand *)command;

@end
