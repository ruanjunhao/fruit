//
//  UPWebAppViewController.h
//  UPClientV3
//
//  Created by wxzhao on 13-4-17.
//  Copyright (c) 2013年 wxzhao. All rights reserved.
//


//#import "UPWBaseViewController.h"
#import "UPXWebAppAlertViewDelegate.h"
//#import "UPXAppDelegate.h"
//#import "UPXSilentViewController.h"
#import "CDVViewController.h"
#import "UPWAppInfoModel.h"

@interface UPXWebAppViewController : CDVViewController<UIWebViewDelegate>
{
    UIButton*   _btnGoBack;
    UIButton*   _btnGoForward;
    UIButton*   _btnReload;
    
    NSOperation* _orderPreHandleOperation;
    NSOperation* _orderPostHandleOperation;
}

@property (nonatomic,assign) id<UPXWebAppAlertViewDelegate> webAppAlertViewDelegate;

// 设置NavigationBar的Title
@property (nonatomic,copy) NSString* title;

// 网页加载时，是否显示LoadingView，加载结束LoadingView消失，非阻塞
@property (nonatomic,assign) BOOL isLoadingView;

// 网页加载时，是否显示WaitingView，加载结束WaitingView消失，阻塞
@property (nonatomic,assign) BOOL isWaitingView;

@property (nonatomic,retain) UIView* toolBar;

//打开web app的view controller, 在js的closeWebApp调用后返回到这个vc
@property(nonatomic,assign) UIViewController* webAppHolder;

@property (nonatomic, retain) UPWAppInfoModel *appInfo;

@property(nonatomic,assign)   BOOL        hasToolbar;

@property(nonatomic,retain) UIActivityIndicatorView* activityView;

#pragma mark -
#pragma mark 关闭web app, 返回web app holder
- (void)closeWebApp:(NSDictionary*)info;

- (void)getOrderPreHandle:(NSString *)tn;
// 发送order.postHandle 支付完毕后上送
- (void)getOrderPostHandle;

- (void)setNavigationBarHidden:(BOOL)hideNavigationBar;
- (void)setToolBarHidden:(BOOL)hideToolBar;

@end
