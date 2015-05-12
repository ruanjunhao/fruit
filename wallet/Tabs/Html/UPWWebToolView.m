//
//  UPWWebToolView.m
//  UPWallet
//
//  Created by jhyu on 14-9-24.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWWebToolView.h"
#import "UPWWebViewController.h"
#import "UPWUiUtil.h"

@interface UPWWebToolView () {
    __weak UIWebView * _webView;
    __weak UPWWebViewController * _webVC;
}

@property (nonatomic, readwrite) UIButton * btnGoBack;
@property (nonatomic, readwrite) UIButton * btnGoForward;
@property (nonatomic, readwrite) UIButton * btnReload;

@end


@implementation UPWWebToolView

- (instancetype)initWithWebViewController:(UPWWebViewController *)webVC
{
    UIWebView * webView = webVC.webView;
    CGRect rc = webView.bounds;
    rc.origin.y = CGRectGetMaxY(webView.frame);
    rc.size.height = kWebToolViewHeight;
    
    self = [super initWithFrame:rc];
    if(self) {
        _webView = webView;
        _webVC = webVC;
        [self addControls];
    }
    
    return self;
}

- (void)addControls
{
    self.backgroundColor = [UIColor whiteColor];
    
    // back button
    _btnGoBack = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* imageBack = UP_GETIMG(@"toolbar_back");
    //热区实际上时图片宽度的三倍，一倍图片边距被计算在左边距内
    int buttonWidth = imageBack.size.width *3;
    [_btnGoBack setFrame:CGRectMake(25-imageBack.size.width, 0, buttonWidth, kWebToolViewHeight)];
    [_btnGoBack setImage:imageBack forState:UIControlStateNormal];
    [_btnGoBack setImage:UP_GETIMG(@"toolbar_back_tap") forState:UIControlStateHighlighted];
    [_btnGoBack setImage:UP_GETIMG(@"toolbar_back_disable") forState:UIControlStateDisabled];
    [_btnGoBack addTarget:self action:@selector(goBackAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnGoBack];
    
    // reload button
    //右边同左边一样
    _btnReload = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* imageRefresh = UP_GETIMG(@"toolbar_refresh");
    buttonWidth = imageRefresh.size.width;
    [_btnReload setFrame:CGRectIntegral(CGRectMake(CGRectGetMaxX(self.bounds) - buttonWidth-25, 0, buttonWidth, kWebToolViewHeight))];
    [_btnReload setImage:imageRefresh forState:UIControlStateNormal];
    [_btnReload setImage:UP_GETIMG(@"toolbar_refresh_tap") forState:UIControlStateHighlighted];
    [_btnReload setImage:UP_GETIMG(@"toolbar_refresh_disable") forState:UIControlStateDisabled];
    
    [_btnReload addTarget:self action:@selector(reloadAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnReload];

    // forward button
    //第二个按钮
    _btnGoForward = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* imageNext = UP_GETIMG(@"toolbar_next");
    buttonWidth = imageNext.size.width * 3;
    [_btnGoForward setFrame:CGRectMake(CGRectGetMaxX(_btnGoBack.frame)+30, 0, buttonWidth, kWebToolViewHeight)];
    [_btnGoForward setImage:imageNext forState:UIControlStateNormal];
    [_btnGoForward setImage:UP_GETIMG(@"toolbar_next_tap") forState:UIControlStateHighlighted];
    [_btnGoForward setImage:UP_GETIMG(@"toolbar_next_disable") forState:UIControlStateDisabled];
    [_btnGoForward addTarget:self action:@selector(goForwardAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnGoForward];
    
    // 顶部细化线
    [self addSubview:[UPWUiUtil createGreyLineViewWithRect:self.bounds]];
}

- (void)goBackAction:(id)sender
{
    if ([_webView canGoBack]) {
        [_webView goBack];
        if([self.delegate respondsToSelector:@selector(didLoadBackPageContent)]) {
            [self.delegate didLoadBackPageContent];
        }
        
        // 很奇怪的bug, 键盘起来之后, 返回就不会收到UIWebViewDelegate的消息
        _webView.delegate = _webVC;
        
        [self updateBtnsStatus];
    }
    else {
        self.btnGoBack.enabled = NO;
    }
}

- (void)updateBtnsStatus
{
    self.btnGoBack.enabled = _webView.canGoBack;
    self.btnGoForward.enabled = _webView.canGoForward;
    self.btnReload.enabled = !_webView.isLoading;
    
    UPDINFO(@"back = %d  forward = %d", self.btnGoBack.enabled, self.btnGoForward.enabled);
}

- (void)goForwardAction:(id)sender;
{
    if ([_webView canGoForward]) {
        [_webView goForward];
        if([self.delegate respondsToSelector:@selector(didLoadForwardPageContent)]) {
            [self.delegate didLoadForwardPageContent];
        }
        
        // 很奇怪的bug, 键盘起来之后, 返回就不会收到UIWebViewDelegate的消息
        _webView.delegate = _webVC;
        
        [self updateBtnsStatus];
    }
    else {
        self.btnGoForward.enabled = NO;
    }
}

- (void)reloadAction:(id)sender
{
    [_webVC showLoadingWithMessage:@""];
    [_webView reload];
}

@end
