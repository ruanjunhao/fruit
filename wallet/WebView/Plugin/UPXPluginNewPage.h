//
//  UPXPluginNewPage.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-9-10.
//
//

#import "CDVPlugin.h"

@interface UPXPluginNewPage : CDVPlugin

@property(nonatomic,copy)NSString* callbackId;


// 新建一个页面
- (void)createWebPage:(CDVInvokedUrlCommand*)command;

@end
