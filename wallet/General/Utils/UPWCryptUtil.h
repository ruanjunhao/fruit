//
//  UPWCryptUtil.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-28.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPWCryptUtil : NSObject

+ (void)setKey:(NSString*)key;

+ (NSString*)encryptMessage:(NSString*)msg;

+ (NSString*)decryptMessage:(NSString*)msg;

+ (NSString*)generateSessionKey;


@end
