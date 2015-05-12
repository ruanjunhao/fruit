//
//  UPWBussUtil.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-30.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWBussUtil.h"
#import "UPXConstKey.h"
#import "UPWGlobalData.h"
#import "UPXConstReg.h"
#import "UPXUtils.h"
#import "UPXConstStrings.h"
#import "UPWAppInfoModel.h"
#import "UPWWebViewController.h"
#import "UPWWelcomeViewController.h"
#import "AppDelegate.h"
#import "UPWBaseNavigationController.h"
#import "UPWEnvMgr.h"
#import "UPWLocalStorage.h"
#import "NSString+IACExtensions.h"
#import "NSString+IACExtensions.h"
#import "UPWShoppingCartViewController.h"
#import "UPWShoppingCartModel.h"
#import "UPWFileUtil.h"
#import "UPWPathUtil.h"

NSString* stringWithVer(NSString* formatKey)
{
    if (UP_IS_NIL(formatKey)) {
        return @"";
    }
    const char* versionComponent = [UP_SHDAT.sysInitModel.resVersion UTF8String];
    NSString* result =  [NSString stringWithFormat:UP_STR(formatKey),versionComponent];
    return result;
}

static NSMutableArray * gBillImageShortCuts;

@implementation UPWBussUtil

+ (BOOL)isCity:(NSString*)city equalToCity:(NSString*)city2
{
    if (UP_IS_NIL(city) || UP_IS_NIL(city2)) {
        UPDERROR(@"UPWBussUtil isCity:equalToCity: param is nil");
        return NO;
    }
    if ([city hasPrefix:city2]) {
        return YES;
    }
    
    if ([city2 hasPrefix:city]) {
        return YES;
    }
    
    return NO;
}


+ (UPWAppInfoModel*)huankuanAppInfo
{
    __block UPWAppInfoModel* result = nil;
    [UP_SHDAT.allAppInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       
        UPWAppInfoModel* model = (UPWAppInfoModel*)obj;
        if ([model.dest hasPrefix:kUPAppDestPrefixHuankuan]) {
            result = model;
            *stop = YES;
        }
    }];
    return result;
}

+ (NSString*)trimBankNumber:(NSString *)bankNumber
{
    NSMutableString* trimBankNumber = [[NSMutableString alloc] initWithCapacity:0];
    for (int i = 0; i < [bankNumber length]; i++)
    {
        NSString* subString = [bankNumber substringWithRange:NSMakeRange(i, 1)];
        if ([subString isEqualToString:@" "] || [subString isEqualToString:@" "]) {
            continue;
        }
        
        [trimBankNumber appendString:subString];
    }
    
    return trimBankNumber;
}

+ (NSString*)formatCardNumber:(NSString *)cardNumber
{
    NSInteger length = [cardNumber length];
    if (length < 8) return cardNumber;
    NSRange range = NSMakeRange(0, 4);
    NSString * frontSubString = [cardNumber substringWithRange:range];
    range = NSMakeRange(length - 4, 4);
    NSString * behindSubString = [cardNumber substringWithRange:range];
    return [NSString stringWithFormat:@"%@%@%@",frontSubString, @" **** **** ", behindSubString];
}

+ (void)payWithTn:(NSString*)tn mode:(NSString*)mode viewController:(UIViewController*)viewController delegate:(id<UPPayPluginDelegate>)delegate
{
    //    UIImage *btn_up = [UIImage imageNamed:@"btn_up.png"];
    //    UIImage *btn_down = [UIImage imageNamed:@"btn_down.png"];
    ////    UIImage *sms_up = [UIImage imageNamed:@"sms_up.png"];
    ////    UIImage *sms_down = [UIImage imageNamed:@"sms_down.png"];
    //    UIImage *back_up = [UIImage imageNamed:@"back_up.png"];
    //    UIImage *back_down = [UIImage imageNamed:@"back_down.png"];
    //    UIImage *cancel_up = [UIImage imageNamed:@"cancel_up.png"];
    //    UIImage *cancel_down = [UIImage imageNamed:@"cancel_down.png"];
    //
    //    UIColor *color = [UIColor colorWithRed:((CGFloat)0x24)/0xFF green:((CGFloat)0x2C)/0xFF blue:((CGFloat)0x30)/0xFF alpha:1.0];
    //
    //    NSArray *keys = @[@"kCustomImageForActionButtonNormalState",
    //                      @"kCustomImageForActionButtonHighLightState",
    ////                      @"kCustomImageForSmsButtonNormalState",
    ////                      @"kCustomImageForSmsButtonHighLightState",
    //                      @"kCustomImageForNavigationBarBackButtonNormalState",
    //                      @"kCustomImageForNavigationBarBackButtonHighLightState",
    //                      @"kCustomImageForNavigationBarCancelButtonNormalState",
    //                      @"kCustomImageForNavigationBarCancelButtonHighLightState",
    //                      @"kCustomNavigationBarColor",
    //                      @"kApplicationIdentifier",
    //                      @"kNeedLoadViewFullScreen"];
    //    NSArray *objects = @[btn_up, btn_down, /*sms_up, sms_down, */back_up, back_down, cancel_up, cancel_down, color, appID , @"NO"];
    //    NSDictionary *d = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    
    //APP ID#VID#UID，如果没有登录就是APP ID#VID
    
    NSMutableString* appID = [kUPPayPluginAppId mutableCopy];

    [appID appendString:@"#"];
    if(!UP_IS_NIL(UP_SHDAT.virtualID)){
        [appID appendString:UP_SHDAT.virtualID];
    }
    
    //用户user id
    [appID appendString:@"#"];
    if (!UP_IS_NIL(UP_SHDAT.bigUserInfo.userInfo.userId)) {
        [appID appendString:UP_SHDAT.bigUserInfo.userInfo.userId];
    }
    
    [UPPayPluginPro startPay:tn mode:mode viewController:viewController delegate:delegate appId:appID];
    
}

+ (NSString*)daysSinceNow:(NSString*)date
{
    if(date.length > 8) {
        date = [date substringToIndex:8];
    }
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate* newDate=[dateFormatter dateFromString:date];
    
    int oneDay = 60*60*24;
    NSTimeInterval interval = [newDate timeIntervalSinceNow] + oneDay;
    int days = (int)(interval /oneDay);
    if (interval / oneDay - days > 0.00) {
        days ++;
    }
    
    if (days > 0 && days <= 7) {
        return [NSString stringWithFormat:@"%d",days];
    }
    
    return @"";
}

+ (BOOL)validPhoneNumber:(NSString*)phoneNumber
{
    BOOL ret = NO;
    //对判断手机号码进行了修改，以前不支持170手机
    //NSString *regex = @"^1[3,5,8][0-9]{9}$";
    NSString *regex = @"^1[0-9]{10}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:phoneNumber] == YES) {
        ret = YES;
    }
    return ret;
}

+ (BOOL)validUserPwd:(NSString*)userPwd
{
    NSString*regex = @"^[a-zA-Z]{6,16}$";
    NSPredicate*predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if([predicate evaluateWithObject:userPwd]) {
        return NO;
    }
    
    regex = @"^[0-9]{6,16}$";
    predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if([predicate evaluateWithObject:userPwd]) {
        return NO;
    }
    
    regex = @"^[^a-zA-Z0-9]{6,16}$";
    predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if([predicate evaluateWithObject:userPwd]) {
        return NO;
    }
    
    if (userPwd.length < 6 || userPwd.length > 16) {
        return NO;
    }
    
    return YES;
}

+ (NSString *)trimDate:(NSString *)date
{
    if (date.length < 10) {
        return @"";
    }
    
    NSRange range = {5,2};
    NSString *year = [date substringToIndex:4];
    NSString *month = [date substringWithRange:range];
    range.location = 8;
    NSString *day = [date substringWithRange:range];
    NSString* formatDate = [[NSMutableString alloc] initWithFormat:@"%@%@%@",year,month,day];
    return formatDate;
}




#pragma mark - 应用跳转

+ (UIViewController*)viewControllerWithAppInfo:(UPWAppInfoModel*)appInfo
{
    
    UIViewController* result = nil;
    NSString* type = appInfo.type;
    NSString* name = appInfo.name;
    NSString* dest = [UPXUtils getAppDestWithAppId:appInfo.appId];
    if (UP_IS_NIL(dest)) {
        dest = appInfo.dest;
    }
    
    if (UP_IS_NIL(dest)) { // 如果dest还是nil，则填进去空字符串
        dest = @"";
    }
    

    // 创建一个中间值
    NSMutableDictionary *tempDic = [[appInfo toDictionary] mutableCopy];
    [tempDic setObject:dest forKey:kKeyCatalogDest];
    
    NSString* destParams = appInfo.destParams;
    NSDictionary* destMap = nil;
    if (!UP_IS_NIL(destParams)) {
        NSError *error = nil;
        destMap = [NSJSONSerialization JSONObjectWithData:[destParams dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if(error) UPDERROR(@"Dest Param JSON Parsing Error: %@", error);
    }
    
    if ([type isEqualToString:kUPAppTypeHtml])
    {
        // 商户提供的Web应用，如导购平台
        UPWWebViewController* webAppVC = [[UPWWebViewController alloc] init];
        webAppVC.isLoadingView = YES;
        
        if([destMap[@"hidetoolbar"] isEqualToString:@"1"])
        {
            webAppVC.hasToolbar = NO;
        }
        else{
            webAppVC.hasToolbar = YES;
        }
        webAppVC.webAppHolder = nil;
        webAppVC.title = name;
        UPDINFO(@"web start page %@",dest);
        webAppVC.startPage = dest;
        NSString* configStr = appInfo.config;
        NSArray* config = [configStr componentsSeparatedByString:@","];
        webAppVC.authPlugins = config;
        webAppVC.appInfo = appInfo;
        result = webAppVC;
    }
    else if([type isEqualToString:kUPAppTypeNative])
    {
        if([dest hasPrefix:kUPAppDestPrefixHuodong])
        {
            //活动, 进秒杀页面
    
//            UPSeckillViewController *seckillVC = [[UPSeckillViewController alloc] init];
//            seckillVC.featureDict = destMap;
//            seckillVC.navTitle = name;
//            result = seckillVC;
        }
        else if([dest hasPrefix:kUPAppDestPrefixTrans])
        {
            // 重用我的花销页面
//            result = [[UPWMyHuaXiaoViewController alloc] initWithEPageType:EDFPageByCostRecords];
        }
        else if([dest hasPrefix:kUPAppDestPrefixJiaofei]||[dest hasPrefix:kUPAppDestPrefixChongzhi]||[dest hasPrefix:kUPAppDestPrefixHuankuan]||[dest hasPrefix:kUPAppDestPrefixFakuan])
        {
            
//            UPXModelAppBill *historyBill = [[UPXModelAppBill alloc] initWithAppID:appInfo.appId];
            
            
            //判断对应的缴费是否包含历史纪录 是否登录过
            //只有没有登录而且本地没有历史纪录才会跳过历史纪录页面
//            if(historyBill.app_bills.count > 0 || UP_SHDAT.hasLogin)
//            {
////                UPXPublicPayHistoryViewController *vc = [[UPXPublicPayHistoryViewController alloc] initWithNibName:nil bundle:nil];
////                vc.appInfo = appInfo;
////                
////                vc.dest = [[NSMutableString alloc] initWithString:dest];
////                result = vc;
//            }
//            else
//            {
//                result = [self directToBill:appInfo];
//            }
            
        }
        else {
            
            
            result = nil;
            
   
        }
    }
    return result;
}


+ (UIViewController*)directToBill:(UPWAppInfoModel *)appInfoModel
{
    UIViewController* result = nil;
    if([appInfoModel.dest hasPrefix:kUPAppDestPrefixFakuan] ) {
//        UPXTrafficFineViewController* trafficPayVC = [[UPXTrafficFineViewController alloc] initWithNibName:nil bundle:nil];
//        trafficPayVC.appInfo = appInfoModel;
//        result = trafficPayVC;
    }
    else if([appInfoModel.dest hasPrefix:kUPAppDestPrefixJiaofei]) {
        
//        UPXPublicPayViewController* publicPayVC = [[UPXPublicPayViewController alloc] initWithNibName:nil bundle:nil];
//        publicPayVC.appInfo = appInfoModel;
//        result = publicPayVC;
        
    }
    else if([appInfoModel.dest hasPrefix:kUPAppDestPrefixHuankuan]){
//        UPXCreditRepaymentsViewController* creditVC = [[UPXCreditRepaymentsViewController alloc] init];
//        creditVC.appInfo = appInfoModel;
//        creditVC.cardCode = kCreditCardCode;
//        result = creditVC;
    }
    else if([appInfoModel.dest hasPrefix:kUPAppDestPrefixChongzhi]) {
        //直接进入新手机页面
//        UPWChongZhiViewController * vc = [[UPWChongZhiViewController alloc] initWithAppInfo:appInfoModel mobileNum:nil];
//        result =  vc;
    }
    
    return result;
}




#pragma mark - 手势密码随机字符串相关

+ (NSString *)getRandomOriginString
{
    int NUMBER_OF_CHARS = 10;
    char data[NUMBER_OF_CHARS];
    for (int x=0;x<NUMBER_OF_CHARS;x++)
    {
        data[x] = (char)('A' + (arc4random_uniform(26)));
        for (int y =0;y <x;y++)
        {
            if (data[y] == data[x])//避免生成的随机数重复
            {
                x--;
                break;
            }
        }
    }
    //for (int x=0;x<NUMBER_OF_CHARS; data[x++] = (char)('A' + (arc4random_uniform(26))));
    NSString *result = [[NSString alloc] initWithBytes:data length:NUMBER_OF_CHARS encoding:NSUTF8StringEncoding];
    return result;
}

+ (NSString *)randomPatternString:(NSString *)patternNumStr randomOriginString:(NSString *)randomString
{
    NSInteger patternNum = [patternNumStr integerValue];
    if (UP_IS_NIL(randomString))
    {
        return nil;
    }
    const char *randomChar = [randomString UTF8String];
    int NUMBER_OF_CHARS = (int)[patternNumStr length];
    char data[NUMBER_OF_CHARS];
    for (int x=0;x<NUMBER_OF_CHARS; x++)
    {
        int index = patternNum/pow(10, NUMBER_OF_CHARS-1-x);
        data[x] = (char)(randomChar[index]);
        patternNum = patternNum - index*pow(10, NUMBER_OF_CHARS-1-x);
    }
    NSString *result = [[NSString alloc] initWithBytes:data length:NUMBER_OF_CHARS encoding:NSUTF8StringEncoding];
    
    return result;
    
}

+ (NSString *)originPatternString:(NSString *)randomStr randomOriginString:(NSString *)randomOriginStr{
    
    if ([randomStr length]<4) {
        //暂不设置
        return randomStr;
    }else{
        int NUMBER_OF_CHARS = (int)[randomStr length];
        NSInteger resultInteger = 0;
        
        for (int x=0;x<NUMBER_OF_CHARS; x++){
            NSString *subStr = [randomStr substringWithRange:NSMakeRange(x, 1)];
            resultInteger = resultInteger * 10 + [randomOriginStr rangeOfString:subStr].location;
        }
        
        return [NSString stringWithFormat:@"%ld",(long)resultInteger];
    }
    
}

// 分享类容制作，包括更多和缴费模块
+ (UPShareContent *)shareContentForType:(UPShareType)shareType withJiaoFeiDest:(NSString *)destStr isForApp:(BOOL)isForApp
{
    UPShareContent * content = [[UPShareContent alloc] init];
    
    switch (shareType) {
        case UPWeiXin:
        case UPWeiXinGroup: {
            
            content.title = UP_STR(@"String_WechatTitleWallet");
            content.body = UP_STR(@"String_WechatDescriptionWallet");
            content.image = UP_GETIMG(@"WeChatIconWallet");
            
            content.webUrl = [UP_SHDAT.sysInitModel.baseUrl  stringByAppendingSubUrl:stringWithVer(@"String_URL_WXShare1_Format")];
        }
            break;
            
        case UPSinaWeiBo:{
            
            content.body = [NSString stringWithFormat:UP_STR(kSNSStrKey1), kAppName, UP_STR(@"String_SinaWeiboRefererWallet")];
            content.image = UP_GETIMG(@"weibo_share");
        }
            break;
        
        case UPSMS: {
            
            content.body = [NSString stringWithFormat:UP_STR(kSNSStrKey1), kAppName, UP_STR(@"String_URL_SMSShareWallet")];
        }
            break;
            
        default:
            break;
    }
    
    return content;
}

+ (BOOL)isPhoneNumberFilledAsCompleted:(NSString *)phoneNumText
{
    // 手机号 分割 3，4，4
    NSString * normal = [UPXUtils getNormalString:phoneNumText];
    return UP_REGEXP(normal, kRegisterPhoneNumberPredicate);
}

// 获取票券图标，券，票，秒杀？
+ (UIImage *)shortcutImageForBillWithType:(NSString *)billType isSecKill:(BOOL)isSecKill
{
    if(!gBillImageShortCuts) {
        gBillImageShortCuts = [[NSMutableArray alloc] init];
        for (int i = 0; i < 8; ++i) {
            [gBillImageShortCuts addObject:[UIImage imageNamed:[NSString stringWithFormat:@"cata_%d",i]]];
        }
    }
    
    NSInteger cataIndex = 0;
    
    switch ([billType integerValue]) {
        case 1:
        case 2:
        case 3: {
            // 优惠券
            if(isSecKill) {
                cataIndex = 4;
            }
            else {
                cataIndex = 1;
            }
        }
            break;
        case 4:
            // 电子票
            if(isSecKill) {
                cataIndex = 5;
            }
            else {
                cataIndex = 2;
            }
            break;
        case 6:
            // 返利券
            if(isSecKill) {
                cataIndex = 6;
            }
            else {
                cataIndex = 3;
            }
            break;
        default:
            break;
    }
    
    NSAssert(cataIndex < gBillImageShortCuts.count, @"");
    
    return gBillImageShortCuts[cataIndex];
}

//弹出消息框来显示消息
void showMessage(NSString * message)
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
    [alertView show];
}


+ (UPWLoginViewController *)showLoginWithSuccessBlock:(completionBlock)successBlock cancelBlock:(completionBlock)cancelBlock completion:(completionBlock)completionBlock
{
    UPWWelcomeViewController* welcome = ((AppDelegate*)([UIApplication sharedApplication].delegate)).rootViewController;
    UPWLoginViewController* loginVC = [[UPWLoginViewController alloc] init];
    loginVC.successBlock = successBlock;
    loginVC.cancelBlock = cancelBlock;
    UPWBaseNavigationController* navi = [[UPWBaseNavigationController alloc] initWithRootViewController:loginVC];
    
    UPWBaseNavigationController *currentNavi=[welcome.tabBarController.viewControllers objectAtIndex:welcome.tabBarController.selectedIndex];
    
    UIViewController *topController = [currentNavi topViewController];


    //当前如果已经有一个presentedView就必须取消掉不然就会出现再present,logionInViewController无法显示的问题
    if(topController.presentedViewController){
        [topController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        [welcome.tabBarController presentViewController:navi animated:YES completion:completionBlock];
    }
    else {
        
        [welcome.tabBarController presentViewController:navi animated:YES completion:completionBlock];
        
    }
    
    return loginVC;
}

#pragma mark -- 获取交易类型列表
+ (void)fetchTradeTypesWithCompetionBlock:(trade_types_block_t)competionBlock
{
    NSString* url = [UP_SHDAT.sysInitModel.baseUrl stringByAppendingSubUrl:UP_STR(@"String_URL_TradeTypes")];
    
    [[UPWHttpMgr instance] downloadWithURL:url success:^(NSData *data) {
        
        id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];;
        
        NSArray * tradeTypes;
        if([obj isKindOfClass:[NSArray class]]) {
            tradeTypes = (NSArray *)obj;
        }
        
        if(tradeTypes.count == 0) {
            tradeTypes = @[]; // 空数组
        }
        
        if(competionBlock) {
            competionBlock(tradeTypes);
        }
        
        // 更新本地文件
        [UPWLocalStorage setTradeTypes:tradeTypes];
        
    } fail:^(NSError *error) {
        
        // 网络获取失败，从文件中读取。
        NSArray * tradeTypes = [UPWLocalStorage tradeTypes];
        if(tradeTypes.count == 0) {
            tradeTypes = @[]; // 空数组
        }
        
        if(competionBlock) {
            competionBlock(tradeTypes);
        }
    }];
}

+ (BOOL)isWebFullUrl:(NSString *)url
{
    return ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]);
}

#pragma mark -
#pragma mark - 刷新购物车角标数量
+ (void)refreshCartDot
{
    UPWWelcomeViewController* welcome = ((AppDelegate*)([UIApplication sharedApplication].delegate)).rootViewController;
    UPWBaseNavigationController *cartNaviVC = welcome.tabBarController.viewControllers[2];
//    UPWShoppingCartViewController *shoppingCartVC = (UPWShoppingCartViewController *)cartNaviVC.viewControllers[0];
    UPWShoppingCartModel *cartModel = [[UPWShoppingCartModel alloc] initWithDictionary:[UPWFileUtil readContent:[UPWPathUtil shoppingCartPlistPath]] error:nil];
    NSInteger badgeValue= 0;
    for (UPWShoppingCartCellModel *cellModel in cartModel.data) {
        badgeValue += cellModel.fruitNum.integerValue;
    }
    cartNaviVC.tabBarItem.badgeValue = [NSNumber numberWithInteger:badgeValue].stringValue;//shoppingCartVC.fruitNum?shoppingCartVC.fruitNum:
}

@end
