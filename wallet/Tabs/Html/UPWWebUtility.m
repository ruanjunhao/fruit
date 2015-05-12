//
//  UPHtmlUtility.m
//  UPWallet
//
//  Created by jhyu on 14-7-29.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWWebUtility.h"
#import <objc/runtime.h>
#import "UPWWebData.h"
#import "UPWGlobalData.h"
#import "UPWEnvMgr.h"
#import "NSString+IACExtensions.h"
#import "UIImageView+MKNetworkKitAdditions_johankool.h"
#import "ShareMgr/ShareMgr.h"
#import "SDWebImageManager.h"
#import "UPXConstStrings.h"

NSString* const UPRecmdUsrId = @"recmdUsrId";
static const char kCacheWebImage;

@implementation UPWWebUtility

#pragma mark -
#pragma mark - 分享模块

+ (BOOL)isMyBillsShare:(UPWWebData *)webData
{
    return (webData.eLaunchType == ELaunchTypeUniversalWebDriven);
}

+ (NSString *)webUrlWithWebData:(UPWWebData *)webData
{
    /*
     替换过程：
     1. 将startPage分成两段，前面是URL，后面是参数数组。
     2. URL是APP模式的，在WEB页面打开的话，替换成WEB模式。
     3. 参数模块添加其他要素，比如推荐人ID。
     */
    
    NSMutableString * shareUrl = [NSMutableString stringWithString:webData.startPage];
    NSArray * components = [shareUrl componentsSeparatedByString:@"?"];
    NSAssert(components.count >= 1, @"Should be true here.");
    [shareUrl setString:components.firstObject];
    
    NSDictionary * queries = [components.lastObject parseURLParams];
    NSMutableDictionary * params;
    if(queries) {
        params = [NSMutableDictionary dictionaryWithDictionary:queries];
    }
    else {
        params = [NSMutableDictionary dictionary];
    }
    
    // APP端的链接替换成WEB的，便于在网站打开。
    if(webData.eShareType == EShareTypeActivity) {
        [shareUrl replaceOccurrencesOfString:@"/app/" withString:@"/v2/web/" options:0 range:NSMakeRange(0, shareUrl.length)];
    }
    else if(webData.eShareType == EShareTypeMerchant) {
        [shareUrl replaceOccurrencesOfString:kMchntDetailUrl withString:@"v2/web/detail/bill.html" options:0 range:NSMakeRange(0, shareUrl.length)];
    }
    else {
        // 票券详情，APP端是静态页面格式，WEB端还是老格式，需完全替换。
        
        // 测试案例： NSString * url = @"http://172.18.342.10/hybrid_v3/detail/appDetail_9999_8888_7777.html?si=_5_&ver=_6_";
        NSArray * items = [[[NSURL URLWithString:shareUrl] relativePath] componentsSeparatedByString:@"_"];
        NSString * brandId;
        NSString * billId;
        
        for(int i = 0; i < items.count; ++i) {
            if([items[i] hasSuffix:@"detail/appDetail"])  {
                if(i + 2 < items.count) {
                    brandId = items[i + 1];
                    billId = items[i + 2];
                }
                break;
            }
        }
        
        NSString * webUrl = [[UPWEnvMgr chspImgServerUrl] stringByAppendingSubUrl:@"v2/web/detail/bill.html"];
        if(brandId && billId) {
            webUrl = [webUrl stringByAppendingFormat:@"?brandId=%@&billId=%@", brandId, billId];
        }
        
        shareUrl = [NSMutableString stringWithString:webUrl];
    }
    
    // 添加推荐人ID。
    NSString * referer = UP_SHDAT.bigUserInfo.encryptCdhdUsrId;
    if([referer length] > 0) {
        params[UPRecmdUsrId] = referer;
    }
    
    // 重组新的URL。
    NSString * fullUrl = [shareUrl stringByAppendingURLParams:params];
    
    return fullUrl;
}

+ (UPShareContent *)shareContentWithType:(UPShareType)eShareType data:(id)obj bindingObj:(id)bindingObj
{
    // 创建UPShareContent对象为分享提供内容。
    NSString* title;
    NSString* body;
    NSString* imagePath;
    NSString* webUrl;
    
    switch (eShareType) {
        case UPWeiXin:
        case UPWeiXinGroup:
            title = obj[@"title"];
            body = obj[@"desc"];
            imagePath = obj[@"picUrl"];
            // 微信票券点击返回URL
            webUrl = [[self class] weixinWebLinkUrlFromData:obj];
            break;
            
        case UPSinaWeiBo:
            body = obj[@"content"];
            break;
            
        case UPSMS:
            body = obj[@"content"];
            break;
            
        default:
            break;
    }
    
    UPShareContent * shareContent = [[UPShareContent alloc] init];
    
    if([title isMemberOfClass:[NSNull class]]) {
        shareContent.title = @"";
    }
    else {
        shareContent.title = title;
    }
    
    if([body isMemberOfClass:[NSNull class]]) {
        shareContent.body = @"";
    }
    else {
        shareContent.body = body;
    }
    
    if([webUrl isMemberOfClass:[NSNull class]]) {
        shareContent.webUrl = @"";
    }
    else {
        shareContent.webUrl = webUrl;
    }
    
    if([imagePath isMemberOfClass:[NSNull class]]) {
        imagePath = @"";
    }
    
    // 如果没有图片的话直接返回
    if(imagePath.length == 0) {
        return shareContent;
    }
    
    UIImage * picImage = objc_getAssociatedObject(bindingObj, &kCacheWebImage);
    if(!picImage) {
        // 异步获取网络图片
        NSString* imageUrl = [[UPWEnvMgr chspImgServerUrl] stringByAppendingSubUrl:imagePath];
        
        [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            if(image) {
                // image的生命周期与bindingObj一致。
                objc_setAssociatedObject(bindingObj, &kCacheWebImage, image,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }];
    }
    
    shareContent.image = picImage;
    
    return shareContent;
}


+ (NSString*)weixinWebLinkUrlFromData:(id)obj
{
    NSString* url = [[UPWEnvMgr chspImgServerUrl] stringByAppendingSubUrl:obj[@"shareUrl"]];
    
    if([[NSURL URLWithString:url] scheme].length > 0) {
        // 添加 @"sharechannel" : @"wx", JS端需求
        NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"wx", @"sharechannel", nil];
        
        // 添加推荐人ID
        NSString * referer = [UPWGlobalData sharedData].bigUserInfo.encryptCdhdUsrId;
        if([referer length] > 0) {
            params[UPRecmdUsrId] = referer;
        }
        
        url = [url stringByAppendingURLParams:params];
        return url;
    }
    
    return nil;
}

+ (NSArray *)shareChannels
{
    ShareMgr * instance = [ShareMgr instance];
    NSMutableArray * channels = [NSMutableArray array];
    
    if([instance canOpenWeixinWithAppKey:kWXAppKey]) {
        [channels addObject:@(UPWeiXin)];
    }
    
    if([instance canOpenWeixinGroupWithAppKey:kWXAppKey]) {
        [channels addObject:@(UPWeiXinGroup)];
    }
    
    if([instance canOpenSinaWeiboWithAppKey:kSinaWBAppKey]) {
        [channels addObject:@(UPSinaWeiBo)];
    }
    
    if([instance canOpenSms]) {
        [channels addObject:@(UPSMS)];
    }
    
    return channels;
}

@end
