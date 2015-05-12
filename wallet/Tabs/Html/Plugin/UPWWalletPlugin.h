//
//  UPWWalletPlugin.h
//  CHSP
//
//  Created by jhyu on 13-11-7.
//
//

#import "CDVPlugin.h"

// 现阶段支持如下插件。
@interface UPWWalletPlugin : CDVPlugin

// 报文发送到Top后台，filter
- (void)sendMessage:(CDVInvokedUrlCommand *)command;

// 显示网络LoadingView
- (void)showLoading:(CDVInvokedUrlCommand *)commands;

// 显示Toast文言
- (void)showToast:(CDVInvokedUrlCommand *)commands;

// 打电话
- (void)callPhone:(CDVInvokedUrlCommand *)commands;

// JS请求本地数据
- (void)fetchNativeData:(CDVInvokedUrlCommand *)commands;

// Plugin打开一个新页面
- (void)openNewPage:(CDVInvokedUrlCommand *)command;

// 打开登录页面，秒杀页面会调用。
- (void)openLoginPage:(CDVInvokedUrlCommand *)command;

// 配置NavBar上的显示参数
- (void)setNavBar:(CDVInvokedUrlCommand *)commands;

// 打开注册页面
- (void)openRegisterPage:(CDVInvokedUrlCommand *)command;

@end

