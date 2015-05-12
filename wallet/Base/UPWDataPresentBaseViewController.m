//
//  UPDataPresentBaseViewController.m
//  UPWallet
//
//  Created by gcwang on 14-7-23.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWDataPresentBaseViewController.h"

@interface UPWDataPresentBaseViewController ()

@end

@implementation UPWDataPresentBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _networkStatusView = [[UPWNetworkStatusView alloc] initWithFrame:CGRectZero];
    __weak UPWDataPresentBaseViewController *wself = self;
    _networkStatusView.retryBlock = ^void{[wself reloadData];};
    [_contentView addSubview:_networkStatusView];
    
    _noContentView = [[UPWListNoContentView alloc] initWithFrame:CGRectZero];
    _noContentView.hidden = YES;
    [_contentView addSubview:_noContentView];
    
    _comingSoonView = [[UPWComingSoonView alloc] initWithFrame:CGRectZero];
    _comingSoonView.hidden = YES;
    [_contentView addSubview:_comingSoonView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark -  展示“加载中”，并提供点击重试的区域

- (void)showNetworkLoading:(CGPoint)center withRetryRect:(CGRect)rect
{
    _networkStatusView.retryRect = rect;
    _networkStatusView.viewCenter = center;
    _networkStatusView.networkStatus = UPNetworkStatusLoading;
}

- (void)showNetworkLoading
{
    CGPoint viewCenter = CGPointMake(_contentView.frame.size.width/2, _contentView.frame.size.height/2 );
    CGRect retryRect = CGRectMake(0, _contentView.frame.origin.y, _contentView.frame.size.width, _contentView.frame.size.height);
    [self showNetworkLoading:viewCenter withRetryRect:retryRect];
}

#pragma mark -
#pragma mark  展示网络错误、后台错误图标

- (void)showNetworkFailed
{
    _networkStatusView.networkStatus = UPNetworkStatusFailed;
    
}

- (void)showMessageError
{
    _networkStatusView.networkStatus = UPNetworkStatusMessageError;
}

#pragma mark -
#pragma mark  隐藏出错提示

- (void)hideNetworkStatusView
{
    _networkStatusView.networkStatus = UPNetworkStatusSuccess;
}

#pragma mark -
#pragma mark  判断是否正在网络加载

- (BOOL)isNetworkLoadingInProgress
{
    return (_networkStatusView.networkStatus == UPNetworkStatusLoading);
}

#pragma mark -
#pragma mark  数据为零时，显示此提示页面

- (void)showNoContentView:(CGPoint)center
{
    _noContentView.hidden = NO;
    _noContentView.listCenter = center;
    [_contentView bringSubviewToFront:_noContentView];
}

- (void)hideNoContentView
{
    _noContentView.hidden = YES;
    [_contentView sendSubviewToBack:_noContentView];
}

#pragma mark -
#pragma mark  提醒用户此业务暂未开通，显示此提示页面

- (void)showComingSoonView:(UIImage*)image withType:(NSString*)type withText:(NSString*)text
{
    _comingSoonView.image = image;
    _comingSoonView.type = type;
    _comingSoonView.content = text;
    _comingSoonView.frame = CGRectMake(0, 0, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame));
    _comingSoonView.hidden = NO;
    [_comingSoonView setNeedsLayout];
    [_contentView bringSubviewToFront:_comingSoonView];
}

- (void)hideComingSoonView
{
    _comingSoonView.hidden = YES;
    [_contentView sendSubviewToBack:_comingSoonView];
}

#pragma mark -
#pragma mark  点击重新加载，sub class需要重载此函数

- (void)reloadData
{
    
}

@end
