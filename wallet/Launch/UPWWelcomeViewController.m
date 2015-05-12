//
//  UPWWelcomeViewController.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWWelcomeViewController.h"
#import "UPWBaseNavigationController.h"
#import "UPWHomeViewController.h"
#import "UPWFruitViewController.h"
#import "UPWShoppingCartViewController.h"
#import "UPWMineViewController.h"
#import "AppDelegate.h"
#import "UPWCryptUtil.h"
#import "UPWRotateAnimationView.h"
#import "UPWCarouselView.h"
#import "UPWNotificationName.h"
#import "UPWImageUtil.h"
#import "UPWLocalStorage.h"
#import "UPWFileUtil.h"
#import "UPWPathUtil.h"
#import "UPWAppInfoModel.h"
#import "UPWUpdateInfoModel.h"
#import "UPWUiUtil.h"
#import "UPXConstKey.h"
#import "UPWExUIView.h"
#import "UPWPlistUtil.h"
#import "UPWBussUtil.h"
#import "UPXUtils.h"
#import "UPWAccountInfoModel.h"
#import "UPWShoppingCartModel.h"

@interface UPWWelcomeViewController()<UPWCarouselViewDatasource, UPWCarouselViewDelegate, UITabBarControllerDelegate>
{

    UIImageView* _welcomeImageView;
    UPWCarouselView* _guideCarouselView;
    UPWRotateAnimationView* _rotateAnimationView;
    UITapGestureRecognizer* _tapGR;
    NSArray* _guideImageArray;
}

@end


@implementation UPWWelcomeViewController


-(void)dealloc
{
    
}

//欢迎页面采集
- (void)trackPageBegin
{
    [UPWDataCollectMgr upTrackPageBegin:@"WelcomeView"];
}

- (void)trackPageEnd
{
    [UPWDataCollectMgr upTrackPageEnd:@"WelcomeView"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // 加载启动Default启动画面
    _welcomeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _welcomeImageView.image = [UPWImageUtil image568H:@"LaunchImage"];

    [self.view addSubview:_welcomeImageView];
    
    UIImage* image = UP_GETIMG(@"icon_activity");//welcome_loading
    
    CGFloat y = 270;
    if (UP_IPHONE5)
    {
        y = 313;
    }
    else if (UP_IPHONE6)
    {
        y = 363;
    }
    else if (UP_IPHONE6_PLUS)
    {
        y = 397;
    }
    _rotateAnimationView = [[UPWRotateAnimationView alloc] initWithFrame:CGRectMake((_screenWidth-image.size.width)/2, y, image.size.width, image.size.height)];
    _rotateAnimationView.image = image;
    [self.view addSubview:_rotateAnimationView];
    [_rotateAnimationView startRotating];
    
    //客户端初始化
    [self sysInit];
    
    // 促使用户打开"我的"Tab（支持微信唤醒功能）
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMineTab) name:kNotificationOpenMineTab object:nil];
    
    // 监听第三方APP打开票券详情页面，比如微信。
//    [UP_NC addObserver:self selector:@selector(openCouponPageByWeixinNotification:) name:kNotificationOpenCouponPageByWeixin object:nil];
}

#pragma mark - 客户端初始化
- (void)sysInit
{
    UPWMessage* message = [UPWMessage sysInit];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary * response) {
        [wself finishedStartupWallet:response[@"data"]];
    } fail:^(NSError * err) {
        [self showFlashInfo:@"初始化失败"];
        UPDNETMSG(@"err = %@",err);
        [wself finishedStartupWallet:nil];
    }];
}

#pragma mark - 客户端启动完成

- (void)finishedStartupWallet:(NSDictionary *)params
{
    [_rotateAnimationView stopRotating];
    _rotateAnimationView.hidden = YES;
    
    // 检查初始化请求是否成功，如果有，则成功启动客户端
    if (params)
    {
        UP_SHDAT.sysInitModel = [[UPWSysInitModel alloc] initWithDictionary:params error:nil];
        
        //版本更新, 在 sys.init 中也需要处理这个更新版本的, 如果sys.init 成功了, checkversion 返回很慢, 可能走入一个不应该看到的页面, 这里也有问题就是, 网络失败, sys.init 和 checkversion 失败都可以进入客户端不升级
        NSDictionary* updateInfo = params[@"updateInfo"];
        UPWUpdateInfoModel* updateModel = [[UPWUpdateInfoModel alloc] initWithDictionary:updateInfo error:nil];
        [self checkNeedUpdateClient:updateModel];
        
    }
    
    //如果用户之前登录过, 恢复登录信息
    NSError* error = nil;
    NSDictionary* accountInfoDict = [UPWFileUtil readContent:[UPWPathUtil accountInfoPlistPath]];
    UPWAccountInfoModel* accountInfoModel = [[UPWAccountInfoModel alloc] initWithDictionary:accountInfoDict error:&error];
    if (!error && accountInfoModel)
    {
        [UPWGlobalData sharedData].hasLogin = YES;
        UP_SHDAT.accountInfo = accountInfoModel;
        [UPWGlobalData sharedData].Authorization = accountInfoModel.token;
    }
    //暂不显示轮播图，直接进入首页
//  if ([self shouldShowGuideImage])
//  {
//       // 客户端第一次启动,展示wallet功能介绍页面
//       [self setupNewVersionGuideView];
//  } else {
        [UIApplication sharedApplication].statusBarHidden = NO;
        [self setupMainViewControllers:YES];
//  }
}

- (void)checkVersion:(NSString*)flag
{
    UPWMessage* message = [UPWMessage sysCheckversion:flag];
    
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *response) {
        
        //客户端版本升级
        NSDictionary* updateInfo = response[@"params"][@"updateInfo"];
        UPWUpdateInfoModel* updateModel = [[UPWUpdateInfoModel alloc] initWithDictionary:updateInfo error:nil];
        [wself checkNeedUpdateClient:updateModel];
    } fail:nil];
}

#pragma mark - 客户端是否需要升级
- (void)checkNeedUpdateClient:(UPWUpdateInfoModel*)model
{
    if (model) {
        NSString* need_update = model.needUpdate;
        NSString* desc = model.desc;
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = desc;
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:16];
        [label setNumberOfLines:0];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize labelsize = [desc sizeWithFont:label.font constrainedToSize:CGSizeMake(240, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        label.frame = CGRectMake(10, 0, labelsize.width, labelsize.height);
        
        UIView* notice = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelsize.width+20, labelsize.height + 20)];
        notice.backgroundColor = [UIColor whiteColor];
        [notice addSubview:label];
        
        if ([need_update isEqualToString:@"1"]){
            // 可选升级
            [UPWUiUtil showAlertViewWithTitle:nil message:nil customView:notice cancelButtonTitle:UP_STR(@"String_UpdateLater") otherButtonTitles:@[UP_STR(@"String_UpdateNow")] special:-1 tag:0 completeBlock:^(UPXAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {//http://itunes.apple.com/cn/app/id600273928
                    UP_OPENURL(model.updateUrl);
                }
            }];
        }
        else if ([need_update isEqualToString:@"2"]){
            // 客户端强制升级，不再做后续操作
            [UPWUiUtil showAlertViewWithTitle:nil message:nil customView:notice cancelButtonTitle:nil otherButtonTitles:@[UP_STR(@"String_UpdateNow")] special:-1 tag:[UPXAlertView neverDismissTag] completeBlock:^(UPXAlertView *alertView, NSInteger buttonIndex) {
                UP_OPENURL(model.updateUrl);
            }];
        }
    }
}

#pragma mark -
#pragma mark 5: 客户端启动失败，点击重试
- (void)retryStarupWallet
{
    if (_tapGR) {
        [self.view removeGestureRecognizer:_tapGR];
    }
    _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRetryAction:)];
    [self.view addGestureRecognizer:_tapGR];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, _rotateAnimationView.center.y - 22, self.view.frame.size.width, 44)];
    label.tag = 1002;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    label.text = UP_STR(@"String_Sys_Init_Error");
    [self.view addSubview:label];
}

- (void)tapRetryAction:(UIGestureRecognizer*)gestureRecognizer
{
    if (_tapGR) {
        [self.view removeGestureRecognizer:_tapGR];
    }
    
    UILabel* label  = (UILabel*)[self.view viewWithTag:1002];
    [label removeFromSuperview];
    
    [_rotateAnimationView startRotating];
    _rotateAnimationView.hidden = NO;
    
    [self sysInit];
}

#pragma mark - 显示引导页面

- (BOOL)shouldShowGuideImage
{
    BOOL shouldShow = NO;
    
    // 判断是否APP为第一次安装使用
    NSString* lastVersion =  [[UPWLocalStorage lastVersion] substringToIndex:5];
    NSString* currentVersion = [[UPWAppUtil appVersion] substringToIndex:5];
    if (!lastVersion)
    {
        // 客户端为新安装的，需要显示引导页
        shouldShow = YES;
    }
    else if (![lastVersion isEqualToString:currentVersion])
    {
        // 小版本号不相同，需要显示引导页
        shouldShow = YES;
    }
    
    [UPWLocalStorage setLastVersion:[UPWAppUtil appVersion]];
    return shouldShow;
}

#pragma mark -
#pragma mark 创建欢迎页面
- (void)setupNewVersionGuideView
{
    [UPWDataCollectMgr upTrackPageBegin:@"TutorialView"];
    _guideImageArray = @[@"iOS1",@"iOS2",@"iOS3"];
    _guideCarouselView = [[UPWCarouselView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _guideCarouselView.datasource = self;
    _guideCarouselView.delegate = self;
    _guideCarouselView.bounces = NO;
    _guideCarouselView.showIndicator = YES;
    
    
    float hToBottom = 0;
    if (UP_IPHONE5)
    {
        hToBottom = 30;
    }
    else if (UP_IPHONE6)
    {
        hToBottom = 118/3.3;
    }
    else if (UP_IPHONE6_PLUS)
    {
        hToBottom = 118/3;
    }
    else
    {
        hToBottom = 30;
    }
    
    _guideCarouselView.pageControlButtomMargin = hToBottom;
    
    [self.view addSubview:_guideCarouselView];
}

#pragma mark -
#pragma mark 欢迎页面 UPWCarouselViewDatasource \ UPWCarouselViewDelegate
- (NSInteger)countOfCellForCarouselView:(UPWCarouselView*)carouselView
{
    return [_guideImageArray count];
}

- (UIView*)carouselView:(UPWCarouselView*)carouselView cellAtIndex:(NSInteger)index
{
    float hImgContent = 0;
    float hLbTitle = 0;
    float hLbContent = 0;
    float wImgContent = 0;
    float hBtnEnter = 0;
    if (UP_IPHONE5)
    {
        hImgContent = 105;
        hLbTitle = 35;
        hLbContent = 10;
        wImgContent = 232;
        hBtnEnter = 34;
    }
    else if (UP_IPHONE6)
    {
        hImgContent = 408/3.3;
        hLbTitle = 136/3.3;
        hLbContent = 40/3.3;
        wImgContent = UP_IPHONESIZE.width*0.725;
        hBtnEnter = 154/3.3;
    }
    else if (UP_IPHONE6_PLUS)
    {
        hImgContent = 408/3;
        hLbTitle = 136/3;
        hLbContent = 40/3;
        wImgContent = UP_IPHONESIZE.width*0.725;
        hBtnEnter = 154/3;
    }
    else
    {
        hImgContent = 105;
        hLbTitle = 35;
        hLbContent = 10;
        wImgContent = 232;
        hBtnEnter = 34;
    }
    
    NSArray * titles = @[UP_STR(@"String_Guide_Title0"),UP_STR(@"String_Guide_Title1")];
    NSArray * contents = @[UP_STR(@"String_Guide_Content0"),UP_STR(@"String_Guide_Content1")];
    NSArray * images = @[UP_GETIMG(@"guideImg1.jpg"),UP_GETIMG(@"guideImg2.jpg"),UP_GETIMG(@"guideImg4.jpg")];
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    imageView.image = [UPWImageUtil image568H:_guideImageArray[index]];
    imageView.userInteractionEnabled = YES;

    UIImageView * imgContent = [[UIImageView alloc]init];
    [imgContent setImage:images[index]];
    [imgContent setWidth:wImgContent];
    [imgContent setHeight:wImgContent];
    [imgContent setCenterX:imageView.centerX];
    [imgContent setFrameY:hImgContent];
    [imageView addSubview:imgContent];
    
    UILabel * lbTitle = [[UILabel alloc]init];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    [lbTitle setFont:[UIFont systemFontOfSize:18]];
    [lbTitle setTextColor:UP_COL_RGB(0X4A4A4A)];
    [lbTitle setBackgroundColor:[UIColor clearColor]];
    [lbTitle setWidth:80];
    [lbTitle setHeight:30];
    [lbTitle setCenterX:imageView.centerX];
    [lbTitle setCenterY:imgContent.bottom + 8 + hLbTitle];
    [lbTitle setText:((index > titles.count-1) ? @"" : titles[index])];
    [imageView addSubview:lbTitle];
    
    UILabel * lbContent = [[UILabel alloc]init];
    [lbContent setTextAlignment:NSTextAlignmentCenter];
    [lbContent setFont:[UIFont systemFontOfSize:15]];
    [lbContent setTextColor:UP_COL_RGB(0XA1A1A1)];
    [lbContent setBackgroundColor:[UIColor clearColor]];
    [lbContent setWidth:self.view.frame.size.width*3/4];
    [lbContent setHeight:30];
    [lbContent setCenterX:lbTitle.centerX + 5];
    [lbContent setCenterY:lbTitle.bottom + hLbContent];
    [lbContent setText:((index > titles.count-1) ? @"" : contents[index])];
    [imageView addSubview:lbContent];
    
    if (index == images.count-1)
    {
        UIButton * btnEnter = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnEnter setWidth:UPFloat(95)];
        [btnEnter setHeight:UPFloat(35)];
        [btnEnter setFrameY:imgContent.bottom + UPFloat(hBtnEnter)];
        [btnEnter setCenterX:imageView.centerX];
        [btnEnter setBackgroundImage:UP_GETIMG(@"ensureBtn") forState:UIControlStateNormal];
        //[btnEnter setTitle:UP_STR(@"String_Guide_Title") forState:UIControlStateNormal];
        //[btnEnter.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [imageView addSubview:btnEnter];
        [btnEnter addTarget:self action:@selector(closeGuideCarouselView:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel * lbBtn = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, UPFloat(80), UPFloat(30))];
        [lbBtn setBackgroundColor:[UIColor clearColor]];
        [lbBtn setTextColor:[UIColor whiteColor]];
        [lbBtn setTextAlignment:NSTextAlignmentCenter];
        [lbBtn setFont:[UIFont systemFontOfSize:16]];
        [lbBtn setText:UP_STR(@"String_Guide_Title")];
        [lbBtn setCenterX:btnEnter.centerX];
        [lbBtn setCenterY:btnEnter.centerY];
        [imageView addSubview:lbBtn];
    }
    
    return imageView;
}

- (void)carouselView:(UPWCarouselView*)carouselView didSelectAtIndex:(NSInteger)index
{
    //引导页页面不留action，按钮控制action
    return;
    //[self closeGuideCarouselView:nil];
}

- (void)closeGuideCarouselView:(id)sender
{
    [UPWDataCollectMgr upTrackPageEnd:@"TutorialView"];

    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self setupMainViewControllers:YES];
    
    [UIView animateWithDuration:2 animations:^{
        _guideCarouselView.layer.opacity = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [_guideCarouselView removeFromSuperview];
        }
    }];
}

#pragma mark - 创建Wallet首页的UITabBarController
- (void)setupMainViewControllers:(BOOL)FIRST//是否第一次打开客户端
{
    if (!UP_iOSgt7)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        CGRect frame = [UIScreen mainScreen].bounds;
        self.view.frame = CGRectMake(0, 20, frame.size.width, frame.size.height-20);
    }
    
    // 设置UITabBar样式
    [[UITabBar appearance] setBarStyle:UIBarStyleDefault];
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];//设置tabbar背景颜色
    [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];
    if (!UP_iOSgt7) {
        [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    }
    
    NSDictionary * attributesForNormal = nil;
    NSDictionary * attributesForSelected = nil;
    // ~ FixMe IOS6，票券详情页面点击短信分享闪退 http://172.17.249.10/NewSys/IPOC/TestBug/TestBugDetail.aspx?TestBugId=63974
    if(UP_iOSgt7) {
        attributesForNormal = @{NSForegroundColorAttributeName:UP_COL_RGB(0x999999), NSFontAttributeName:[UIFont systemFontOfSize:11]};
        
        attributesForSelected = @{NSForegroundColorAttributeName:UP_COL_RGB(0x09bb07), NSFontAttributeName:[UIFont systemFontOfSize:11]};
    }
    else {
        attributesForNormal = @{UITextAttributeTextColor:UP_COL_RGB(0x999999), UITextAttributeFont:[UIFont systemFontOfSize:11]};
        
        attributesForSelected = @{UITextAttributeTextColor:UP_COL_RGB(0x09bb07), UITextAttributeFont:[UIFont systemFontOfSize:11]};
    }
    
    [[UITabBarItem appearance] setTitleTextAttributes:attributesForNormal forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:attributesForSelected forState:UIControlStateSelected];
    [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -4)];

    _tabBarController = [[UITabBarController alloc] init];
    _tabBarController.delegate = self;
    _tabBarController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView animateWithDuration:1 animations:^{
        _welcomeImageView.layer.opacity = 0.0f;
    } completion:^(BOOL finished) {
        if (finished)
        {
            [_welcomeImageView removeFromSuperview];
        }
    }];
    
    [self.view insertSubview:_tabBarController.view belowSubview:_welcomeImageView];
    [self addChildViewController:_tabBarController];

    if (FIRST)//首次登陆直接进入，以后进入再手势密码操作完成后再进入
    {
        [self fillTheTabViewControllersContent];
    }
}

- (void)fillTheTabViewControllersContent
{
    NSArray* tabItems = UP_ARRAY(@"TabItem_titles");
    
    UPWHomeViewController* featuredVC = [[UPWHomeViewController alloc] init];
    UPWBaseNavigationController* homeNavi = [[UPWBaseNavigationController alloc] initWithRootViewController:featuredVC];
    homeNavi.tabBarItem = [self tabBarItemWithTitle:tabItems[0] selectedImage:@"tabbar_home_hl" unselectedImageName:@"tabbar_home"];
    
    UPWFruitViewController* couponVC = [[UPWFruitViewController alloc] init];
    UPWBaseNavigationController* couponNavi = [[UPWBaseNavigationController alloc] initWithRootViewController:couponVC];
    couponNavi.tabBarItem = [self tabBarItemWithTitle:tabItems[1] selectedImage:@"tabbar_fruit_hl" unselectedImageName:@"tabbar_fruit"];
    
    UPWShoppingCartViewController* cardsVC = [[UPWShoppingCartViewController alloc] init];
    UPWBaseNavigationController* cardsNavi = [[UPWBaseNavigationController alloc] initWithRootViewController:cardsVC];
    cardsNavi.tabBarItem = [self tabBarItemWithTitle:tabItems[2] selectedImage:@"tabbar_shoppingcart_hl" unselectedImageName:@"tabbar_shoppingcart"];
    
    UPWMineViewController* mineVC = [[UPWMineViewController alloc] init];
    UPWBaseNavigationController* mineNavi = [[UPWBaseNavigationController alloc] initWithRootViewController:mineVC];
    mineNavi.tabBarItem = [self tabBarItemWithTitle:tabItems[3] selectedImage:@"tabbar_mine_hl" unselectedImageName:@"tabbar_mine"];
    
    _tabBarController.viewControllers = @[homeNavi,couponNavi,cardsNavi,mineNavi];
    
    //标示我的消息中有推送信息
    self.dotImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"push_info@2x.png"]];
    self.dotImage.backgroundColor = [UIColor clearColor];
    CGRect tabFrame = _tabBarController.tabBar.frame;
    CGFloat x = ceilf(0.94 * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    self.dotImage.frame = CGRectMake(x, y, 8, 8);
    self.dotImage.hidden = YES;
    [_tabBarController.tabBar addSubview:self.dotImage];
    
    [UPWBussUtil refreshCartDot];
    
     //先注释掉推送功能
    //尝试上传device token(静默), 还必须满足device token已获取的先决条件
//    AppDelegate *myDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
//    [myDelegate trySendUploadDeviceToken:UPDeviceTokenPrerequisiteSysInit];;
//    
//    //如果是推送启动,则发送推送信息
//    [myDelegate handlePushMessageInfo];
}

- (UITabBarItem*)tabBarItemWithTitle:(NSString*)title selectedImage:(NSString*)selectedImageName unselectedImageName:(NSString*)unselectedImageName
{
    if (UP_iOSgt7) {
        UIImage* selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage* unselectedImage = [[UIImage imageNamed:unselectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem* tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:unselectedImage selectedImage:selectedImage];
        tabBarItem.imageInsets = UIEdgeInsetsMake(-3, 0, 3, 0);
        return tabBarItem;
    }
    else
    {
        UIImage* selectedImage = [UIImage imageNamed:selectedImageName];
        UIImage* unselectedImage = [UIImage imageNamed:unselectedImageName];
        
        UITabBarItem* tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:unselectedImage tag:0];
        [tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
        tabBarItem.imageInsets = UIEdgeInsetsMake(-3, 0, 3, 0);
        return tabBarItem;
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    UINavigationController* tabNavi = (UINavigationController*)viewController;
    if ( [[tabNavi.viewControllers firstObject] isKindOfClass:[UPWShoppingCartViewController class]])
    {
        //不登录也能显示购物车，也能购买
//        if (!UP_SHDAT.hasLogin) {
//            [UPWBussUtil showLoginWithSuccessBlock:^{
//                tabBarController.selectedIndex = 3;
//            } cancelBlock:nil completion:nil];
//            return NO;
//        }
    } else if ([[tabNavi.viewControllers firstObject] isKindOfClass:[UPWMineViewController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTapMineTab object:nil userInfo:nil];
    }
    return YES;
}

#pragma mark - 
#pragma mark 在我的栏目显示/隐藏推送信息标识
- (void) showPushInfoOnMineTab {
    
    self.dotImage.hidden = NO;
}

- (void) hidePushInfoOnMineTab {
    
    self.dotImage.hidden = YES;
}

#pragma mark - 被提出统一在这里弹框
//只能弹一个
static BOOL s_isKicking = NO;
- (void)handleLoginKicked:(NSNotification *)notification
{
    [super handleLoginKicked:notification];
    NSString* msg = @"用户异常";//notification.object;
    if (!s_isKicking && UP_SHDAT.hasLogin) {
        s_isKicking = YES;
        [self showAlertWithTitle:nil message:msg cancelButtonTitle:nil otherButtonTitle:UP_STR(@"String_LoginAgain") completeBlock:^(UPXAlertView *alertView, NSInteger buttonIndex) {
            s_isKicking = NO;
            [UPXUtils clearLoginStatus];
            [UPWBussUtil showLoginWithSuccessBlock:^{
                _tabBarController.selectedIndex = 3;
            } cancelBlock:^{
                _tabBarController.selectedIndex = 0;
            } completion:^{
                [_tabBarController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [obj popToRootViewControllerAnimated:NO];
                }];
            }];
        }];
    }
}

/*
#pragma mark - 微信唤醒
- (void)openMineTab
{
    for(UIViewController * vc in self.childViewControllers) {
        if([vc isKindOfClass:[UITabBarController class]]) {
            UITabBarController * tabVC = (UITabBarController *)vc;
            tabVC.selectedIndex = 4; // “我的”Tab
            break;
        }
    }
}

#pragma mark - 监听第三方APP打开票券详情页面，比如微信。
#pragma mark
- (void)openCouponPageByWeixinNotification:(NSNotification*)notification
{
    _tabBarController.selectedIndex = 0;
}
*/
@end
