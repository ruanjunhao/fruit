//
//  UPWWalletPlugin.m
//  CHSP
//
//  Created by jhyu on 13-11-7.
//
//

#import "UPWWalletPlugin.h"
#import "UPWHttpMgr.h"
#import "UPWMessage.h"
#import "UPWWebData.h"
#import "UPWGlobalData.h"
#import "UPWLocationService.h"
#import "UPWBaseNavigationController.h"
#import "UPWWebViewController.h"
#import "UPWLoginViewController.h"
#import "UPWHttpMgr.h"
#import "UPWCryptUtil.h"
#import "UPWSharePanel.h"
#import "UPWNotificationName.h"
#import "UPWUiUtil.h"
#import "UPWBussUtil.h"



@interface UPWWalletPlugin (){
    NSString *_callbackIdForSeckill; // 秒杀
}
@property (nonatomic, readonly) UPWWebViewController * viewController;
@end

@implementation UPWWalletPlugin

#pragma mark -
#pragma mark - Common methods

- (UPWWebViewController *)viewController
{
    // Plugin的载体就是UPWWebViewController
    if([super.viewController isKindOfClass:[UPWWebViewController class]]) {
        return (UPWWebViewController *)super.viewController;
    }
    
    return nil;
}

#pragma mark -
#pragma mark - sendMessage

/*
 javascript调用native的格式为： upopenlink://base64code
 其中base64code格式为：
 {
 uri: 服务器地址,etc: ‘/activity/activityList’,
 encrypt: 是否加密,
 encryptFields: [], //部分加密字段，如果数组为空全部加密
 params: json格式参数
 }
 */

- (void)sendMessage:(CDVInvokedUrlCommand *)command
{
    id args = [command argumentAtIndex:0];
    if(![args isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    UPWMessage * message = [UPWMessage messageWithUrl:args[@"uri"] params:args[@"params"] encrypt:[args[@"encrypt"] boolValue] isPost:[[args[@"method"] uppercaseString] isEqualToString:@"POST"] hostType:args[@"hostType"]];
    message.isFromWeb = YES;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        NSString* resp = responseJSON[@"resp"];
        NSString* msg = responseJSON[@"msg"];
        
        if (NSOrderedSame == [resp compare:@"00" options:NSCaseInsensitiveSearch]) {
            // 成功回调
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:responseJSON];
            [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
        else {
            // 失败回调
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            if (!UP_IS_NIL(resp)) {
                dict[@"resp"] = resp;
            }
            
            if (!UP_IS_NIL(msg)) {
                dict[@"msg"] = msg;
            }
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
            [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
        
    } fail:^(NSError *error) {
        
        // 失败回调
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        NSString* resp = [error userInfo][NSLocalizedFailureReasonErrorKey];
        NSString* msg = [error userInfo][NSLocalizedDescriptionKey];
        if (!UP_IS_NIL(resp)) {
            dict[@"resp"] = resp;
        }
        
        if (!UP_IS_NIL(msg)) {
            dict[@"msg"] = msg;
        }
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
        [weakSelf.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

#pragma mark -
#pragma mark - Open/dismiss loading view

/**
 * JS请求打开/关闭遮罩
 */
- (void)showLoading:(CDVInvokedUrlCommand *)commands
{
    BOOL willShow = [[commands argumentAtIndex:0] boolValue];
    if(willShow) {
        [self.viewController showLoadingWithMessage:@""];
    }
    else {
        [self.viewController dismissLoading];
    }
}

#pragma mark -
#pragma mark - 显示toast文言

/**
 * JS显示文言
 */

- (void)showToast:(CDVInvokedUrlCommand *)commands
{
    [self.viewController showFlashInfo:[commands argumentAtIndex:0][@"msg"]];
}

#pragma mark -
#pragma mark - 拨打电话

/**
 * JS请求拨打电话
 */

- (void)callPhone:(CDVInvokedUrlCommand *)commands
{
    NSString * phoneNum = [commands argumentAtIndex:0];
    [UPWUiUtil showPhoneCallingInHostView:self.viewController.view withPhoneNumber:phoneNum];
}

#pragma mark -
#pragma mark - 获取Native数据

/**
 * JS请求本地数据 (json中的TYPE)
 *
 */
- (void)fetchNativeData:(CDVInvokedUrlCommand *)commands
{
    id args = [commands argumentAtIndex:0];
    if(![args isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSInteger type = [args[@"type"] integerValue];
    
    UPDINFO(@"...retrieveNativeData type = %@", [@(type) stringValue]);
    
    switch (type) {
        case 0:
        {
            // 0-系统参数
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"version":[[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"]}];
            [self.commandDelegate sendPluginResult:result callbackId:commands.callbackId];
        }
            break;
            
        case 1:
        {
            // 1-经纬度
            __weak typeof(self) weakSelf = self;
            if([UPWLocationService isLocationServiceEnable]) {
                
                if (!self.viewController.locationService) {
                    self.viewController.locationService = [[UPWLocationService alloc] init];
                }
                
                [self.viewController.locationService updatingLocationWithSuccess:^(NSString *longitude, NSString *latitude, NSDictionary * city) {
                    
                    CDVPluginResult* result = [weakSelf pluginResultWithLat:latitude lon:longitude];
                    [weakSelf.commandDelegate sendPluginResult:result callbackId:commands.callbackId];
                } fail:^(NSError* err) {
                
                    [weakSelf.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:commands.callbackId];
                }];
                
                self.viewController.locationService.retCityNm = NO; // 这儿不需要城市名
            }
            else {
                [weakSelf.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR] callbackId:commands.callbackId];
            }
        }
            break;
            
        case 5:
        {
            // 5-UserId
            
            CDVPluginResult* result;
            
            if(UP_SHDAT.hasLogin && !UP_IS_NIL(UP_SHDAT.bigUserInfo.userInfo.userIdC)) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK  messageAsDictionary:@{@"userId":UP_SHDAT.bigUserInfo.userInfo.userIdC}];
            }
            else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            
            [self.commandDelegate sendPluginResult:result callbackId:commands.callbackId];
        }
            break;
            
        default:
        {
            // 其他的，JS后续版本添加的，当前版本不支持返回Error.
            UPDWARNING(@"!!! Uncatch command type %@", [@(type) stringValue]);
            
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:result callbackId:commands.callbackId];
        }
            break;
    }
}

- (CDVPluginResult *)pluginResultWithLat:(NSString *)lat lon:(NSString *)lon
{
    return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"latitude":lat, @"longitude":lon}];
}

#pragma mark -
#pragma mark - Plugin开新页面

/*
 {"pageUrl":{"uri":@"hybrid_v3/html/data/myexpense.html", "params":{}},
 "navBar":@{@"title":"我的花销分析", @"showShare":true}}
 
 
 */

- (void)openNewPage:(CDVInvokedUrlCommand *)command
{
    id args = [command argumentAtIndex:0];
    if(![args isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    ELaunchType eType = ELaunchTypePluginNewPageOpen;
    if(args[@"pageUrl"]) {
        // openNewPage 新版本，WEB端完全控制，账单项目已经采用这一模式。
        eType = ELaunchTypeUniversalWebDriven;
    }
    
    UPWWebData * webData = [[UPWWebData alloc] initWithLaunchType:eType poiData:args];
    [self.viewController.navigationController pushViewController:[[UPWWebViewController alloc] initWithWebData:webData] animated:YES];
}

#pragma mark -
#pragma mark - 打开登录页面

// 打开登录页面，秒杀页面会调用。
- (void)openLoginPage:(CDVInvokedUrlCommand *)command
{
    // 登录成功以后是否需要刷新WEB页面。
    __weak typeof(self) wself = self;
    [UPWBussUtil showLoginWithSuccessBlock:^() {
        [wself loginSuccessHandlerWithParams:[command argumentAtIndex:0]];
    } cancelBlock:nil completion:nil];
}

- (void)loginSuccessHandlerWithParams:(id)args
{
    if([args[@"refreshPage"] boolValue]) {
        // 登陆成功以后可能需要刷新页面
        [self.webView reload];
        [self.viewController.contentView bringSubviewToFront:self.webView];
    }
}

#pragma mark - UPWDownloadMgrDelegate

- (void)didDownloadSuccessWithBillId:(NSString *)billId
{
    if(UP_IS_NIL(billId)) {
        return;
    }
    
    // WEB页面端更新, 更新详情页面。
    [self.webView stringByEvaluatingJavaScriptFromString:@"UP.M.NAPI.nativeCall('updateDownloadNum')"];

    // 通知票券列表页面。
    [UP_NC postNotificationName:kNotificationDownloadCouponSucceed object:nil userInfo:@{@"billId":billId}];
}

- (void)didDownloadSeckillSuccessWithParams:(NSDictionary *)params
{
    // 回调通知，请求结果存放在params中。
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:params];
    [self.commandDelegate sendPluginResult:result callbackId:_callbackIdForSeckill];
}

#pragma mark - setNavBar

- (void)setNavBar:(CDVInvokedUrlCommand *)commands
{
    [self.viewController performSelector:@selector(setNavBarWithArgs:) withObject:[commands argumentAtIndex:0]];
}

- (void)openRegisterPage:(CDVInvokedUrlCommand *)command
{
    __block UPWLoginViewController * loginVC = [UPWBussUtil showLoginWithSuccessBlock:nil cancelBlock:nil completion:^() {
        
        //[loginVC performSelector:@selector(openRegisterPage) withObject:nil afterDelay:0.7f];
        
        __weak UPWLoginViewController * wLoginVC = loginVC;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wLoginVC openRegisterPage];
        });
    }];
    
}

@end
