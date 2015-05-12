//
//  AppDelegate.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDFileLogger.h"
#import "DDTTYLogger.h"
#import "CDVUserAgentUtil+Custom.h"
#import "NSObject+Swizzle.h"
#import "UPWWelcomeViewController.h"
#import "UPWNotificationName.h"
#import "UPWHttpMgr.h"
#import "UPWEnvMgr.h"
#import "../Tabs/Html/Share/ShareMgr/ShareMgr.h"
//#import "BMapKit.h"
#import <MAMapKit/MAMapKit.h>
#import "UPXConstKey.h"
#import "UPXNotificationBanner.h"
#import "UPWWebViewController.h"
#import "UPWImageUtil.h"
#import "UPWLocalStorage.h"

@interface AppDelegate ()
{
    NSDate* _enterForegroundDate;
    NSDate* _enterBackgroundDate;
   // BMKMapManager* _mapManager;
    
    BOOL _isRecievedRemoteOrderNotification;//区分是否收到了账单推送，收到消息为YES，处理之后改为NO
    BOOL _isWillEnterForeground; // 是否将进入前台
    BOOL _isActive; // 是否处于激活状态
    
    UPDeviceTokenPrerequisite _deviceTokenPrerequisite;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //收集数据以及错误日志
    [UPWDataCollectMgr startTrack];
    
    [UPWLocalStorage registerDefaultValue];
    
    //日志
    [self addLogger];
    
//    //百度地图SDK
//    [self initBaiduMapSDK];
    [self initGaoDeMap];
    
    //设置 host
    [UPWHttpMgr instance].hostName = [UPWEnvMgr appServerUrl];
    
    UPDNETMSG(@"\n\n\n****************************\nappServerUrl %@\nchspServerUrl %@\ncryptKey %@\n****************************\n\n\n\n",[UPWEnvMgr appServerUrl],[UPWEnvMgr chspServerUrl],[UPWEnvMgr cryptKey]);

    //修改Cordova的UserAgent
    [CDVUserAgentUtil swizzleClassMethod:@selector(originalUserAgent) withClassMethod:@selector(walletUserAgent)];

    //修改导航栏
    [self setupNavigationAppearance];
    
    //修改状态栏
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [self loadWelcomeview];
    
    //此处处理推送相关代码
//    [self dealPushNotificacton:launchOptions];
//    [self clearBadgeNumber];
    
    return YES;
}

//进入欢迎页面
-(void) loadWelcomeview
{
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    UIWindow *window = [[UIWindow alloc] initWithFrame:screenBounds];
    _rootViewController = [[UPWWelcomeViewController alloc] init];
    [window setRootViewController:_rootViewController];
    [window makeKeyAndVisible];
    [self setWindow:window];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
//    [UP_NC postNotificationName:kNCResignActive object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    _enterBackgroundDate = [NSDate date];
    
//    [UP_NC postNotificationName:kNCEnterBackground object:nil];
    
    if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1 && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_6_1)
    {
        //防止ios6下，中文输入时，lock screen,导致crash
        // Acquired additional time
        UIDevice *device = [UIDevice currentDevice];
        BOOL backgroundSupported = NO;
        if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
            backgroundSupported = device.multitaskingSupported;
        }
        
        if (backgroundSupported) {
            __block UIBackgroundTaskIdentifier backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
                [application endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
//    [UP_NC postNotificationName:kNCEnterForeground object:nil];
    
//    _isWillEnterForeground = YES;
//    _enterForegroundDate = [NSDate date];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
//    [self clearBadgeNumber];
    
//    _isWillEnterForeground = NO;
//    _isActive = YES;
    // 切回active状态，如果有没有处理的消息，则显示
//    if (!_isUPPayPluginShow && _isRecievedRemoteOrderNotification) {
//        [self showRemoteNotification];
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (!url) {  return NO; }
    UPDINFO(@"Url request from %@, %@", sourceApplication, [url absoluteString]);
    /*
    // 分享库首先会Handle此URL
    BOOL ret = [[ShareMgr instance] appDelegateOpenURL:url];
    if(ret) {
        // 处理成功，直接返回。
        return ret;
    }
    
    // 从微信打开票券页面启动钱包
    if([[url scheme] isEqualToString:@"chsp"]) {
        UP_SHDAT.launchUrlByWeixin = url;
        // 通知HomeVC有新的票券要打开。
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenCouponPageByWeixin object:nil];
        return YES;
    }
    */
    return NO;
}

#pragma mark - GaoDe Map
- (void)initGaoDeMap
{
    [MAMapServices sharedServices].apiKey = MAP_API_KEY;
}

- (void)setupNavigationAppearance
{
#warning 设置导航栏参数不区分ios系统，需要在ios6上测试
//    if (UP_iOSgt7) {
        [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
        [[UINavigationBar appearance] setBarTintColor:UP_COL_RGB(0x09bb07)];//设置导航栏背景颜色
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];//设置导航栏标题颜色
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];//修改导航栏返回按钮标题、返回按钮图像的颜色
//        [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"btn_back"]];//修改导航栏返回按钮的箭头图标
//        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"btn_back"]];
#warning 此处crash http://stackoverflow.com/questions/17480796/uiappearance-settranslucent-error-illegal-property-type-c-for-appearance-sette
//        [[UINavigationBar appearance] setTranslucent:YES];
//    }
//    else{
//        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_naviBar44.png"] forBarMetrics:UIBarMetricsDefault];
//    }
}

#pragma mark -
#pragma mark - 初始化logger
- (void)addLogger
{
#if TARGET_IPHONE_SIMULATOR
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    UPDINFO(@"doc path %@",path);
#endif
    
    //log 最好放在这里，只有log初始化后，才能打印。
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDFileLogger* fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [DDLog addLogger:fileLogger];
    
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:UP_COL_RGB(0x597fa6) backgroundColor:nil forFlag:LOG_FLAG_INFO];
}

/*
- (void)setIsUPPayPluginShow:(BOOL)isUPPayPluginShow {
    if (_isUPPayPluginShow != isUPPayPluginShow) {
        _isUPPayPluginShow = isUPPayPluginShow;
        
        if (!_isUPPayPluginShow && _isRecievedRemoteOrderNotification) {
            [self showRemoteNotification];
        }
    }
}


- (NSTimeInterval)backgroundInterval{
    
    NSTimeInterval interval = 0.0;
    
    if (_enterForegroundDate && _enterBackgroundDate) {
        interval = [_enterForegroundDate timeIntervalSinceDate:_enterBackgroundDate];
    }
    
    return interval;
}


#pragma mark -
#pragma mark 推送相关

-(void) dealPushNotificacton:(NSDictionary*) launchOptions {
    
    NSDictionary *remoteNotificationDic = nil;
    if (launchOptions != nil)
    {
        remoteNotificationDic = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteNotificationDic != nil)
        {
            UPDINFO(@"Launched from push notification: %@", remoteNotificationDic);
        }
    }
    
    _isUPPayPluginShow = NO;
    _isWillEnterForeground = NO;
    _isActive = NO;

    if (UP_IOS_VERSION >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }

    if (UP_IOS_VERSION < 8.0)
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert];
    }

    [self clearBadgeNumber];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // device token NSData ==> NSString
    UPDINFO(@"device token data: %@", deviceToken);
    
    NSString *token = [deviceToken description];
    token = [token stringByReplacingOccurrencesOfString: @"<" withString: @""];
    token = [token stringByReplacingOccurrencesOfString: @">" withString: @""];
    token = [token stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    UPDINFO(@"device token: %@", token);
    
    UP_SHDAT.deviceToken = token;
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:kUDKeyDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 收到推送通知后逻辑
    [self trySendUploadDeviceToken:UPDeviceTokenPrerequisiteRegisterSuccess];
    
    // 清除应用icon 数字图标
    [self clearBadgeNumber];
    
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
{
    //iOS8新增的回调, 设置badge必须获得用户许可
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:kUDKeyBadgeAllowed];
}
#endif

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    UPDINFO(@"didFailToRegisterForRemoteNotificationsWithError %@",error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *) userInfo {
    
    // 收到推送通知后逻辑
    [self sendSysClearmsg];
    
    UPDINFO(@"didReceiveRemoteNotification %@",userInfo);
    self.remoteNotificationUserInfo = userInfo;
    _isRecievedRemoteOrderNotification = YES;
    
    //如果点击收到的消息，从后台切换到前台，那么直接push不显示
    if (_isWillEnterForeground && !self.isUPPayPluginShow) {
        [self handlePushMessageInfo];
    }else if (!_isWillEnterForeground && !self.isUPPayPluginShow && _isActive) {
        // 已经在前台，且处于active状态，则显示消息，如果active处于NO，则当变回active时再显示。
        [self showRemoteNotification];
    }
    
    // 收到账单消息通知 order.list进行刷新
    NSDictionary *order = userInfo[@"order"];
    if (order) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNCRefreshOrderList object:nil userInfo:nil];
    }
}

//进入水电煤对应的缴费页面
- (void)handlePushMessageInfo
{
    UPDINFO(@"\n\n\n\nhandlePushMessageInfo: %@\n\n\n", self.remoteNotificationUserInfo[kUPXRemoteNotificationAPS][kUPXRemoteNotificationAPSInfo]);

    NSDictionary *message = self.remoteNotificationUserInfo[kUPXRemoteNotificationMessage];
    
    
    UINavigationController *navigationVC = [_rootViewController.tabBarController.viewControllers objectAtIndex:_rootViewController.tabBarController.selectedIndex];
    
    if(!navigationVC) {
        
        return;
    }
    
    //消息推送
    if(message) {
        
        UPWWebViewController* webAppVC = [[UPWWebViewController alloc] init];
        webAppVC.isLoadingView = YES;
        webAppVC.title = @"消息推送";
        webAppVC.startPage = message[kUPXRemoteNotificationMessageLink];

        UINavigationController *navigationVC = [_rootViewController.tabBarController.viewControllers objectAtIndex:_rootViewController.tabBarController.selectedIndex];
        [navigationVC pushViewController:webAppVC animated:YES];
    }

    // 标志位改为NO
    if (_isRecievedRemoteOrderNotification) {
        _isRecievedRemoteOrderNotification = NO;
    }
}

- (void)showRemoteNotification {
    
    NSString* str = self.remoteNotificationUserInfo[kUPXRemoteNotificationAPS][kUPXRemoteNotificationAPSAlert];
    if (!UP_IS_NIL(str)) {
        [UPXNotificationCenter presentNotificationWithTitle:str
                                                      image:UP_GETIMG(@"banner_ic_new_order")
                                                 tapHandler:^{
                                                     [self handlePushMessageInfo];
                                                 }];
        _isRecievedRemoteOrderNotification = NO;
    }
}

- (void)clearBadgeNumber
{
    //ios8.0以上如果没有设着badge_allowed则无法清除badge标签
    if (UP_IOS_VERSION >= 8.0) {
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyBadgeAllowed] isEqualToNumber:@YES]) {
            return;
        }
    }
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [self sendSysClearmsg];
    }
    else {
        UPDINFO(@" applicationIconBadgeNumber == 0");
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
#ifndef __IPHONE_8_0
    if (UP_IOS_VERSION < 8.0)
    {
        //iOS8上崩溃
        // If that doesn’t work, you can try setting the list of scheduled local notifications to itself; this keeps any scheduled notifications intact, but also removes old ones from Notification Center.
        UIApplication* application = [UIApplication sharedApplication];
        NSArray* scheduledNotifications = @[application.scheduledLocalNotifications];
        application.scheduledLocalNotifications = scheduledNotifications;
    }
#endif
    
}

#pragma mark -
#pragma mark 上送DeviceToken信息 
- (void)trySendUploadDeviceToken:(UPDeviceTokenPrerequisite)item
{
    _deviceTokenPrerequisite |= item;
    
    if ((_deviceTokenPrerequisite & UPDeviceTokenPrerequisiteSysInit)
        && (_deviceTokenPrerequisite & UPDeviceTokenPrerequisiteRegisterSuccess)) {
    
        _deviceTokenPrerequisite = UPDeviceTokenPrerequisiteNone;
        
        UPWMessage *message = [UPWMessage uploadDeviceToken:UP_SHDAT.deviceToken status:YES];
        
        if (message) {
            [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *response) {
           
            } fail:^(NSError *error) {
              
            }];
        }
    }
}

-(void)sendSysClearmsg {
    
    //默认device token及其nil没必要上传
    if (UP_IS_NIL(UP_SHDAT.deviceToken)) {
        return;
    }
    
    if ([UP_SHDAT.deviceToken isEqualToString:kDefaultDeviceToken]) {
        return;
    }

    UPWMessage *message = [UPWMessage clearSystemMessage:UP_SHDAT.deviceToken];
    if (message) {
        
        [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *response) {
            
        } fail:^(NSError *error) {
            
        }];
    }
}


#pragma mark - Baidu Map SDK
- (void)initBaiduMapSDK
{
    _mapManager = [[BMKMapManager alloc] init];

    NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString* mapKey = @"Gg5TaZzd0KGW00RXFdSdmqVC";
    if ([bundleId hasSuffix:@"inhouse"]) {
        mapKey = @"zR56LUaZGDP2V8zLd3TvuBYP";
    }

    BOOL ret = [_mapManager start:mapKey generalDelegate:self];
    if (!ret) {
        UPDERROR(@"BaiduMap Init Failed!!!!");
    }
}

- (void)onGetNetworkState:(int)error
{
    if (error) {
        UPDERROR(@"获取ATM网络失败: %d",error);
    }
}

- (void)onGetPermissionState:(int)error
{
    if (error) {
        UPDERROR(@"获取ATM授权失败: %d",error);
    }
}
*/
@end
