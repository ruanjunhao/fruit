//
//  UPWebAppViewController.m
//  UPClientV3
//
//  Created by wxzhao on 13-4-17.
//  Copyright (c) 2013年 wxzhao. All rights reserved.
//

#import "CDVViewController.h"
#import "UPXWebAppViewController.h"
#import "UPWMessage.h"
#import "UPXConstLayout.h"
#import "UPXConstStrings.h"
#import "UPXConstKey.h"
#import "UPXUtils.h"
#import "UPWLoginViewController.h"


#define kWebToolBarLeftMargin 24

@interface UPXWebAppViewController ()
{
    BOOL _firstPageLoadFinished;
}

// order.postHandle 上送的 orderid和ordertime
@property (nonatomic,copy) NSString *posthandleOrderId;
@property (nonatomic,copy) NSString *posthandleOrderTime;

@end

@implementation UPXWebAppViewController

@synthesize webAppAlertViewDelegate;
@synthesize title;
@synthesize isLoadingView;
@synthesize isWaitingView;


- (id)init
{
    self = [super init];
    if (self) {
        self.isLoadingView = NO;
        self.isWaitingView = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    // Web APP 启动UIWebView
    [super viewDidLoad];
    
    [self setNaviTitle:self.title];
    [self addBackButton];
    
    // 显示webView，调整webView的Frame
    int toolbarHeight = 0;
    if (self.hasToolbar)
    {
        toolbarHeight = kWebViewToolBarHeight;
        [self addToolbar];
        [self goBackAction:nil];
        [self goForwardAction:nil];
    }

    self.webView.hidden = YES;
    self.webView.scrollView.bounces = NO;
    
    self.webView.frame = CGRectMake(0, 0, kScreenWidth, kViewHeight-toolbarHeight);
    [self.view bringSubviewToFront:self.webView];
    [self.view bringSubviewToFront:self.navigationController.navigationBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //向页面发送事件
    [self.commandDelegate evalJs:@"cordova.fireDocumentEvent('closewebview');"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - webViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{

    [super webViewDidStartLoad:webView];
    
    if (self.isWaitingView) {
        [self showWaitingView:UP_STR(kPleaseWaiting)];
        self.isWaitingView = NO;
        self.isLoadingView = YES;
    }
    else if (self.isLoadingView) {
        [self showLoadingView];
    }
    
    _btnGoBack.enabled = self.webView.canGoBack;
    _btnGoForward.enabled = self.webView.canGoForward;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super webViewDidFinishLoad:webView];
    if (self.isLoadingView || self.isWaitingView) {
        [self dismissAll];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    _btnGoBack.enabled = self.webView.canGoBack;
    _btnGoForward.enabled = self.webView.canGoForward;
    [self hideLoadingView];
    
    if (!_firstPageLoadFinished) {
        _firstPageLoadFinished = YES;
    }
    self.webView.hidden = NO;
    // 加载成功，允许滑动。
    self.webView.scrollView.scrollEnabled = YES;
    // Disable user selection
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // Disable callout
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    

#ifdef UP_WEB_APP_LOCAL_URL
    [NSClassFromString(@"WebView") performSelector:@selector(_enableRemoteInspector)];
#endif
    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [super webView:webView didFailLoadWithError:error];
    
    if (self.isLoadingView || self.isWaitingView) {
        [self dismissAll];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    _btnGoBack.enabled = self.webView.canGoBack;
    _btnGoForward.enabled = self.webView.canGoForward;
    
    [self hideLoadingView];
    
    self.webView.hidden = NO;
    // 加载失败，禁止滑动。
    self.webView.scrollView.scrollEnabled = NO;
    
    // webView 加载失败，导航栏还需要显示出来
    [self setNavigationBarHidden:NO];
}


#pragma mark 生成 _activityView 和 _waitingView
-(UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityView setCenter:CGPointMake(kScreenWidth/2.0, kScreenHeight/2.0)];
        [self.view addSubview:_activityView];
    }
    return _activityView;
    
}

//有toolbar时菊花放在toolbar上取代刷新按钮 
- (void)showLoadingView
{
    if (self.hasToolbar && _firstPageLoadFinished){
        UPDINFO(@"web toolbar showLoadingView");
        _btnReload.hidden = YES;
        CGRect rect = _btnReload.superview.frame;
        CGPoint pt = CGPointMake(_btnReload.center.x, rect.origin.y + _btnReload.center.y);
        [self.activityView setCenter:pt];
        [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [self.activityView startAnimating];
        [self.view bringSubviewToFront:self.activityView];
    }
    else{
        [super showLoadingWithMessage:nil];
    }
}


- (void)hideLoadingView
{
    if (self.hasToolbar && _firstPageLoadFinished){
        UPDINFO(@"web toolbar hideLoadingView");
        _btnReload.hidden = NO;
        [_activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    }
    
    if (_activityView) {
        [_activityView stopAnimating];
        //[_activityView removeFromSuperview];
    }
}

#pragma mark - toolBar
- (void)addToolbar
{
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0,  kScreenHeight-kWebViewToolBarHeight+kStatusBarHeight, kScreenWidth, kWebViewToolBarHeight)];
    [self.view addSubview:_toolBar];
    
    UIImage* imageBackground = [UP_GETIMG(@"toolbar_bg") stretchableImageWithLeftCapWidth:2 topCapHeight:22];
    UIImageView* background = [[UIImageView alloc] initWithFrame:_toolBar.bounds];
    background.image = imageBackground;
    [_toolBar addSubview:background];

    
    _btnGoBack = [UIButton buttonWithType:UIButtonTypeCustom];
    //左边距全部算在热区内, 为了居中x2
    UIImage* imageBack = UP_GETIMG(@"toolbar_back");
    int buttonWidth = imageBack.size.width;
    [_btnGoBack setFrame:CGRectMake(18, 0, buttonWidth, kWebViewToolBarHeight)];
    [_btnGoBack setImage:imageBack forState:UIControlStateNormal];
    [_btnGoBack setImage:UP_GETIMG(@"toolbar_back_tap") forState:UIControlStateHighlighted];
    [_btnGoBack setImage:UP_GETIMG(@"toolbar_back_disable") forState:UIControlStateDisabled];
    [_btnGoBack addTarget:self action:@selector(goBackAction:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_btnGoBack];

    
    //右边同左边一样
    _btnReload = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* imageRefresh = UP_GETIMG(@"toolbar_refresh");
    buttonWidth = imageRefresh.size.width;
    [_btnReload setFrame:CGRectIntegral(CGRectMake(kScreenWidth - buttonWidth-20, 0, buttonWidth, kWebViewToolBarHeight))];
    [_btnReload setImage:imageRefresh forState:UIControlStateNormal];
    [_btnReload setImage:UP_GETIMG(@"toolbar_refresh_tap") forState:UIControlStateHighlighted];
    [_btnReload setImage:UP_GETIMG(@"toolbar_refresh_disable") forState:UIControlStateDisabled];

    [_btnReload addTarget:self action:@selector(reloadAction:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_btnReload];
    
    
    
    //第二个按钮
    _btnGoForward = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* imageNext = UP_GETIMG(@"toolbar_next");
    buttonWidth = imageNext.size.width;
    [_btnGoForward setFrame:CGRectMake(CGRectGetMaxX(_btnGoBack.frame)+2, 0, buttonWidth, kWebViewToolBarHeight)];
    [_btnGoForward setImage:imageNext forState:UIControlStateNormal];
    [_btnGoForward setImage:UP_GETIMG(@"toolbar_next_tap") forState:UIControlStateHighlighted];
    [_btnGoForward setImage:UP_GETIMG(@"toolbar_next_disable") forState:UIControlStateDisabled];
    [_btnGoForward addTarget:self action:@selector(goForwardAction:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:_btnGoForward];
    

}

- (void)goBackAction:(id)sender
{
    if ([self.webView canGoBack])
    {
        [self.webView goBack];
        //很奇怪的bug, 键盘起来之后, 返回就不会收到UIWebViewDelegate的消息
        self.webView.delegate = self;
    }
}

- (void)goForwardAction:(id)sender;
{
    if ([self.webView canGoForward])
    {
        [self.webView goForward];
        //很奇怪的bug, 键盘起来之后, 返回就不会收到UIWebViewDelegate的消息
        self.webView.delegate = self;
    }
}

- (void)reloadAction:(id)sender
{
    [self.webView reload];
}

#pragma mark - hide navigation bar
- (void)setNavigationBarHidden:(BOOL)hideNavigationBar {
    BOOL hideToolBar = self.toolBar.hidden;
    self.navigationController.navigationBar.hidden = hideNavigationBar;
    
    // 显示webView，调整webView的Frame
    int toolbarHeight = hideToolBar ? 0 : kWebViewToolBarHeight;
    int navigationbarHeight = hideNavigationBar ? 0 : kNavigationBarHeight;
    
    float deltaY = 0.0f;
    
    if (UP_IOS_VERSION >= 7.0)
    {
        //在ios7上增加偏移量
        deltaY = kStatusBarHeight;
    }
    self.webView.frame = CGRectMake(0, deltaY + navigationbarHeight, kScreenWidth, kScreenHeight -navigationbarHeight  -toolbarHeight);
}

- (void)setToolBarHidden:(BOOL)hideToolBar {
    BOOL hideNavigationBar = self.navigationController.navigationBar.hidden;
    self.toolBar.hidden = hideToolBar;
    
    // 显示webView，调整webView的Frame
    int toolbarHeight = hideToolBar ? 0 : kWebViewToolBarHeight;
    int navigationbarHeight = hideNavigationBar ? 0 : kNavigationBarHeight;
    
    float deltaY = 0.0f;
    
    if (UP_IOS_VERSION >= 7.0)
    {
        //在ios7上增加偏移量
        deltaY = kStatusBarHeight;
    }
    self.webView.frame = CGRectMake(0, deltaY + navigationbarHeight, kScreenWidth, kScreenHeight -navigationbarHeight  -toolbarHeight);
}

#pragma mark - alert
- (void)alertView:(UPXAlertView *)alertView onDismiss:(NSInteger)buttonIndex
{
    //[super alertView:alertView onDismiss:buttonIndex];
    [self.webAppAlertViewDelegate buttonOKClicked:alertView.tag];

}


- (void)alertViewOnCancel:(UPXAlertView *)alertView
{
    //[super alertViewOnCancel:alertView];

    [self.webAppAlertViewDelegate buttonCancelClicked:alertView.tag];
}

#pragma mark -
#pragma mark 关闭web app, 返回web app holder
- (void)closeWebApp:(NSDictionary*)info
{
    if ([self.webAppHolder isKindOfClass:[UPWLoginViewController class]]) {
        UPWLoginViewController* loginVC = (UPWLoginViewController*)self.webAppHolder;
        [loginVC fillinUserName:info[@"registerUserName"] password:info[@"registerPassWord"]];
    }
    
    if (self.webAppHolder) {
        [self.navigationController popToViewController:self.webAppHolder animated:YES];
//        [self customPopToViewController:self.webAppHolder];
    }else {
        //[self customPopViewController];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 请求 preHandle
- (void)getOrderPreHandle:(NSString *)tn {

    
    UPDSTART();
    
    UPWMessage *message=nil;
    
    // 如果是 第三方应用，上送appID和appName
//    if ([UPXUtils isThirdPartyApp:self.appInfo.appId]) {
//        
//        message = [UPWMessage publicPayOrderPreHandleWithTn:tn
//                                                  sessionId:nil
//                                                      appId:self.appInfo.appId
//                                                    appName:self.appInfo.name
//                                                     amount:nil
//                                        isSendMerchantOrder:YES];
//    }
//    else{
//        
//        message = [UPWMessage publicPayOrderPreHandleWithTn:tn
//                                                  sessionId:nil
//                                                      appId:self.appInfo.appId
//                                                    appName:nil
//                                                     amount:nil
//                                        isSendMerchantOrder:NO];
//        
//    }

    
    if (message) {
        [self showWaitingView:UP_STR(kPleaseWaiting)];
        
        __weak UPXWebAppViewController *weakSelf=self;
        [weakSelf showWaitingView:UP_STR(kPleaseWaiting)];
        
        //原来请求_orderPreHandleOperation = [self postMessage:msg];
        [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
            
            // 获取 prehandle 返回的 order_id, order_time
            NSDictionary *params = [responseJSON objectForKey:kJSONParamsKey];
            weakSelf.posthandleOrderId = params[kJSONPrehandleOrderId];
            weakSelf.posthandleOrderTime = params[kJSONPrehandleOrderTime];
            // 返回正确之后，再进入支付控件
            [weakSelf gotoPayPluginCode:kUPWebPluginPayToJSResultCodeSuccess message:@""];
            
        } fail:^(NSError *error) {
            
            [weakSelf dismissAll];
            [weakSelf showFlashInfo:[weakSelf stringWithError:error]];
            [weakSelf gotoPayPluginCode:kUPWebPluginPayToJSResultCodeFailed message:[self msgWithError:error]];

        }];
    }
    
    UPDEND();
}

#pragma mark  发送order.postHandle 支付完毕后上送
- (void)getOrderPostHandle {

//    UPDSTART();
//    
//    UPWMessage *message = [UPWMessage orderPostHandleWithOrderId:self.posthandleOrderId
//                                                       orderTime:self.posthandleOrderTime
//                                                  classification:[UPXUtils getAppClassificationWithAppId:self.appInfo.appId]];
//    
//    
//    // 偷偷发请求
//    // 原来调用[UP_App.silenceViewController sendOrderPostHandleWithOrderId:_posthandleOrderId
//    //                                                       orderTime:_posthandleOrderTime
//    //                                                  classification:[UPXUtils getAppClassificationWithAppId:_app_id]];
//    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
//        
//    } fail:^(NSError *error) {
//        
//        //[weakSelf showFlashInfo:[weakSelf stringWithError:error]];
//        
//    }];
//    
//    UPDEND();
}


// 进入支付插件
- (void)gotoPayPluginCode:(NSString*)code message:(NSString *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUPXNotfifcationWebPluginPayOrderPrehandle
                         object:nil
                       userInfo:@{kUPWebPluginPayToJSResultCode: code,
                                  kUPWebPluginPayToJSResultMessage:message}];
}

//#pragma mark 网络收到数据
//- (void)receivedMessage:(NSDictionary*)msg withOperation:(NSOperation*)operation
//{
//    UPDSTART();
//    if (operation == _orderPreHandleOperation) {
//        [super receivedMessage:msg withOperation:operation];
//        
//        // 获取 prehandle 返回的 order_id, order_time
//        NSDictionary *params = [msg objectForKey:kJSONParamsKey];
//        self.posthandleOrderId = params[kJSONPrehandleOrderId];
//        self.posthandleOrderTime = params[kJSONPrehandleOrderTime];
//        // 返回正确之后，再进入支付控件
//        [self gotoPayPluginCode:kUPWebPluginPayToJSResultCodeSuccess message:@""];
//    } else if (operation == _orderPostHandleOperation) {
//        
//    } else {
//        [super receivedMessage:msg withOperation:operation];
//    }
//    UPDEND();
//}
//
//- (void)receivedData:(NSData*)data withOperation:(NSOperation *)operation
//{
//    if (operation == _orderPreHandleOperation) {
//        [super receivedData:data withOperation:operation];
//        // 返回正确之后，再进入支付控件
//        [self gotoPayPluginCode:kUPWebPluginPayToJSResultCodeSuccess message:@""];
//    } else if (operation == _orderPostHandleOperation) {
//        
//    } else {
//        [super receivedData:data withOperation:operation];
//    }
//}
//
//- (void)messageError:(NSString*)error code:(NSString*)code cmd:(NSString *)cmd withOperation:(NSOperation*)operation
//{
//    if (operation == _orderPreHandleOperation) {
//        [super messageError:error code:code cmd:cmd withOperation:operation];
//        // 返回正确之后，再进入支付控件
//        [self gotoPayPluginCode:kUPWebPluginPayToJSResultCodeFailed message:error];
//    } else if (operation == _orderPostHandleOperation) {
//        
//    } else {
//        [super messageError:error code:code cmd:cmd withOperation:operation];
//    }
//}
//
//
//- (void)networkErrorCode:(NSError*)error withOperation:(NSOperation*)operation
//{
//    if (operation == _orderPreHandleOperation) {
//        [super networkErrorCode:error withOperation:operation];
//        // 返回正确之后，再进入支付控件
//        [self gotoPayPluginCode:kUPWebPluginPayToJSResultCodeFailed message:[self errorMessage:error]];
//    } else if (operation == _orderPostHandleOperation) {
//        
//    } else {
//        [super networkErrorCode:error withOperation:operation];
//    }
//}


@end
