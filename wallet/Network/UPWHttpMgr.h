//
//  UPWHttpMgr.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKNetworkEngine.h"
#import "UPWMessage.h"
#import "MKNetworkOperation.h"



typedef void (^http_success_block_t)(NSDictionary* response);
typedef void (^http_fail_block_t)(NSError* error);

typedef void (^http_get_success_block_t)(NSData* data);

static const NSString* kDetailError = @"DetailError";

@interface UPWHttpMgr : NSObject

@property (nonatomic, copy) NSString* hostName;

@property (nonatomic, strong) NSDate* lastSysGetKeyTime; //上一次交换密钥的时间, 为了安全期间, 在3个请求超时时间内不再做新的交换密钥

@property (nonatomic, assign) BOOL hasKey;   //是否已经拿到 key


+ (instancetype)instance;

- (NSOperation*)downloadWithURL:(NSString*)url success:(http_get_success_block_t)successBlock fail:(http_fail_block_t)failBlock;

- (void)sendMessage:(UPWMessage*)message success:(http_success_block_t)successBlock fail:(http_fail_block_t)failBlock;

- (void)cancelMessage:(UPWMessage*)message;

@end