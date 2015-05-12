//
//  UPWRefreshViewController.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-10-8.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWBaseViewController.h"
#import "UPWDataPresentBaseViewController.h"
typedef void (^pull_to_refresh_block_t)();
typedef void (^infinite_scrolling_block_t)();


@interface UPWRefreshViewController : UPWDataPresentBaseViewController

- (void)addPullToRefresh:(UIScrollView*)scrollView withActionHandler:(pull_to_refresh_block_t)actionHandler;

- (void)didFinishedRefreshing:(UIScrollView*)scrollView;

- (void)didFinishedRefreshing:(UIScrollView*)scrollView showPullToRefresh:(BOOL)show;

- (void)triggerPullToRefresh:(UIScrollView*)scrollView;

- (void)addInfiniteScrolling:(UIScrollView*)scrollView withActionHandler:(infinite_scrolling_block_t)actionHandler;

- (void)didFinishedInfiniteScrolling:(UIScrollView*)scrollView;

- (void)didFinishedInfiniteScrolling:(UIScrollView*)scrollView showInfiniteScrolling:(BOOL)show;

@end
