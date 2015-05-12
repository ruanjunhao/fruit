//
//  ShareMgr.m
//  ShareMgr
//
//  Created by jhyu on 14-6-18.
//  Copyright (c) 2014年 UP. All rights reserved.
//

#import "ShareMgr.h"
#import "weixinShare.h"
#import "weiboShare.h"
#import "smsShare.h"
#import "smsShare.h"

NSString* const kNotificationShareResult = @"kNotificationShareResult";
NSString* const kResultCode = @"kResultCode";

@interface ShareMgr ()  {
    smsShare*           _smsShare;
    weixinShare*        _wxShare;
    weiboShare*         _sinaWBShare;
    UIViewController*   _topVC;
    
    NSString*           _appKey4SinaWeibo;
    NSString*           _appKey4Weixin;
}

@end

@implementation ShareMgr

#pragma mark -
#pragma mark - Public methods

+ (instancetype)instance
{
    static id mySharInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharInstance = [[ShareMgr alloc] init];
    });
    
    return mySharInstance;
}

- (BOOL)appDelegateOpenURL:(NSURL *)url
{
    if (!url) {  return NO; }
    
    NSString * scheme = [url scheme];
    if([scheme isEqualToString:[NSString stringWithFormat:@"wb%@", _appKey4SinaWeibo]]) {
        // Sina weibo.
        BOOL ret = [WeiboSDK handleOpenURL:url delegate:_sinaWBShare];
        return ret;
    }
    else if([scheme isEqualToString:_appKey4Weixin]) {
        // weixin.
        BOOL ret = [WXApi handleOpenURL:url delegate:_wxShare];
        return ret;
    }
 
    return NO;
}

#pragma mark - 微信好友

- (BOOL)canOpenWeixinWithAppKey:(NSString *)key
{
    if(!_wxShare) {
        _wxShare = [[weixinShare alloc] initWithAppKey:key];
    }
    
    return [_wxShare isWeixinAvailable];
}

- (BOOL)openWeixinWithAppKey:(NSString *)key content:(UPShareContent *)content
{
    if(![self canOpenWeixinWithAppKey:key]) {
        errno = EErrorNotSupport;
        return NO;
    }
    
    _appKey4Weixin = key;
    
    return [_wxShare shareWithTitle:content.title description:content.body image:content.image url:content.webUrl isGroupShare:NO];
}

#pragma mark - 微信朋友圈

- (BOOL)canOpenWeixinGroupWithAppKey:(NSString *)key
{
    if(!_wxShare) {
        _wxShare = [[weixinShare alloc] initWithAppKey:key];
    }
    
    return [_wxShare isWeixinGroupAvailable];
}

- (BOOL)openWeixinGroupWithAppKey:(NSString *)key content:(UPShareContent *)content
{
    if(![self canOpenWeixinGroupWithAppKey:key]) {
        errno = EErrorNotSupport;
        return NO;
    }
    
    _appKey4Weixin = key;
    
    return [_wxShare shareWithTitle:content.title description:content.body image:content.image url:content.webUrl isGroupShare:YES];
}

#pragma mark - 新浪微博

- (BOOL)canOpenSinaWeiboWithAppKey:(NSString *)key
{
    if(!_sinaWBShare) {
        _sinaWBShare = [[weiboShare alloc] initWithAppKey:key];
    }
    
    return [_sinaWBShare isSinaWeiboAvailable];
}

- (BOOL)openSinaWeiboWithAppKey:(NSString *)key content:(UPShareContent *)content topVC:(UIViewController *)topVC
{
    if(![self canOpenSinaWeiboWithAppKey:key]) {
        errno = EErrorNotSupport;
        return NO;
    }
    
    _appKey4SinaWeibo = key;
    
    return [_sinaWBShare shareWithTopVC:topVC message:content.body url:content.webUrl image:content.image];
}

#pragma mark - 短信

- (BOOL)canOpenSms
{
    if(!_smsShare) {
        _smsShare = [[smsShare alloc] init];
    }
    
    return [smsShare isSmsAvailable];
}

- (BOOL)openSmsWithContent:(UPShareContent *)content topVC:(UIViewController *)topVC
{
    if(![self canOpenSms]) {
        errno = EErrorNotSupport;
        return NO;
    }
    
    return [_smsShare shareMessageWithTopVC:topVC message:content.body];
}

@end


#pragma mark -
#pragma mark - UPShareContent

@implementation UPShareContent
@end

