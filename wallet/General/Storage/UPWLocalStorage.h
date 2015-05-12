//
//  UPLocalStorage.h
//  UPWallet
//
//  Created by wxzhao on 14-6-9.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPWCityModel.h"


@interface UPWLocalStorage : NSObject

+ (void)registerDefaultValue;

+ (BOOL)firstLaunched;
+ (void)setFirstLaunched:(BOOL)firstLaunched;

+ (NSString *)latestCommunity;
+ (void)setLatestCommunity:(NSString *)latestCommunity;

+ (UPWCityModel*)latestCity;
+ (void)setLatestCity:(UPWCityModel*)latestCity;

+ (NSString*)latestUserName;
+ (void)setLatestUserName:(NSString*)userName;

+ (NSArray*)searchHistory;
+ (void)insertSearchHistory:(NSArray*)historyArray;

+ (NSString*)lastVersion;
+ (void)setLastVersion:(NSString*)lastVersion;

+ (NSArray *)tradeTypes;
+ (void)setTradeTypes:(NSArray *)tradeTypes;

+ (BOOL)isPushSettingSwitchOn;
+ (void)setPushSettingSwitch:(BOOL)isOn;

@end
