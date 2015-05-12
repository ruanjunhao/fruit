//
//  UPDataPresentBaseViewController.h
//  UPWallet
//
//  Created by gcwang on 14-7-23.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWBaseViewController.h"
#import "UPWNetworkStatusView.h"
#import "UPWListNoContentView.h"
#import "UPWComingSoonView.h"
#import "UPWNavRightTitleViewController.h"

@interface UPWDataPresentBaseViewController : UPWNavRightTitleViewController
{
    UPWNetworkStatusView* _networkStatusView;
    UPWListNoContentView* _noContentView;
    UPWComingSoonView* _comingSoonView;
}

/*
 展示“加载中”，并提供点击重试的区域
 */
- (void)showNetworkLoading:(CGPoint)center withRetryRect:(CGRect)rect;
- (void)showNetworkLoading;

/*
 展示网络错误、后台错误图标
 */
- (void)showNetworkFailed;
- (void)showMessageError;

/*
 隐藏出错提示
 */
- (void)hideNetworkStatusView;

/*
 判断是否正在网络加载
 */
- (BOOL)isNetworkLoadingInProgress;

/*
 数据为零时，显示此提示页面
 */
- (void)showNoContentView:(CGPoint)center;
- (void)hideNoContentView;

/*
 提醒用户此业务暂未开通，显示此提示页面
 */
- (void)showComingSoonView:(UIImage*)image withType:(NSString*)type withText:(NSString*)text;
- (void)hideComingSoonView;

/*
 点击重新加载，sub class需要重载此函数
 */
- (void)reloadData;

@end
