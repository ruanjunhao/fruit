//
//  UPWMyCardsTrackMgr.h
//  wallet
//
//  Created by jhyu on 14/11/4.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UPWBaseViewController;

@interface UPWMyCardsTrackMgr : NSObject

- (id)initWithOwnerVC:(UPWBaseViewController *)ownerVC;

- (void)openMyFootPrintPage;

- (void)openMyHuaXiaoPage;

@end
