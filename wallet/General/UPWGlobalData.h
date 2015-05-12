//
//  UPWGlobalData.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-28.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPWUserInfoModel.h"
#import "UPWSysInitModel.h"
#import "UPWAccountInfoModel.h"

@interface UPWGlobalData : NSObject

//彩虹果
@property(nonatomic,strong) UPWAccountInfoModel* accountInfo;
@property(nonatomic,strong) NSString* Authorization;




//钱包
@property(nonatomic,copy) NSString* virtualID;
@property(nonatomic,copy) NSString* uniIdentifier;

// 客户端初始化完成后的数据
@property(nonatomic,strong) UPWSysInitModel* sysInitModel;

//用户账户信息
@property(nonatomic,strong) UPWBigUserInfoModel* bigUserInfo;

// 从微信打开票券页面启动钱包的URL
@property(nonatomic, copy) NSURL * launchUrlByWeixin;

//当前城市。
@property(nonatomic,copy) NSString *currentCity;

@property(nonatomic, retain) NSMutableDictionary* allAppInfo;

//push消息的token
@property(nonatomic,copy) NSString* deviceToken;

//信用卡还款信息
@property(nonatomic,retain) NSMutableDictionary* huankuanInfo;

@property(nonatomic,assign) BOOL hasLogin;

@property(nonatomic,copy) NSString* locateCity;


+ (UPWGlobalData*)sharedData;


@end
