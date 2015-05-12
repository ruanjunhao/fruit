//
//  UPWMessage.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

#define KHTTP_METHOD_POST @"POST"
#define KHTTP_METHOD_GET @"GET"
#define KSOURCE             @"2"
#define KVERSION            @"1.0"

@interface UPWMessageHeader : JSONModel

//彩虹果
@property(nonatomic,strong) NSString<Optional>* Authorization;

//钱包
@property (nonatomic, copy) NSString<Optional>* vid;
@property (nonatomic, copy) NSString<Optional>* decrypt;
@property (nonatomic, copy) NSString<Optional>* userAgent;
@property (nonatomic, copy) NSString<Optional>* contentType;
@property (nonatomic, copy) NSString<Optional>* uniIdentifier;

// 秒杀券需要访问Header里面内容所以将此接口外置
+ (instancetype)chspHeader;


@end


@interface UPWMessageBody : JSONModel

@property (nonatomic, copy) NSDictionary<Optional>* params;

@end


@interface UPWMessage : JSONModel

@property (nonatomic, strong) NSDictionary<Optional>* body;
@property (nonatomic, strong) NSDictionary<Optional>* params;
@property (nonatomic, copy) NSString<Optional>* path;
@property (nonatomic, assign) BOOL encrypt;
@property (nonatomic, strong) UPWMessageHeader<Optional>* header;
@property (nonatomic, copy) NSString<Optional>* httpMethod;
@property (nonatomic, assign) BOOL isFromWeb;

//彩虹果报文接口
+ (instancetype)sysInit;
+ (instancetype)sysCheckversion:(NSString*)flag;
//第一批
+ (instancetype)messageWheelImageListWithParams:(NSDictionary *)params;
+ (instancetype)messageCatagoryListWithParams:(NSDictionary *)params;
+ (instancetype)messageFruitListWithParams:(NSDictionary *)params;
+ (instancetype)messageShoppingCartListWithParams:(NSDictionary *)params;
+ (instancetype)messageSyncShoppingCartListWithParams:(NSDictionary*)params;
+ (instancetype)messageDeliveryAddressWithParams:(NSDictionary *)params;
+ (instancetype)messageUploadNewDeliveryAddrWithParams:(NSDictionary*)params;
//第二批
+ (instancetype)messageAccountInfoWithParams:(NSDictionary *)params;
+ (instancetype)messageLoginWithParams:(NSDictionary*)params;
+ (instancetype)messageSmsWithParams:(NSDictionary*)params;
+ (instancetype)messageRegisterWithParams:(NSDictionary*)params;
+ (instancetype)messageOrderListWithParams:(NSDictionary *)params;
//第三批
+ (instancetype)messageLogoutWithParams:(NSDictionary*)params;
+ (instancetype)messageCommitOrderWithParams:(NSDictionary*)params;

//可能会用到的接口，借鉴
+ (instancetype)sysCheckkey;
+ (instancetype)sysGetkey;
+ (instancetype)regionLocatePosition:(NSString*)cityNm;
+ (instancetype)regionRelocatePosition:(NSString*)longitude latitude:(NSString*)latitude cityNm:(NSString*)cityNm;
+ (instancetype)uploadDeviceToken:(NSString *)deviceToken status:(BOOL)isOn;
//清理推送消息数
+ (instancetype)clearSystemMessage:(NSString *) deviceToken;
+ (instancetype)messageWithUrl:(NSString *)url params:(NSDictionary *)params encrypt:(BOOL)encrypt isPost:(BOOL)isPost hostType:(NSString *)hostType;

@end

