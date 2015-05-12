//
//  UPWWebViewController.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//


#import "CDVViewController.h"
#import "UPWWebAppAlertViewDelegate.h"

@class UPWAppInfoModel;
@class UPWWebData;
@class UPWLocationService;

/*
 * UPWWebViewController主要用于展示与票券相关的详情页面，包含响应对票券操作的事件。
 *
 */
@interface UPWWebViewController : CDVViewController

@property (nonatomic, strong) UPWLocationService * locationService;

// 整合随行里面的一些特殊需求，以及逻辑。
@property (nonatomic,weak) id<UPWWebAppAlertViewDelegate> webAppAlertViewDelegate;

// 设置NavigationBar的Title
@property (nonatomic,copy) NSString* title;

// 网页加载时，是否显示LoadingView，加载结束LoadingView消失，非阻塞
@property (nonatomic,assign) BOOL isLoadingView; // 默认值是YES

// 网页加载时，是否显示WaitingView，加载结束WaitingView消失，阻塞
@property (nonatomic,assign) BOOL isWaitingView; // 默认值是NO

//打开web app的view controller, 在js的closeWebApp调用后返回到这个vc
@property(nonatomic,weak) UIViewController* webAppHolder;

@property (nonatomic,strong) UPWAppInfoModel *appInfo;

@property(nonatomic,assign) BOOL hasToolbar; // 默认值是NO

// 初始化的参数可以通过UPWWebData构建
- (id)initWithWebData:(UPWWebData *)webData;

#pragma mark -
#pragma mark 关闭web app, 返回web app holder
- (void)closeWebApp:(NSDictionary*)info;
- (void)gotoPayPluginCode:(NSString*)code message:(NSString *)message;
- (void)setNavigationBarHidden:(BOOL)hideNavigationBar toolBarHidden:(BOOL)hideToolBar;

// plugin控制NavBar上的显示元素
- (void)setNavBarWithArgs:(NSDictionary *)args;

@end

