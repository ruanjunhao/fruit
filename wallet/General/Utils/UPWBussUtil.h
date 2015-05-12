//
//  UPWBussUtil.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-30.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPPayPluginPro.h"
#import "ShareMgr/ShareMgr.h"
#import "UPWSharePanel.h"
#import "UPWAppInfoModel.h"
#import "UPWLoginViewController.h"

typedef void (^trade_types_block_t)(NSArray* tradeTypes);

NSString* stringWithVer(NSString* formatKey);

@interface UPWBussUtil : NSObject

+ (BOOL)isCity:(NSString*)city equalToCity:(NSString*)city2;

+ (UPWAppInfoModel*)huankuanAppInfo;

+ (NSString*)trimBankNumber:(NSString *)bankNumber;

+ (NSString*)formatCardNumber:(NSString *)cardNumber;

+ (NSString*)daysSinceNow:(NSString*)date;

+ (void)payWithTn:(NSString*)tn
             mode:(NSString*)mode
   viewController:(UIViewController*)viewController
         delegate:(id<UPPayPluginDelegate>)delegate;

+ (BOOL)validPhoneNumber:(NSString*)phoneNumber;

+ (BOOL)validUserPwd:(NSString*)userPwd;

+ (NSString *)trimDate:(NSString *)date;

#pragma mark - 应用跳转

+ (UIViewController*)viewControllerWithAppInfo:(UPWAppInfoModel*)appInfo;


#pragma mark - 手势密码随机字符串相关

+ (NSString *)getRandomOriginString;

+ (NSString *)randomPatternString:(NSString *)patternNumStr randomOriginString:(NSString *)randomString;

+ (NSString *)originPatternString:(NSString *)randomStr randomOriginString:(NSString *)randomOriginStr;

// 分享类容制作，包括更多和缴费模块
+ (UPShareContent *)shareContentForType:(UPShareType)shareType withJiaoFeiDest:(NSString *)destStr isForApp:(BOOL)isForApp;

// 判断手机号码是否完成，出去前缀，空格等，总的位数是11位
+ (BOOL)isPhoneNumberFilledAsCompleted:(NSString *)phoneNumText;

// 获取票券图标
+ (UIImage *)shortcutImageForBillWithType:(NSString *)billType isSecKill:(BOOL)isSecKill;

void showMessage(NSString * message);

+ (UPWLoginViewController *)showLoginWithSuccessBlock:(completionBlock)successBlock cancelBlock:(completionBlock)cancelBlock completion:(completionBlock)completionBlock;

+ (void)fetchTradeTypesWithCompetionBlock:(trade_types_block_t)competionBlock;

+ (BOOL)isWebFullUrl:(NSString *)url;

+ (void)refreshCartDot;

@end
