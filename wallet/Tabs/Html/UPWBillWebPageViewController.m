//
//  UPWBillWebPageViewController.m
//  CHSP
//
//  Created by jhyu on 13-10-25.
//
//

#import "UPWBillWebPageViewController.h"
#import "UPWRatingViewController.h"
#import "UPWBaseNavigationController.h"
#import "UPWLoginViewController.h"
#import "UPWSharePanel.h"
#import "UPWGlobalData.h"
#import "UPWFlipMapMgr.h"
#import "UPWWebData.h"
#import "UPWMessage.h"
#import "UPWPanel.h"
#import "UPWBussUtil.h"
#import "UPWWebUtility.h"
#import "UPWNotificationName.h"
#import "NSString+IACExtensions.h"
#import "ShareMgr/ShareMgr.h"
#import "UPWWebToolView.h"
#import "UPXConstStrings.h"
#import "UPXConstKey.h"
#import "UPXUtils.h"

typedef void (^addMyFavBtnBlcok)(BOOL isOn);

@interface UPWBillWebPageViewController () <UPWSharePanelDelegate, UPWFlipMapMgrDataSource> {
    UPWWebData*      _webData;
    UPWSharePanel*   _sharePanel;
    
    NSDictionary*  _params; // 页面WEB端参数
    UPWPanel*       _panel;  // 收藏Panel
    UIButton*      _favBtn;
    BOOL           _isPoiSaved;  // 记录当前收藏状态，YES表示已经收藏。
    BOOL           _isPageRefresh;  // 页面Pop返回时是否需要重新刷新，默认值为NO。
}

@property (nonatomic,strong) UPWWebToolView* toolBar;

// order.postHandle 上送的 orderid和ordertime
@property (nonatomic,copy) NSString *posthandleOrderId;
@property (nonatomic,copy) NSString *posthandleOrderTime;

@end


@implementation UPWBillWebPageViewController

#pragma mark -
#pragma mark - System methods

- (id)initWithWebData:(UPWWebData *)webData
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _webData = webData;
        self.startPage = _webData.startPage;
        DDLogCDebug(@">>> self.startPage = %@", self.startPage);
        
        // 事件处理中需要一些参数信息，例如"brandId"等等，从self.startPage中Parse.
        NSArray * components = [self.startPage componentsSeparatedByString:@"?"];
        // 从参数对中Parse.
        _params = [components.lastObject parseURLParams];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_panel removeFromSuperview];
}

- (void)openSharePanel
{
    [self shareButtonClick:nil];
}

- (void)refreshPageAfterLoginSucceed
{
    _isPageRefresh = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString * title = self.title;
    if(UP_IS_NIL(title)) {
        title = _webData.navigationBarTitle;
    }
    [self setNaviTitle:title];
    
    self.webView.scrollView.bounces = YES;
    self.webView.scrollView.alwaysBounceVertical = YES;
    self.webView.scalesPageToFit = YES;
    
    if(self.startPage.length > 0) {
        if(self.isLoadingView) {
            [self showLoadingWithMessage:UP_STR(@"kStrLoading")];
        }
        else {
            [self showWaitingView:UP_STR(@"kStrWaiting")];
        }
    }
    
    // 监听分享结果通知，是成功还是失败？
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareResultNotification:) name:kNotificationShareResult object:nil];
    
    // 监听密钥超时通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionKeyTimeout) name:kNotificationSessionKeyTimeout object:nil];
    
    // 评论页面提交成功以后刷新页面
    if(_webData.eRightBtn & ERightBtnRating) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshComments) name:kNotificationRefreshComments object:nil];
    }
    
    // 打开登录页面, 注意：只监听自己这个页面的。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openLoginPage) name:kNotificationOpenLoginPage object:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _panel.hidden = NO;
    
    if(_isPageRefresh && [UPWGlobalData sharedData].isLoginStatus) {
        [self.webView reload];
        [_contentView bringSubviewToFront:self.webView];
        _isPageRefresh = NO; // 重置标记。
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _panel.hidden = YES;
}

#pragma mark -
#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [super webViewDidFinishLoad:webView];
    [self dismissAll];
    [self configNavBarRightButton];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [super webView:webView didFailLoadWithError:error];
    [self dismissAll];
    [self configNavBarRightButton]; // DEBUG
    
    // ~ https://discussions.apple.com/thread/1727260?start=0&tstart=0
    if (error.code != NSURLErrorCancelled) {
        [self showFlashInfo:UP_STR(@"String_JSON_Error")];
    }
}

#pragma mark -
#pragma mark - Actions

// 分享按钮点击事件
- (void)shareButtonClick:(id)sender
{
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
}

// 用户评论，打分页面打开事件
- (void)commentBtnClickAction:(id)sender
{
    if (![UPWGlobalData sharedData].isLoginStatus) {
        [self openLoginPage];
        return;
    }
    
    // Plugin必须传递@"brandId"字段
    if([_params[@"brandId"] length] == 0) {
        return;
    }
    
    UPWRatingViewController * ratingVC = [[UPWRatingViewController alloc] initWithBrandId:_params[@"brandId"]];
    
    [self.navigationController pushViewController:ratingVC animated:YES];
}

- (void)showBillPage:(id)sender
{
    NSDictionary * params = @{@"pageUrl":@{@"uri":@"hybrid_v2/html/data/expensetrend.html", @"params":@{}}, @"navBar":@{@"title":UP_STR(@"kStrMyCostTrend")}};
    UPWWebData * webData = [[UPWWebData alloc] initWithLaunchType:ELaunchTypeUniversalWebDriven poiData:params];
    [self.navigationController pushViewController:[[UPWBillWebPageViewController alloc] initWithWebData:webData] animated:YES];
}

#pragma mark -
#pragma mark - Action (Favorite)

// 收藏（取消）收藏
- (void)favBtnClickAction:(id)sender
{
    // 需要登陆
    if(![UPWGlobalData sharedData].isLoginStatus) {
        [self openLoginPage];
        return;
    }
    
    NSString * brandId = _params[@"brandId"];
    NSString * cityCd = _params[@"cityCd"];
    
    if(!brandId || !cityCd) {
        return;
    }
    
    // 将收藏状态上报服务器
    NSDictionary * params = @{@"brandId":brandId, @"cdhdUsrId":UP_SHDAT.userInfoModel.userIdC, @"cityCd":cityCd, @"accTp":(_isPoiSaved ? @"0" : @"1")};
    UPWMessage * message = [UPWMessage messageWithUrl:@"brand/app/favorBrand" params:params cmd:nil ver:nil encrypt:YES isPost:YES];
    __weak id weakSelf = self;
    
    [self showLoadingWithMessage:UP_STR(@"kStrLoading")];
    
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
    // 组装提示消息
    NSString* message;
    if(_isPoiSaved) {
        message = UP_STR(@"kStrUnSaveFavorite");
    }
    else {
        message = UP_STR(@"kStrSaveFavorite");
    }
    
    NSString * status;
    id value = responseJSON[@"data"][@"favorResult"];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChangeFavorStateSucceed object:nil userInfo:@{@"state":@(_isPoiSaved), @"brandId":_params[@"brandId"]}];
    
    // 通知我的账户页面, 更新收藏商户数字。
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshAccountInfo object:nil];
}

- (void)didSaveFavoriteWithError:(NSError *)error
{
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


- (void)setFavoriteStatus
{
    // 没有登录，无法获取其状态，标记为未收藏。
    if(![UPWGlobalData sharedData].isLoginStatus) {
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
    
    [self showLoadingWithMessage:UP_STR(@"kStrLoading")];
    NSDictionary * params = @{@"brandId":brandId, @"cityCd":cityCd};
    
    __weak id weakSelf = self;
    id message = [UPWMessage messageWithUrl:@"bill/brandDetail" params:params cmd:nil ver:nil encrypt:NO isPost:NO];
    
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        
        [weakSelf dismissLoading];
        [weakSelf refreshFavoriteStatus:[responseJSON[@"data"][@"favorSt"] isEqualToString:@"1"]];
    } fail:^(NSError *error) {
        
        [weakSelf dismissLoading];
        
        // 网络错误，收藏状态不改变，保持以前的状态。
    }];
}


// 刷新Panel里面收藏按钮UI状态。
- (void)refreshFavoriteStatus:(BOOL)isOn
{
    [_favBtn setImage:[UIImage imageNamed:(isOn ? @"favorite_done" : @"favorite_grey")] forState:UIControlStateNormal];
    
    _isPoiSaved = isOn;
}

#pragma mark -
#pragma mark - Private Methods

- (void)configNavBarRightButton
{
    // 当页面加载成功以后，显示标题栏右边按钮
    if(_webData.eRightBtn & ERightBtnMap) {
        // 地图
        UPFlipMapMgr * flipMapMgr = [[UPFlipMapMgr alloc] initWithContentView:_contentView flipPairView:self.webView];
        [flipMapMgr setBarIcon:@"shop_list" ownerVC:self];
        flipMapMgr.dataSource = self;
    }
    else if((_webData.eRightBtn & ERightBtnShare) && [UPWSharePanel isAvailableForShare]) {
        // 分享
        [self setRightButtonWithImageName:@"share" title:nil target:self action:@selector(shareButtonClick:)];
    }
    else if(_webData.eRightBtn & ERightBtnBill) {
        // 账单模块查看半年花费。
        [self setRightButtonWithImageName:@"half_year_bill" title:nil target:self action:@selector(showBillPage:)];
    }
    
    // 商户详情， 新设计，收藏和评论用底部Panel显示
    if(_webData.eRightBtn & ERightBtnRating && _webData.eRightBtn & ERightBtnFavorite) {
        _panel = [[UPWPanel alloc] init];
        // 收藏商户
        _favBtn = [_panel appendButtonWithImageName:@"favorite_grey" highlightImageName:@"favorite_highlight" title:UP_STR(@"kStrSaveFavorite") target:self action:@selector(favBtnClickAction:)];
        // 写评论
        [_panel appendButtonWithImageName:@"comment_panel" highlightImageName:@"comment_highlight" title:UP_STR(@"kStrUserRating") target:self action:@selector(commentBtnClickAction:)];
        [_panel showInView:[[UIApplication sharedApplication] keyWindow]];
        
        // 设置收藏按钮状态
        [self setFavoriteStatus];
    }
    else if(_webData.eRightBtn & ERightBtnRating) {
        // 评论列表上面的写评论
        [self setRightButtonWithImageName:@"comment_white" title:nil target:self action:@selector(commentBtnClickAction:)];
    }
}

- (void)openLoginPage
{
    UPWBaseNavigationController * navVC = [[UPWBaseNavigationController alloc] initWithRootViewController:[[UPWLoginViewController alloc] init]];
    [self presentViewController:navVC animated:YES completion:nil];
}

#pragma mark -
#pragma mark - UPWSharePanelDelegate

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
        shareContent = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"UP.M.Share.getData(%ld, 1, %ld)", (long)channel, _webData.eShareType]];
    }
    
    if(shareContent.length == 0) {
        return nil;
    }
    
    // sina weibo，客户端特殊处理。
    // 账单项目，直接跳到钱包，无需URL转换。
    if((1 == channel) && ([UPWWebUtility isMyBillsShare:_webData] == NO)) {
        // 需求：微博分享出去的链接打开直接跳转到钱包网站页面，所以要做必要的URL重组工作。分享内容中包含模板URL，需要替换成票券实际的URL。
        NSString * webUrl = [UPWWebUtility webUrlWithWebData:_webData];
        //UPDINFO(@"webUrl = %@", webUrl);
        shareContent = [shareContent stringByReplacingOccurrencesOfString:@"@WEIBO_WEBLINK_URL@" withString:webUrl];
    }
    
    NSError * err = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:[shareContent dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
    
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

- (EMapAnnotation)mapAnnotationType
{
    return EAnnotationCoupon;
}

#pragma mark - 通知事件处理

#pragma mark 登录超时

- (void)sessionKeyTimeout
{
    if([self isNavTopVC] && (self.presentedViewController == nil)) {
        // 只有最上面的VC并且没有打开其他VC的才会处理超时通知， 打开其他VC的，其他VC会处理超时事件。
        if ([UPWGlobalData sharedData].isLoginStatus) {
            [UPWGlobalData sharedData].isLoginStatus = NO;
            //[UPWGlobalData sharedData].accountInfoModel = nil;
            
            [self dismissAll];
            
            // 要求用户重新登录
            UPWBaseNavigationController * navVC = [[UPWBaseNavigationController alloc] initWithRootViewController:[[UPWLoginViewController alloc] init]];
            [self presentViewController:navVC animated:YES completion:nil];
        }
    }
}

#pragma mark 分享操作结果

- (void)shareResultNotification:(NSNotification *)notification
{
    if([self isNavTopVC]) {
        // 只有最上面的VC才会处理分享结果通知，因为此通知在所有的BillWebVC里面都注册过。
        EShareResult eResult = (EShareResult)[notification.userInfo[kResultCode] integerValue];
        NSString * message;
        if(eResult == EShareSuccess) {
            message = UP_STR(@"kStrShareSuccess");
        }
        else if(eResult == EShareFailed) {
            message = UP_STR(@"kStrShareFail");
        }
        
        if(message) {
            [self showFlashInfo:message];
        }
    }
}

- (BOOL)isNavTopVC
{
    return (self == self.navigationController.viewControllers.lastObject);
}

// 刷新评论页面
- (void)refreshComments
{
    // 评论提交以后，JS需要知道反馈结果来决定WEB页面是否需要刷新
    // 调用JS，JS会启动Plugin来起写评论页面。
    [self.webView stringByEvaluatingJavaScriptFromString:@"UP.M.NAPI.nativeCall('refreshComment')"];
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
- (void)getOrderPreHandle:(NSString *)tn
{
    UPDSTART();
    UPWMessage *message=nil;
    
    // 如果是 第三方应用，上送appID和appName
    if ([UPXUtils isThirdPartyApp:self.appInfo.appId]) {
        message = [UPWMessage publicPayOrderPreHandleWithTn:tn
                                                  sessionId:nil
                                                      appId:self.appInfo.appId
                                                    appName:self.appInfo.name
                                                     amount:nil
                                        isSendMerchantOrder:YES];
    }
    else{
        message = [UPWMessage publicPayOrderPreHandleWithTn:tn
                                                  sessionId:nil
                                                      appId:self.appInfo.appId
                                                    appName:nil
                                                     amount:nil
                                        isSendMerchantOrder:NO];
        
    }
    
    if (message) {
        [self showWaitingView:UP_STR(kPleaseWaiting)];
        
        __weak typeof(self) weakSelf = self;
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
- (void)getOrderPostHandle
{
    UPDSTART();
    UPWMessage *message = [UPWMessage orderPostHandleWithOrderId:self.posthandleOrderId
                                                       orderTime:self.posthandleOrderTime
                                                  classification:[UPXUtils getAppClassificationWithAppId:self.appInfo.appId]];
    
    // 偷偷发请求
    // 原来调用[UP_App.silenceViewController sendOrderPostHandleWithOrderId:_posthandleOrderId
    //                                                       orderTime:_posthandleOrderTime
    //                                                  classification:[UPXUtils getAppClassificationWithAppId:_app_id]];
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        
    } fail:^(NSError *error) {
        
        //[weakSelf showFlashInfo:[weakSelf stringWithError:error]];
        
    }];
    
    UPDEND();
}


// 进入支付插件
- (void)gotoPayPluginCode:(NSString*)code message:(NSString *)message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUPXNotfifcationWebPluginPayOrderPrehandle object:nil userInfo:@{kUPWebPluginPayToJSResultCode: code, kUPWebPluginPayToJSResultMessage:message}];
}

@end
