//
//  UPHtmlUtility.h
//  UPWallet
//
//  Created by jhyu on 14-7-29.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPWSharePanel.h"

// 随行：wxd29ad08769821625  钱包 wx82582d2ace426da2
#define kWXAppKey           @"wx82582d2ace426da2"

// 随行：145373014  钱包 3535504461
#define kSinaWBAppKey       @"3535504461"

@class UPWWebData;
@class UPShareContent;

@interface UPWWebUtility : NSObject

+ (NSString *)webUrlWithWebData:(UPWWebData *)webData;

+ (UPShareContent *)shareContentWithType:(UPShareType)eShareType data:(id)obj bindingObj:(id)bindingObj;

+ (NSArray *)shareChannels;

+ (BOOL)isMyBillsShare:(UPWWebData *)webData;

@end
