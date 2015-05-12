//
//  UPWDeviceUtil.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPWDeviceUtil : NSObject

+ (NSString*)vendorIdentifier;
+ (NSString*)deviceOSVersion;
+ (NSString*)machineType;
+ (NSString*)deviceWidth;
+ (NSString*)deviceHeight;
+ (NSString*)model;
+ (NSString*)systemName;
+ (NSString*)localLanguage;
+ (NSString*)screenSize;
+ (NSString *)bundleSeedID;
+ (BOOL)isJailbroken;


@end
