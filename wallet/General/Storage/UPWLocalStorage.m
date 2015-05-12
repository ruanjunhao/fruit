//
//  UPLocalStorage.m
//  UPWallet
//
//  Created by wxzhao on 14-6-9.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWLocalStorage.h"
#import "UPWPathUtil.h"
#import "UPWFileUtil.h"
#import "UPXConstKey.h"
#import "UPWConst.h"


@implementation UPWLocalStorage

+ (void)registerDefaultValue
{
    // 默认后台开通
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kUDKeyPushSettingSwitch:@YES}];
}

+ (BOOL)firstLaunched
{
    NSString* obj = [[NSUserDefaults standardUserDefaults] objectForKey:KUDKeyFirstLaunch];
    if ([obj isEqualToString:@"yes"]) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (void)setFirstLaunched:(BOOL)firstLaunched
{
    [[NSUserDefaults standardUserDefaults] setObject:firstLaunched?@"yes":@"no" forKey:KUDKeyFirstLaunch];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark - 保存用户选择的社区
+ (NSString *)latestCommunity
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyCommunity];
}

+ (void)setLatestCommunity:(NSString *)latestCommunity
{
    [[NSUserDefaults standardUserDefaults] setObject:latestCommunity forKey:kUDKeyCommunity];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark 保存用户选择的城市信息

+ (UPWCityModel*)latestCity
{
    NSDictionary* dict = [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyLatestCity];
    
    return [[UPWCityModel alloc] initWithDictionary:dict error:nil];
}

+ (void)setLatestCity:(UPWCityModel*)latestCity
{
    [[NSUserDefaults standardUserDefaults] setObject:[latestCity toDictionary] forKey:kUDKeyLatestCity];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark 记录最近登录的用户名

+ (NSString*)latestUserName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyLatestUsername];
}

+ (void)setLatestUserName:(NSString*)userName
{
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:kUDKeyLatestUsername];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark 优惠券搜索记录

+ (NSArray*)searchHistory
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeySearchHistory];
}

+ (void)insertSearchHistory:(NSArray*)historyArray
{
    [[NSUserDefaults standardUserDefaults] setObject:historyArray forKey:kUDKeySearchHistory];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark 记录客户端最新版本

+ (NSString*)lastVersion
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyLastVersion];
}

+ (void)setLastVersion:(NSString*)lastVersion
{
    [[NSUserDefaults standardUserDefaults] setObject:lastVersion forKey:kUDKeyLastVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];    
}

#pragma mark -
#pragma mark 交易类型列表

+ (NSArray *)tradeTypes
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUDKeyTradeTypes];
}

+ (void)setTradeTypes:(NSArray *)tradeTypes
{
    [[NSUserDefaults standardUserDefaults] setObject:tradeTypes forKey:kUDKeyTradeTypes];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark 推送消息开关状态

+ (BOOL)isPushSettingSwitchOn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUDKeyPushSettingSwitch];
}
+ (void)setPushSettingSwitch:(BOOL)isOn
{
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:kUDKeyPushSettingSwitch];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


