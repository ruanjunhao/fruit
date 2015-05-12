//
//  UPWAppUtil.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef BOOL (^FinishBlock)(void);

@interface UPWAppUtil : NSObject


+ (float)deviceOS;

#pragma mark - app版本号
+ (NSString*)appVersion;

#pragma mark - 去掉小数点的app版本号
+ (NSString*)formatAppVersion;

+ (NSString*)localizedStringWithKey:(NSString*)key;

+ (NSArray*)localizedArrayWithKey:(NSString*)key;

+ (void)writeConfigFile:(NSData *)data;

+ (BOOL)isEmpty:(NSString *)value;

+ (UIColor*)colorWithHexString: (NSString *) str;

+ (UIImage*)getImage:(NSString*) imageName;

+ (BOOL)isRetina;

+ (NSURL*)urlWithString:(NSString *)value;

// return if open remote notification
+ (BOOL)isAllowRemoteNotification;

#pragma mark - 银行卡数字相关处理

+ (NSString *)formatBankNumberWithStar:(NSString *)bankNumber;

+ (NSString*)trimBankNumber:(NSString *)bankNumber;

+ (NSString*)formatBankNumber:(NSString *)bankNumber;

+ (NSString *)appBundleDisplayName;

+ (BOOL)waitForTarget:(FinishBlock)block withTimeout:(NSTimeInterval)timeoutInSeconds;

+ (NSString *)ratingAppStoreUrlById:(NSString *)appId;

+ (NSString *)appStoreUrlById:(NSString *)appId;

+ (NSString *)gaodeMapAppKey;

+ (NSString *)appBundleIdentifier;

@end
