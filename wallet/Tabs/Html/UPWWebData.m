//
//  UPWebBridge.m
//  UPWallet
//
//  Created by jhyu on 14-7-17.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWWebData.h"
#import "UPWEnvMgr.h"
#import "NSString+IACExtensions.h"
#import "UPWLocalStorage.h"
#import "UPWGlobalData.h"
#import "JSONModel.h"
#import "UPWNotificationName.h"
#import "UPWBussUtil.h"

@interface UPWWebData () {
    
    NSString* _startPage;
    NSString* _navigationBarTitle;
    ERightBtn _eRightBtn;
    EShareType _eShareType;
    
    NSDictionary* _poiData;
    ELaunchType _eLaunchType;
}

@end

@implementation UPWWebData

@synthesize startPage = _startPage;
@synthesize navigationBarTitle = _navigationBarTitle;
@synthesize eRightBtn = _eRightBtn;
@synthesize eShareType = _eShareType;

@synthesize eLaunchType = _eLaunchType;

- (id)initWithLaunchType:(ELaunchType)eLaunchType poiData:(id)poiData
{
    self = [super init];
    if (self) {
        _eLaunchType = eLaunchType;
        if([poiData isKindOfClass:[NSDictionary class]]) {
            _poiData = poiData;
        }
        else if([poiData isKindOfClass:[JSONModel class]]) {
            _poiData = [poiData toDictionary];
        }
        else {
            NSAssert(NO, @"Not support param type yet !!!");
        }
        
        [self configParams];
    }
    
    return self;
}

- (id)initWithBrandId:(NSString *)brandId billId:(NSString *)billId billType:(NSString *)billType updTime:(NSString *)updTime
{
    if(UP_IS_NIL(brandId) || UP_IS_NIL(billId) || UP_IS_NIL(billType)) {
        return nil;
    }
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:@{@"brandId":brandId, @"billId":billId, @"billType":billType}];
    
    if(!UP_IS_NIL(updTime)) {
        params[@"updTime"] = updTime;
    }
    
    return [[UPWWebData alloc] initWithLaunchType:ELaunchTypeLocalCoupon poiData:params];
}

- (id)initWith3rdPatyAppLunchUrl:(NSURL *)url
{
    /*
     * eg: 从微信点击票券启动钱包 Url request from com.apple.mobilesafari, chsp:///hybrid_v3/html/bill/detail.html?urlType=1&recmdUsrId=EBBDADDDDADER&cityCd=310000&brandId=61700&billId=Z00000000004114
     *
     */
    
    NSArray * components = [url.absoluteString componentsSeparatedByString:@"?"];
    NSDictionary * queries = [components.lastObject parseURLParams];
    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:@{@"params" : queries}];
    
    NSString * relativePath = url.relativePath;
    if(relativePath.length == 0) {
        // 没有URI, 不用打开任何页面。
        return nil;
    }
    else {
        [params setObject:relativePath forKey:@"uri"];
        
        if(queries[@"urlType"]) {
            // 常规票券
            [params setObject:queries[@"urlType"] forKey:@"type"];
            return [self initWithLaunchType:ELaunchTypePluginNewPageOpen poiData:params];
        }
        else {
            // 我的账单里面，数据项目整合。
            NSString * pageTitle = nil;
            
            if([relativePath hasSuffix:@"myexpense.html"]) {
                // 我的花销
                pageTitle = UP_STR(@"String_HuaXiao_Analysis");
            }
            else if([relativePath hasSuffix:@"dareintro.html"]) {
                // 敢不敢玩
                pageTitle = UP_STR(@"kStrMyGame");
            }
            
            if(!UP_IS_NIL(pageTitle)) {
                NSDictionary * params = @{@"pageUrl":@{@"uri":relativePath, @"params":@{}}, @"navBar":@{@"title":pageTitle, @"showBill":@YES}};
                UPWWebData * webData = [[UPWWebData alloc] initWithLaunchType:ELaunchTypeUniversalWebDriven poiData:params];
                
                if(webData) {
                    // 先打开"我的"Tab。
                    [UP_NC postNotificationName:kNotificationOpenMineTab object:nil];
                    
                    // 打开"我的"Tab需要时间（等待），然后打开相应页面。
                    [self performSelector:@selector(openMyBillsPageWithWebData:) withObject:webData afterDelay:0.3f];
                }
            }
            
            // 这儿返回nil 因为真正的打开操作我们通过上面的方法openMyBillsPageWithWebData:来实现了。
            return nil;
        }
    }
}

- (void)openMyBillsPageWithWebData:(UPWWebData *)webData
{
    [UP_NC postNotificationName:kNotificationOpenMyBillsPage object:nil userInfo:@{kUPWWebData:webData}];
}

- (id)initWithStartPage:(NSString *)startPage title:(NSString *)title rightBtn:(ERightBtn)eRightBtn shareType:(EShareType)eShareType
{
    self = [super init];
    if (self) {
        _startPage = [startPage copy];
        _navigationBarTitle = [title copy];
        _eRightBtn = eRightBtn;
        _eShareType = eShareType;
        _eLaunchType = ELaunchTypeNone;
    }
    
    return self;
}

- (void)configParams
{
    NSString * url = [self requestUrl];
    // 优惠开发连江俊的服务器
    if(![UPWBussUtil isWebFullUrl:url]) {
        NSString * baseUrl = [UPWEnvMgr chspImgServerUrl];
        url = [baseUrl stringByAppendingSubUrl:url];
    }
    
    _startPage = [self startPageByUrl:url];
    _navigationBarTitle = [self navBarTitle];
    _eShareType = [self sharePageType];
    _eRightBtn = [self rightBtnType];
}

- (NSString *)requestUrl
{
    NSString * url;
    
    switch (_eLaunchType) {
        case ELaunchTypeLocalCoupon:
        case ELaunchTypeLocalSecKill: {
            // 优惠券（电子票...）页面静态化。
            NSString* brandId = _poiData[@"brandId"];
            
            NSString* billId = _poiData[@"billId"];
            if(UP_IS_NIL(billId)) {
                billId = _poiData[@"couponId"];
            }
            
            //NSAssert(!UP_IS_NIL(brandId) && !UP_IS_NIL(billId), @"服务器传值缺失");
            
            url = [NSString stringWithFormat:@"/hybrid_v3/detail/appDetail_%@_%@_%@.html", brandId, billId, [self clientCityCode]];
        }
            break;
        case ELaunchTypeLocalMerchant:
            url = kMchntDetailUrl;
            break;
        case ELaunchTypeLocalActivityList:
            url = @"hybrid_v3/html/activity/activitylist.html";
            break;
        case ELaunchTypePluginNewPageOpen:
            url = _poiData[@"uri"];
            break;
        case ELaunchTypeUniversalWebDriven:
            url = _poiData[@"pageUrl"][@"uri"];
            break;
        default:
            break;
    }
    
    NSAssert(url.length > 0, @"");
    
    return url;
}

- (NSString *)navBarTitle
{
    NSString * title = UP_STR(@"kStrGeneralDetail");
    switch (_eLaunchType) {
        case ELaunchTypeLocalCoupon:
            title = [self couponPageTitle];
            break;
        case ELaunchTypeLocalMerchant:
            title = UP_STR(@"kStrMerchantDetail");
            break;
        case ELaunchTypeLocalActivityList:
            title = UP_STR(@"kStrActivityList");
            break;
        case ELaunchTypeLocalSecKill:
            title = UP_STR(@"kStrSecKillDetail");
            break;
        case ELaunchTypePluginNewPageOpen:
            title = [self naviTitleForPlugin];
            break;
        case ELaunchTypeUniversalWebDriven:
            title = _poiData[@"navBar"][@"title"];
            break;
        default:
            break;
    }
    
    return title;
}

- (NSString *)couponPageTitle
{
    NSString * title;
    switch ([[self billTypeCode] integerValue]) {
        case 1:
        case 2:
        case 3:
            title = UP_STR(@"kStrCouponDetail");
            break;
        case 4:
            title = UP_STR(@"kStrETicketDetail");
            break;
        case 6:
            title = UP_STR(@"kStrRebateDetail");
            break;
        default:
            break;
    }
    
    return title;
}

- (NSString *)billTypeCode
{
    NSString * billType;
    if([_poiData[@"billTp"] length] > 0) {
        billType = _poiData[@"billTp"];
    }
    else if([_poiData[@"billType"] length] > 0) {
        billType = _poiData[@"billType"];
    }
    else if([_poiData[@"urlType"] length] > 0) {
        billType = _poiData[@"urlType"];
    }
    
    return billType;
}

- (NSString *)startPageByUrl:(NSString *)url
{
    NSMutableDictionary * allParams = [NSMutableDictionary dictionaryWithDictionary:@{@"source":@"2"}];
    
    if(_eLaunchType == ELaunchTypePluginNewPageOpen) {
        // WEB端新起页面，参数全复制
        [allParams addEntriesFromDictionary:_poiData[@"params"]];
    }
    else if(_eLaunchType == ELaunchTypeUniversalWebDriven) {
        // WEB端新起页面，参数全复制
        [allParams addEntriesFromDictionary:_poiData[@"pageUrl"][@"params"]];
    }
    
    if([self isCouponDetailStaticWebPage]) {
        // 现阶段票券详情页面已经静态化。
        
        // 支持格瓦拉电子票
        if(_poiData[@"sceneId"]) {
            [allParams setObject:_poiData[@"sceneId"] forKey:@"sceneId"];
        }
        
        if(_poiData[@"seqId"]) {
            [allParams setObject:_poiData[@"seqId"] forKey:@"seqId"];
        }
    }
    else {
        allParams[@"cityCd"] = [self clientCityCode];
        
        // URL参数添加如下信息，比如我的收藏里面的商户详情。
        if(_poiData[@"billId"]) {
            allParams[@"billId"] = _poiData[@"billId"];
        }
        
        if(_poiData[@"brandId"]) {
            allParams[@"brandId"] = _poiData[@"brandId"];
        }
    }
    
    NSString * updTime = _poiData[@"updTime"];
    if(!UP_IS_NIL(updTime)) {
        allParams[@"updTime"] = updTime;
    }
    
    NSString * fullUrl = [url stringByAppendingURLParams:allParams];
    UPDINFO(@">> fullUrl = %@", fullUrl);
    return fullUrl;
}

// 为了加快访问速度，WEB端将一些频繁访问的页面静态化了。
- (BOOL)isCouponDetailStaticWebPage
{
    // 现阶段优惠券是静态化页面。
    if(_eLaunchType == ELaunchTypeLocalCoupon || _eLaunchType == ELaunchTypeLocalSecKill) {
        return YES;
    }
    
    if(_eLaunchType == ELaunchTypePluginNewPageOpen) {
        switch ([_poiData[@"type"] integerValue]) {
                // 1-优惠券详情  | 2-电子票详情  | 3-积分券详情
            case 1:
            case 2:
            case 3:
                return YES;
            default:
                break;
        }
    }
    
    return NO;
}

- (NSString *)clientCityCode
{
    // 如果后台数据包括"cityCd", 使用后台数据的。
    
    NSString* cityCd = _poiData[@"cityCd"];
    if(cityCd.length > 0) {
        return cityCd;
    }
    
    // 没有@"cityCd"字段，客户端来添加。
    if([UPWLocalStorage latestCity].cityCd) {
        cityCd = [UPWLocalStorage latestCity].cityCd;
    }
    
    if(cityCd.length == 0) {
        // still nil.
        cityCd = @"310000"; // 默认选上海;
    }
    
    return cityCd;
}

- (EShareType)sharePageType
{
    EShareType eType = EShareTypeNone;
    
    switch (_eLaunchType) {
        case ELaunchTypeLocalCoupon:
            eType = [self localSharePageType];
            break;
        case ELaunchTypeLocalMerchant:
            eType = EShareTypeMerchant;
            break;
        case ELaunchTypeLocalActivityList:
            // No share btn.
            break;
        case ELaunchTypeLocalSecKill:
            eType = EShareTypeCoupon;
            break;
        case ELaunchTypePluginNewPageOpen:
            eType = [self sharePageTypeForPlugin];
            break;
        case ELaunchTypeUniversalWebDriven:
            if([_poiData[@"navBar"][@"showShare"] boolValue]) {
                eType = EShareTypeUniversalWebDriven;
            }
            break;
        default:
            break;
    }
    
    return eType;
}

- (EShareType)sharePageTypeForPlugin
{
    EShareType eType = EShareTypeNone;
    
    /*
     *type: '0-不加 | 1-优惠券详情  | 2-电子票详情  | 3-积分券详情 | 4-活动详情 | 5-门店列表 | 6-银联钱包电子票使用介绍 | 7-银联钱包优惠券使用介绍 | 8-银联钱包积分券使用介绍 | 9-用户评论列表 | 10-商户详情
     **/
    NSInteger pageType = [_poiData[@"type"] integerValue];
    if(pageType == 1) {
        eType = EShareTypeCoupon;
    }
    else if(pageType == 2) {
        eType = EShareTypeETicket;
    }
    else if(pageType == 3) {
        eType = EShareTypeRebate;
    }
    else if(pageType == 4) {
        eType = EShareTypeActivity;
    }
    else if(pageType == 10) {
        eType = EShareTypeMerchant;
    }
    
    return eType;
}

- (ERightBtn)rightBtnType
{
    ERightBtn eRightBtn = ERightBtnNone;
    
    if(_eShareType != EShareTypeNone) {
        eRightBtn = ERightBtnShare;
    }
    
    if(_eLaunchType == ELaunchTypePluginNewPageOpen) {
        NSInteger pageType = [_poiData[@"type"] integerValue];
        if(pageType == 5) {
            // 5-门店列表
            eRightBtn |= ERightBtnMap;
        }
        else if(pageType == 9) {
            // 9-用户评论列表
            eRightBtn |= ERightBtnRating;
        }
        else if(pageType == 10) {
            // 10-商户详情
            eRightBtn |= (ERightBtnRating | ERightBtnFavorite);
        }
    }
    else if(_eLaunchType == ELaunchTypeUniversalWebDriven) {
        if([_poiData[@"navBar"][@"showBill"] boolValue]) {
            eRightBtn |= ERightBtnBill;
        }
    }
    if(_eLaunchType == ELaunchTypeLocalMerchant) {
        // 从我的收藏页面过来的商户详情
        eRightBtn |= (ERightBtnRating | ERightBtnFavorite);
    }
    else if(_eLaunchType == ELaunchTypePluginNewPageOpen) {
        if(_eLaunchType == ELaunchTypeLocalMerchant) {
            eRightBtn |= (ERightBtnRating | ERightBtnFavorite);
        }
    }
    
    return eRightBtn;
}

- (EShareType)localSharePageType
{
    EShareType eType = EShareTypeNone;
    
    switch ([[self billTypeCode] integerValue]) {
        case 1:
        case 2:
        case 3:
            eType = EShareTypeCoupon;
            break;
        case 4:
            eType = EShareTypeETicket;
            break;
        case 6:
            eType = EShareTypeRebate;
            break;
        default:
            break;
    }
    
    return eType;
}

- (NSString *)naviTitleForPlugin
{
    NSString* title = _poiData[@"title"];
    if(title.length > 0) {
        // Apply JS plugin ver 2.0
        return title;
    }
    
    /*
     *type: '0-不加 | 1-优惠券详情  | 2-电子票详情  | 3-积分券详情 | 4-活动详情 | 5-门店列表 | 6-银联钱包电子票使用介绍 | 7-银联钱包优惠券使用介绍 | 8-银联钱包积分券使用介绍 | 9-用户评论列表 | 10-商户详情
     **/
    NSInteger pageType = [_poiData[@"type"] integerValue];
    switch (pageType) {
        case 1:
            title = UP_STR(@"kStrCouponDetail");
            break;
        case 2:
            title = UP_STR(@"kStrETicketDetail");
            break;
        case 3:
            title = UP_STR(@"kStrRebateDetail");
            break;
        case 4:
            title = UP_STR(@"kStrActivityDetail");
            break;
        case 5:
            title = UP_STR(@"kStrMerchantList");
            break;
        case 6:
        case 7:
        case 8:
            title = UP_STR(@"kStrFreshMenUsage");
            break;
        case 9:
            title = UP_STR(@"kStrCommentList");
            break;
        case 10:
            title = UP_STR(@"kStrMerchantDetail");
            break;
        case 14:
            // 版本说明详情
            title = UP_STR(@"String_FeaturesIntroduction");
            break;
        default:
            break;
    }
    
    return title;
}

@end

