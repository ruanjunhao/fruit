//
//  UPWRefreshViewController.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-10-8.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWRefreshViewController.h"
#import "SVPullToRefresh.h"


@implementation UPWRefreshViewController


- (void)addPullToRefresh:(UIScrollView*)scrollView withActionHandler:(pull_to_refresh_block_t)actionHandler
{
    [scrollView addPullToRefreshWithActionHandler:actionHandler];
}

- (void)triggerPullToRefresh:(UIScrollView*)scrollView
{
    scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, (scrollView.contentOffset.y - CGRectGetHeight(scrollView.pullToRefreshView.frame)));
    [scrollView triggerPullToRefresh];
}


- (void)startRefreshingData
{

}

- (void)didFinishedRefreshing:(UIScrollView*)scrollView
{

    [scrollView.pullToRefreshView stopAnimating];
}

//show代表是否允许下拉刷新，在优惠券筛选无内容的时候，不允许下拉刷新，其他页面通用
- (void)didFinishedRefreshing:(UIScrollView*)scrollView showPullToRefresh:(BOOL)show
{
    [scrollView.pullToRefreshView stopAnimating];
    scrollView.showsPullToRefresh = show;
}

#pragma mark - 上拉加载更多


- (void)addInfiniteScrolling:(UIScrollView*)scrollView withActionHandler:(infinite_scrolling_block_t)actionHandler
{
    [scrollView addInfiniteScrollingWithActionHandler:actionHandler];
}

- (void)didFinishedInfiniteScrolling:(UIScrollView*)scrollView
{
    [scrollView.infiniteScrollingView stopAnimating];
}

//show代表是否允许上拉加载，当优惠列表上拉加载完所有内容时，不允许再上拉加载，其他页面通用
- (void)didFinishedInfiniteScrolling:(UIScrollView*)scrollView showInfiniteScrolling:(BOOL)show
{
    [scrollView.infiniteScrollingView stopAnimating];
    scrollView.showsInfiniteScrolling = show;
}

@end
