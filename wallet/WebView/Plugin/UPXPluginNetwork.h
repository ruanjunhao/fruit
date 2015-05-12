//
//  UPXPluginNetwork.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-9-10.
//
//

#import "CDVPlugin.h"

@interface UPXPluginNetwork : CDVPlugin

@property(nonatomic,copy)NSString* callbackId;

// 发送报文, 支持 Get Post
- (void)sendMessage:(CDVInvokedUrlCommand*)command;

@end
