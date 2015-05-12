//
//  UPWWebViewController.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

//
//  UPWWebViewController.m
//  CHSP
//
//  Created by jhyu on 13-10-25.
//
//

#import "UPWWebViewController.h"
#import "UPWBaseNavigationController.h"
#import "UPWLoginViewController.h"
#import "UPWSharePanel.h"
#import "UPWAddToCartPanel.h"
#import "UPWGlobalData.h"
#import "UPWWebData.h"
#import "UPWMessage.h"
#import "UPWBussUtil.h"
#import "UPWWebUtility.h"
#import "UPWNotificationName.h"
#import "NSString+IACExtensions.h"
#import "ShareMgr/ShareMgr.h"
#import "UPWWebToolView.h"
#import "UPXConstStrings.h"
#import "UPXConstKey.h"
#import "UPXUtils.h"
#import "UPWLocationService.h"

typedef void (^addMyFavBtnBlcok)(BOOL isOn);

@interface UPWWebViewController () <UPWSharePanelDelegate, UPWWebToolViewDelegate, UIScrollViewDelegate> {
    UPWWebData*      _webData;
    UPWSharePanel*   _sharePanel;
    
    NSDictionary*  _params; // 页面WEB端参数
    UIButton*      _favBtn;
    BOOL           _isPoiSaved;  // 记录当前收藏状态，YES表示已经收藏。
    
    CGFloat        _topOffsetBak; // 为show/hide NavigationBar服务
    BOOL           _isNaviBarHidden;
}

@property (nonatomic,strong) UPWWebToolView* toolBar;

// order.postHandle 上送的 orderid和ordertime
@property (nonatomic,copy) NSString *posthandleOrderId;
@property (nonatomic,copy) NSString *posthandleOrderTime;

@end

@implementation UPWWebViewController

- (void)dealloc
{
    self.webView.scrollView.delegate = nil;
    [UP_NC removeObserver:self];
    // _panel是加到MainWindow上面的。
    // 恢复NavigationBar.
    [self resetNaviBar];
    
    // 插件里面调用的loading, waiting都干掉。
    [self dismissAll];
}

- (id)init
{
    self = [super init];
    if (self) {
        // 设置默认值
        self.isLoadingView = YES;
        self.isWaitingView = NO;
        self.hasToolbar = NO;
    }
    
    return self;
}

- (id)initWithWebData:(UPWWebData *)webData
{
    self = [self init];
    if (self) {
        _webData = webData;
        self.startPage = _webData.startPage;
        UPDINFO(@">>> self.startPage = %@", self.startPage);
        
        // 事件处理中需要一些参数信息，例如"brandId"等等，从self.startPage中Parse.
        NSArray * components = [self.startPage componentsSeparatedByString:@"?"];
        // 从参数对中Parse.
        _params = [components.lastObject parseURLParams];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(_isNaviBarHidden) {
        [self setNavigationBarHidden:YES toolBarHidden:_toolBar.isHidden];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self resetNaviBar];
    
    [self.locationService stopUpdatingLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // ! 针对UIWebView的许多个性化设置通过配置config.xml来实现
    
    _topOffsetBak = _topOffset;
    
    NSString * title = self.title;
    if(UP_IS_NIL(title)) {
        title = @"详情";//_webData.navigationBarTitle;
    }
    [self setNaviTitle:title];
    
    if(self.startPage.length > 0) {
        if(self.isLoadingView) {
            [self showLoadingWithMessage:@""]; 
        }
        else {
            [self showWaitingView:UP_STR(@"kStrWaiting")];
        }
    }
    
    // 打开登录页面, 注意：只监听自己这个页面的。
//    [UP_NC addObserver:self selector:@selector(openLoginPage) name:kNotificationOpenLoginPage object:self];
    
    // 锁屏与分享时打开其他系统类APP相冲突。
//    [UP_NC addObserver:self selector:@selector(dismissShareSystemCtrlComponents) name:kNCEnterBackground object:nil];
    
    // ~ http://stackoverflow.com/questions/9062195/uiwebview-disable-zooming-when-scalespagetofit-is-on
    self.webView.scrollView.delegate = self;
}

#pragma mark -
#pragma mark - 关闭WebView的自动缩放功能。
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

- (void)resetNaviBar
{
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark -
#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super webViewDidFinishLoad:webView];
    [self dismissAll];
    [self configNavBarRightButton];
    
    if(self.hasToolbar) {
        // 展示底部ToolBar.
        [self setNavigationBarHidden:NO toolBarHidden:NO];
    }

    // 加载成功，允许滑动。
    self.webView.scrollView.scrollEnabled = YES;
    // Disable user selection
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // Disable callout
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [super webView:webView didFailLoadWithError:error];
    [self dismissAll];
    
    // ~ https://discussions.apple.com/thread/1727260?start=0&tstart=0
    if (error.code != NSURLErrorCancelled) {
        [self showFlashInfo:UP_STR(@"String_JSON_Error")];
        
        //self.webView.hidden = NO;
        // 加载失败，禁止滑动。
        self.webView.scrollView.scrollEnabled = NO;
        
        // webView 加载失败，导航栏还需要显示出来
        if(_isNaviBarHidden) {
            [self setNavigationBarHidden:NO toolBarHidden:_toolBar.isHidden];
        }
    }
}

#pragma mark -
#pragma mark - Actions

// 分享按钮点击事件
- (void)shareButtonClick:(id)sender
{
    [UPWDataCollectMgr upTrackEvent:@"youhui_share"];
    // 取消键盘，秒杀页面输入验证码会弹出。
    [self.view endEditing:YES];
    
    if(!_sharePanel) {
        NSString * title;
        /*
         if(_webData.eShareType == EShareTypeApp) {
         title = _webData.navigationBarTitle;
         }
         else */{
             title = UP_STR(@"kStrShare");
         }
        
        _sharePanel = [[UPWSharePanel alloc] initWithTitle:title];
        _sharePanel.delegate = self;
        
        if(_webData.eShareType != EShareTypeApp) {
            // 微信分享图片提前异步获取，分享时直接使用。
            [self shareContentByType:UPWeiXin];
        }
    }
    
    [_sharePanel show];
    
    if(_webData.eShareType == EShareTypeActivity) {
        // 只跟踪专题活动分享。
        [UPWDataCollectMgr upTrackEvent:@"share_activity"];
    }
}

// 用户评论，打分页面打开事件
- (void)commentBtnClickAction:(id)sender
{
    if (!UP_SHDAT.hasLogin) {
        [self openLoginPage];
        return;
    }
    
    // Plugin必须传递@"brandId"字段
    if([_params[@"brandId"] length] == 0) {
        return;
    }
    
//    UPWRatingViewController * ratingVC = [[UPWRatingViewController alloc] initWithBrandId:_params[@"brandId"]];
//    
//    [self.navigationController pushViewController:ratingVC animated:YES];
}

// 我的花销页面Bar上点击事件
- (void)showCostTrendPage:(id)sender
{
    NSDictionary * params = @{@"pageUrl":@{@"uri":@"hybrid_v3/html/data/expensetrend.html", @"params":@{}}, @"navBar":@{@"title":UP_STR(@"String_Cost_Trend")}};
    UPWWebData * webData = [[UPWWebData alloc] initWithLaunchType:ELaunchTypeUniversalWebDriven poiData:params];
    [self.navigationController pushViewController:[[UPWWebViewController alloc] initWithWebData:webData] animated:YES];
}

#pragma mark -
#pragma mark - Action (Favorite)

// 收藏（取消）收藏
- (void)favBtnClickAction:(id)sender
{
    // 需要登陆
    if(!UP_SHDAT.hasLogin) {
        [self openLoginPage];
        return;
    }
    
    NSString * brandId = _params[@"brandId"];
    NSString * cityCd = _params[@"cityCd"];
    
    if(!brandId || !cityCd) {
        return;
    }
    
    // 将收藏状态上报服务器
    NSDictionary * params = @{@"brandId":brandId, @"cdhdUsrId":UP_SHDAT.bigUserInfo.userInfo.userIdC, @"cityCd":cityCd, @"accTp":(_isPoiSaved ? @"0" : @"1")};
    UPWMessage * message = [UPWMessage messageWithUrl:@"brand.app.favorBrand" params:params encrypt:YES isPost:YES hostType:@"0"];
    __weak id weakSelf = self;
    
    [self showLoadingWithMessage:UP_STR(kLoadingInProgress)];
    NSAssert(sender == _favBtn, @"");
    
    // 请求未返回之前，不允许用户重复点击
    _favBtn.userInteractionEnabled = NO;
    
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        
        [weakSelf dismissLoading];
        [weakSelf didSaveFavoriteWithResponseJSON:responseJSON];
    } fail:^(NSError *error) {
        
        [weakSelf dismissLoading];
        [weakSelf didSaveFavoriteWithError:error];
    }];
}

- (void)didSaveFavoriteWithResponseJSON:(id)responseJSON
{
    _favBtn.userInteractionEnabled = YES;
    
    // 组装提示消息
    NSString* message;
    if(_isPoiSaved) {
        message = UP_STR(@"kStrUnSaveFavorite");
    }
    else {
        message = UP_STR(@"kStrSaveFavorite");
    }
    
    NSString * status;
    id value = responseJSON[kJSONParamsKey][@"favorResult"];
    if(_isPoiSaved) {
        if([value isEqualToString:@"3"]) {
            status = UP_STR(@"kStrSuccess");
        }
        else {
            status = UP_STR(@"kStrFail");
        }
    }
    else {
        status = UP_STR(@"kStrSuccess");
    }
    
    if(status.length > 0) {
        message = [message stringByAppendingString:status];
    }
    
    [self showFlashInfo:message];
    
    [self refreshFavoriteStatus:!_isPoiSaved];
    
    // 通知我的收藏页面
    [UP_NC postNotificationName:kNotificationChangeFavorStateSucceed object:nil userInfo:@{@"state":@(_isPoiSaved), @"brandId":_params[@"brandId"]}];
}

- (void)didSaveFavoriteWithError:(NSError *)error
{
    _favBtn.userInteractionEnabled = YES;
    
    NSString * message;
    if(_isPoiSaved) {
        message = UP_STR(@"kStrUnSaveFavorite");
    }
    else {
        message = UP_STR(@"kStrSaveFavorite");
    }
    
    message = [message stringByAppendingString:UP_STR(@"kStrFail")];
    
    [self showFlashInfo:message];
}


- (void)setFavoriteStatus:(BOOL)willShowLoading
{
    // 没有登录，无法获取其状态，标记为未收藏。
    if(!UP_SHDAT.hasLogin) {
        [self refreshFavoriteStatus:NO];
        return;
    }
    
    NSString * brandId = _params[@"brandId"];
    NSString * cityCd = _params[@"cityCd"];
    // 如下请求必备字段
    if(!brandId || !cityCd) {
        return;
    }
    
    // 我的收藏过来打开的商户详情，收藏状态是已收藏
    if(_webData.eLaunchType == ELaunchTypeLocalMerchant) {
        // come from "My favorite page."
        [self refreshFavoriteStatus:YES];
        // 还是要继续下面的请求，原因是收藏状态在后续页面中可能会被修改，返回的时候进行刷新。
    }
    
    if(willShowLoading) {
        [self showLoadingWithMessage:UP_STR(kLoadingInProgress)];
    }

    NSDictionary * params = @{@"brandId":brandId, @"cityCd":cityCd};
    
    __weak id weakSelf = self;
    id message = [UPWMessage messageWithUrl:@"bill.brandDetail" params:params encrypt:NO isPost:NO hostType:@"0"];
    
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        
        [weakSelf dismissLoading];
        BOOL isOn = [responseJSON[kJSONParamsKey][@"favorSt"] isEqualToString:@"1"];
        [weakSelf refreshFavoriteStatus:isOn];
    } fail:^(NSError *error) {
        
        [weakSelf dismissLoading];
        
        // 网络错误，收藏状态不改变，保持以前的状态。
    }];
}


// 刷新Panel里面收藏按钮UI状态。
- (void)refreshFavoriteStatus:(BOOL)isOn
{
    [_favBtn setImage:[UIImage imageNamed:(isOn ? @"favorite_done" : @"favorite")] forState:UIControlStateNormal];
    [_favBtn setTitle:(isOn ? UP_STR(@"kStrUnSaveFavorite") : UP_STR(@"kStrSaveFavorite")) forState:UIControlStateNormal];
    
    _isPoiSaved = isOn;
}

#pragma mark -
#pragma mark - Private Methods

- (void)configNavBarRightButton
{
    // 当页面加载成功以后，显示标题栏右边按钮
    if((_webData.eRightBtn & ERightBtnShare) && [UPWSharePanel isAvailableForShare]) {
        // 分享
        [self setRightButtonWithImage:@"share" target:self action:@selector(shareButtonClick:)];
    }
    else if(_webData.eRightBtn & ERightBtnBill) {
        // 账单模块查看半年花费。
        [self setRightButtonWithImageName:nil title:UP_STR(@"String_TrendAnalysis") target:self action:@selector(showCostTrendPage:)];
    }
    
    if(_webData.eRightBtn & ERightBtnRating) {
        // 评论列表上面的写评论
        [self setRightButtonWithImage:@"comment_navbar" target:self action:@selector(commentBtnClickAction:)];
    }
}

#pragma mark - Notification

- (void)openLoginPage
{
    [UPWBussUtil showLoginWithSuccessBlock:nil cancelBlock:nil completion:nil];
}

// 收到kNCEnterBackground通知，关掉当前打开的系统分享控件
- (void)dismissShareSystemCtrlComponents
{
    if([self.presentedViewController isKindOfClass:NSClassFromString(@"MFMessageComposeViewController")] || [self.presentedViewController isKindOfClass:NSClassFromString(@"SLComposeViewController")]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark -
#pragma mark - UPWSharePanelDelegate

// 用户点击某一种分享方式
- (void)didSelectShareType:(UPShareType)shareType
{
    UPShareContent* prefillContent = [self shareContentByType:shareType];
    ShareMgr* instance = [ShareMgr instance];
    
    switch (shareType) {
        case UPWeiXin:
            [instance openWeixinWithAppKey:kWXAppKey content:prefillContent];
            break;
            
        case UPWeiXinGroup:
            [instance openWeixinGroupWithAppKey:kWXAppKey content:prefillContent];
            break;
            
        case UPSinaWeiBo:
            [instance openSinaWeiboWithAppKey:kSinaWBAppKey content:prefillContent topVC:self];
            break;
            
        case UPSMS:
            [instance openSmsWithContent:prefillContent topVC:self];
            break;
            
        default:
            break;
    }
}

/**
 * 获取分享内容 getShareData(clientType,channel,contentType)
 * 参数:clientType-客户端类型,0:短信，1:微博，2:邮件, 3:微信 4:微信朋友圈
 * 参数:channel-分享渠道,0:安卓,1:ios
 * 参数:contentType-内容类型,0:优惠券,1:电子票,2:积分商户,3:活动, 4:积分券，5:商户详情
 * 返回值(json字符串),该返回值只针对ios客户端,{"body":"xxx","subject":"yyy"}。
 * 返回值(调用安卓接口),该返回值只针对安卓客户端。
 */
- (id)shareContentByType:(UPShareType)eShareType
{
    if(_webData.eShareType == EShareTypeApp) {
        // 推荐，分享APP, 分享内容是写死的，单独处理。
        return [UPWBussUtil shareContentForType:eShareType withJiaoFeiDest:nil isForApp:YES];
    }
    
    // ShareMgr 的接口与JS端定义的接口对应转化。
    NSInteger channel = -1;
    switch (eShareType) {
        case UPWeiXin:
            channel = 3;
            break;
        case UPWeiXinGroup:
            channel = 4;
            break;
        case UPSinaWeiBo:
            channel = 1;
            break;
        case UPSMS:
            channel = 0;
            break;
        default:
            break;
    }
    
    NSAssert(channel >= 0, @"Your share type is not supported");
    
    // 执行JS脚本获取分享内容
    NSString * shareContent;
    if(_webData.eShareType == EShareTypeUniversalWebDriven) {
        // WEB端全Driven模式，无需传入票券类型，JS自己知道。
        shareContent = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"UP.M.Share.getData(%ld, 1)", (long)channel]];
    }
    else {
        // 以前老模式，必须传入票券类型作为参数。
        shareContent = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"UP.M.Share.getData(%ld, 1, %ld)", (long)channel, (long)_webData.eShareType]];
    }
    
    NSDictionary * obj = nil;
    
    if(!UP_IS_NIL(shareContent)) {
        // sina weibo，客户端特殊处理。
        // 账单项目，直接跳到钱包，无需URL转换。
        if((1 == channel) && ([UPWWebUtility isMyBillsShare:_webData] == NO)) {
            // 需求：微博分享出去的链接打开直接跳转到钱包网站页面，所以要做必要的URL重组工作。分享内容中包含模板URL，需要替换成票券实际的URL。
            NSString * webUrl = [UPWWebUtility webUrlWithWebData:_webData];
            //UPDINFO(@"webUrl = %@", webUrl);
            shareContent = [shareContent stringByReplacingOccurrencesOfString:@"@WEIBO_WEBLINK_URL@" withString:webUrl];
        }
        
        NSError * err = nil;
        obj = [NSJSONSerialization JSONObjectWithData:[shareContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    }
    
    if(!obj) {
        // 微信分享，必须提供其url，否则调用时会崩溃。
        obj = [NSDictionary dictionaryWithObjectsAndKeys:@"shareUrl", self.startPage, nil];
    }
    
    UPShareContent * shareContentObj = [UPWWebUtility shareContentWithType:eShareType data:obj bindingObj:_sharePanel];
    return shareContentObj;
}

#pragma mark - UPWFlipMapMgrDataSource

- (NSArray *)fetchMapData
{
    // map所有的点。
    NSArray * mapData;
    
    // 向JS获取所有要MAP的点的数据。
    NSString * mapDataGotByJS = [self.webView stringByEvaluatingJavaScriptFromString:@"UP.M.NAPI.nativeCall('lookMapList')"];
    
    if([mapDataGotByJS length] > 0) {
        NSError * err = nil;
        id obj = [NSJSONSerialization JSONObjectWithData:[mapDataGotByJS dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
        if(obj && [obj isKindOfClass:[NSDictionary class]]) {
            mapData = ((NSDictionary*)obj)[@"data"];
        }
    }
    
    return mapData;
}

// 判断当前WebVC是否是在最上面
- (BOOL)isNavTopVC
{
    return (self == self.navigationController.viewControllers.lastObject);
}

#pragma mark - show / hide navigation bar
- (void)setNavigationBarHidden:(BOOL)hideNavigationBar toolBarHidden:(BOOL)hideToolBar
{
    //UPDINFO(@"----- Before");
    [self debugViews];
    
    _isNaviBarHidden = hideNavigationBar;
    
    if(hideNavigationBar) {
        // 隐藏NavigationBar
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        CGRect rcScreen = [UIScreen mainScreen].bounds;
        // 隐藏导航栏以后，需求是NavBar上除了顶端20pixes的statusBar以外，其他全部变成可显示区域。
        if (UP_iOSgt7) {
            // 重写base基类，_contentView将statusBar渲染成白色了。
            self.edgesForExtendedLayout = UIRectEdgeNone;
            CGRect rc = rcScreen;
            _contentView.frame = rc;
            _contentView.backgroundColor = [UIColor blackColor];
            
            self.edgesForExtendedLayout = UIRectEdgeTop;
        }
        else {
            CGRect rc = rcScreen;
            _contentView.frame = rc;
        }
        
        CGRect rc = _contentView.bounds;
        if (UP_iOSgt7) {
            rc.origin.y = kStatusBarHeight;
            rc.size.height -= rc.origin.y;
        }
        else {
            rc.size.height -= kStatusBarHeight;
        }
        
        if(!hideToolBar) {
            rc.size.height -= kWebToolViewHeight;
        }
        self.webView.frame = rc;
        
        _topOffsetBak = _topOffset;
    }
    else {
        // 展现NavigationBar
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        _topOffset = _topOffsetBak;
        
        CGRect rc = [UIScreen mainScreen].bounds;
        if(_topOffset == 0) {
            rc.origin.y += _topOffset;
            rc.size.height -= kNavigationBarHeight + kStatusBarHeight;
        }
        else {
            rc.origin.y += _topOffset;
            rc.size.height -= rc.origin.y;
        }
        _contentView.frame = rc;
        
        rc = _contentView.bounds;
        if(!hideToolBar) {
            rc.size.height -= kWebToolViewHeight;
        }
        self.webView.frame = rc;
    }
    
    CGSize contentSize = self.webView.scrollView.contentSize;
    if(contentSize.height <= self.webView.bounds.size.height) {
        contentSize.height = self.webView.bounds.size.height + 27.0f;
    }
    
    self.webView.scrollView.contentSize = contentSize;

    // 设置ToolBar
    [self setToolBarHidden:hideToolBar];
    
    //UPDINFO(@"----- After");
    [self debugViews];
}

#pragma mark - show / hide tool bar
- (void)setToolBarHidden:(BOOL)hideToolBar
{
    if(hideToolBar) {
        // 隐藏
        _toolBar.hidden = YES;
    }
    else {
        // 显示
        if(!_toolBar) {
            _toolBar = [[UPWWebToolView alloc] initWithWebViewController:self];
            _toolBar.delegate = self;
            [_contentView addSubview:_toolBar];
        }
        else {
            CGRect rc = _toolBar.frame;
            rc.origin.y = CGRectGetMaxY(self.webView.frame);
            _toolBar.frame = rc;
            [_contentView bringSubviewToFront:_toolBar];
        }
        
        _toolBar.hidden = NO;
        
        [_toolBar updateBtnsStatus];
    }
    
    self.hasToolbar = !hideToolBar;
}

- (void)debugViews
{
    return;
    UPDINFO(@"------------\n");
    UPDINFO(@"self.view.frame = %@", NSStringFromCGRect(self.view.frame));
    
    UPDINFO(@"_contentView.frame = %@", NSStringFromCGRect(_contentView.frame));
    
    for(UIView * subView in _contentView.subviews) {
        UPDINFO(@"subView.frame = %@", NSStringFromCGRect(subView.frame));
    }
    
    UPDINFO(@"self.webView.scrollView.contentOffset = %@", NSStringFromCGPoint(self.webView.scrollView.contentOffset));
    UPDINFO(@"self.webView.scrollView.contentSize = %@", NSStringFromCGSize(self.webView.scrollView.contentSize));
    UPDINFO(@"self.webView.scrollView.contentInset = %@", NSStringFromUIEdgeInsets(self.webView.scrollView.contentInset));
}

#pragma mark - alert
- (void)alertView:(UPXAlertView *)alertView onDismiss:(NSInteger)buttonIndex
{
    [self.webAppAlertViewDelegate buttonOKClicked:alertView.tag];
}

- (void)alertViewOnCancel:(UPXAlertView *)alertView
{
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
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 请求 preHandle

// 进入支付插件
- (void)gotoPayPluginCode:(NSString*)code message:(NSString *)message
{
    [UP_NC postNotificationName:kUPXNotfifcationWebPluginPayOrderPrehandle object:nil userInfo:@{kUPWebPluginPayToJSResultCode: code, kUPWebPluginPayToJSResultMessage:message}];
}

#pragma mark - plugin控制NavBar上的显示元素

- (void)setNavBarWithArgs:(NSDictionary *)args
{
    if(args.count == 0) {
        return;
    }
    
    NSString * title = args[@"title"];
    if(!UP_IS_NIL(title)) {
        [self setNaviTitle:title];
    }
    
    if([args[@"showShare"] boolValue]) {
        // 分享
        [self setRightButtonWithImage:@"share" target:self action:@selector(shareButtonClick:)];
    }
}

@end

