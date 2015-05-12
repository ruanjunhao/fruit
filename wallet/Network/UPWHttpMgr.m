
//
//  UPWHttp.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWHttpMgr.h"
#include "UPWCryptUtil.h"
#import "UPWNotificationName.h"
#import "UPXUtils.h"
#import "UPWConst.h"
#import "UPWBussUtil.h"


#define kKeyRespCode                @"resp"
#define kKeyMsg                     @"msg"
#define kKeySucceed                 @"0000"
#define kKeyUserStatusError             @"90"

#define kUPFreezableOperationExtension @"UPFrozenOperation"

#define kNCGetKeyFinished @"UPNCGetKeyFinished"


@interface UPWHttpRequestObj : NSObject
@property (nonatomic, strong) http_success_block_t successBlock;
@property (nonatomic, strong) http_fail_block_t failBlock;
@property (nonatomic, strong) UPWMessage* message;
@end

@implementation UPWHttpRequestObj @end

@interface UPWHttpMgr()
{
    MKNetworkEngine* _engine;
    BOOL _isGettingKey;//是否正在发送 sys.getKey
    NSMutableArray* _resendEncMsgArr;//需要重发的加密消息队列
    NSMutableArray* _pendingOperations;//正在发送的请求, 用于取消
    NSMutableDictionary* _operationMessageInfo;//根据 UPWMessage 对应的 operation 的 udid
}

@end


@implementation UPWHttpMgr

+ (instancetype)instance
{
    static UPWHttpMgr* httpEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpEngine = [[UPWHttpMgr alloc] init];
    });
    
    return httpEngine;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _resendEncMsgArr = [[NSMutableArray alloc] init];
        _pendingOperations = [[NSMutableArray alloc] init];
        _operationMessageInfo = [[NSMutableDictionary alloc] init];
        _isGettingKey = NO;
        _hasKey = NO;
    }
    
    return self;
}


- (void)addToResendMsgArr:(UPWMessage*)message success:(http_success_block_t)successBlock fail:(http_fail_block_t)failBlock
{
    UPWHttpRequestObj* request = [[UPWHttpRequestObj alloc] init];
    request.message = message;
    request.successBlock = successBlock;
    request.failBlock = failBlock;
    [_resendEncMsgArr addObject:request];

}

- (void)resendMessages
{
    [_resendEncMsgArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //针对持卡人加密报文，在做完秘钥交换，重发上一加密请求前，重新设置header.uniIdentifier
        UPWHttpRequestObj* request = (UPWHttpRequestObj*)obj;
        UPWMessage *msg = request.message;
        UPWMessageHeader *header = msg.header;
        if ([header.userAgent isEqualToString:@"iPhone CHSP"]) {
            if (msg.encrypt) {
                if (!UP_IS_NIL(UP_SHDAT.uniIdentifier)) {
                    header.uniIdentifier = UP_SHDAT.uniIdentifier;
                    msg.header = header;
                }
            }
        }
        [self sendMessage:msg success:request.successBlock fail:request.failBlock];
    }];
    [_resendEncMsgArr removeAllObjects];
}

- (void)failToResendMessages:(NSError*)error
{
    [_resendEncMsgArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UPWHttpRequestObj* request = (UPWHttpRequestObj*)obj;
        if (request.failBlock) {
            NSError* reqError = error;
            if (reqError == nil) {
                reqError = [NSError errorWithDomain:@"ErrorFromNetwork"
                                               code:kErrorGetKeyCode
                                           userInfo:@{NSLocalizedDescriptionKey:kErrorResendMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%ld",(long)kErrorGetKeyCode]}];
            }
            UPDERROR(@"failToResendMessages %@",reqError);
            request.failBlock(reqError);
        }
    }];
    [_resendEncMsgArr removeAllObjects];
}

- (void)setHostName:(NSString *)hostName
{
    _hostName = [hostName copy];
    _engine = [[MKNetworkEngine alloc] initWithHostName:hostName];
}

- (void)dealloc
{
    
}

- (NSOperation*)downloadWithURL:(NSString*)url success:(http_get_success_block_t)successBlock fail:(http_fail_block_t)failBlock

{
    UPDINFO(@"downloadWithURL: %@",url);
    
    MKNetworkOperation *op = [_engine operationWithURLString:url
                                                   params:nil
                                               httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation){
        if (successBlock) {
            successBlock([completedOperation responseData]);
        }
    }
                errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {
                    if (failBlock) {
                        UPDERROR(@"downloadWithURL failed %@, %@",url, error);
                        failBlock(error);
                    }
                }];
    [_engine enqueueOperation:op forceReload:YES];
    return op;
}


- (void)internalSendMessage:(UPWMessage*)message success:(http_success_block_t)successBlock fail:(http_fail_block_t)failBlock
{
    
    NSString* path = message.path;
    NSString* msg = nil;
    if (message.body.count > 0) {
        NSData* data = [NSJSONSerialization dataWithJSONObject:message.body options:0 error:nil];
        msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    BOOL encrypted = message.encrypt;
    NSDictionary* hdr = [message.header toDictionary];
    NSMutableString* urlString = [_hostName mutableCopy];
    if ([UPWBussUtil isWebFullUrl:path]) {
        [urlString setString:path];
    }
    else if (!UP_IS_NIL(path)) {
        [urlString setString:[NSString stringWithFormat:@"%@/%@",_hostName,path]];
    }
    if ([message.httpMethod isEqualToString:KHTTP_METHOD_GET])
    {
        NSMutableDictionary* fields = [[NSMutableDictionary alloc] init];
        if (encrypted) {
            [message.params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString* value = (NSString*)obj;
                [fields setObject:[UPWCryptUtil encryptMessage:value] forKey:key];
            }];
        }
        else{
            fields = [message.params mutableCopy];
        }
        if ([fields count] > 0 ) {
            [urlString appendFormat:@"?%@",[fields urlEncodedKeyValueString]];
        }
    }
    else if ([message.httpMethod isEqualToString:KHTTP_METHOD_POST])
    {
        if (UP_IS_NIL(msg)) {
            msg = @"{}";
        }
    }
    
    MKNetworkOperation* op = [_engine operationWithURLString:urlString params:nil httpMethod:message.httpMethod];
    [op addHeaders:hdr];
    if([message.httpMethod isEqualToString:KHTTP_METHOD_POST]){
        [op setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
            
        
            if (encrypted) {
                return [UPWCryptUtil encryptMessage:msg];
            }
            return msg;
        } forType:@"application/json"];
    }
    
    __weak typeof(self) weakSelf = self;
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        
        [_pendingOperations removeObject:completedOperation];
        [_operationMessageInfo removeObjectForKey:@([[message toJSONString] hash])];

        id responseJSON = nil;
        if (encrypted) {
            responseJSON = [weakSelf responseJSONFromEncryptedString:[completedOperation responseString]];
            
        }
        else {
            responseJSON = [completedOperation responseJSON];
        }
        
        [weakSelf dispatchResponseJSON:responseJSON  message:message success:successBlock fail:failBlock];
    }
                errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
                    [_pendingOperations removeObject:completedOperation];
                    [_operationMessageInfo removeObjectForKey:@([[message toJSONString] hash])];
                    if ([error code] == 401) {
                        //密钥超时, 授权失败
                        if (message.encrypt) {
                            NSTimeInterval interval = -[_lastSysGetKeyTime timeIntervalSinceNow];
                            if (interval > 10) {
                                //设置 hasKey = NO 之前先判断当前时间距离lastSysGetKeyTime有没有超过三个请求超时时间, 就怕刚第一个请求交换过密钥后的加密消息报文还没回到客户端, 第二个请求的401超时返回了
                                _hasKey = NO;
                                [weakSelf sendMessage:message success:successBlock fail:failBlock];
                            }
                            else{
                                [weakSelf error:error message:message withBlock:failBlock];
                            }
                        }
                        else{
                            [weakSelf error:error message:message withBlock:failBlock];
                        }
                    }
                    else{
                        [weakSelf error:error message:message withBlock:failBlock];

                    }
                }];
    [_engine enqueueOperation:op forceReload:YES];
    
    //将 UPWMessage 对象和 NSOperaion 的uniqueIdentifier 对应起来
    if (!UP_IS_NIL([message toJSONString])) {
        [_operationMessageInfo setObject:op.uniqueIdentifier forKey:@([[message toJSONString] hash])];
        [_pendingOperations addObject:op];
    }

}

- (void)error:(NSError*)error message:(UPWMessage*)message withBlock:(http_fail_block_t)failBlock
{
    NSError* reqError = [NSError errorWithDomain:@"ErrorFromNetwork"
                                            code:[error code]
                                        userInfo:@{NSLocalizedDescriptionKey:kErrorNetworkMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%ld",(long)[error code]]}];
    if (failBlock) {
        UPDERROR(@"internal send message fail %@ %@",[message toDictionary], error);
        failBlock(reqError);
    }

}


/*
 @praram :info字典的结构：@{"path":"不包含host的url",@"msg":@"为加密的发送报文",@"hdr":@"需要增加的http header",@"enc":@" ‘enc’表明需要msg需要加密发送 "}
 */

- (void)sendMessage:(UPWMessage*)message success:(http_success_block_t)successBlock fail:(http_fail_block_t)failBlock
{
    UPDNETMSG(@"sendMessage: %@",[message toDictionary]);
    
    if (!message) {
        UPDERROR(@"sendMessage pass empty message");
        NSError* reqError = [NSError errorWithDomain:@"ErrorFromNetwork"
                                                code:kErrorInvalidMsgCode
                                            userInfo:@{NSLocalizedDescriptionKey:kErrorInvalidMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%ld",(long)kErrorInvalidMsgCode]}];
        if (failBlock) {
            failBlock(reqError);
        }
        return;
    }
    
    if (message.encrypt) {
        if (_isGettingKey) {
            [self addToResendMsgArr:message success:successBlock fail:failBlock];
        }
        else{
            if (_hasKey) {
                [self internalSendMessage:message success:successBlock fail:failBlock];
            }
            else{
                [self addToResendMsgArr:message success:successBlock fail:failBlock];
                UPWMessage* msg = [UPWMessage sysGetkey];
                _isGettingKey = YES;
                [self sendMessage:msg success:^(NSDictionary * response) {
                    _isGettingKey = NO;
                    if (response && [response isKindOfClass:[NSDictionary class]] && response[@"params"][@"encryptedCk"])
                    {
                        [UPWCryptUtil setKey:response[@"params"][@"encryptedCk"]];
                        UP_SHDAT.uniIdentifier = response[@"params"][@"uniIdentifier"];
                        _hasKey = YES;
                        [self resendMessages];
                        _lastSysGetKeyTime = [NSDate date];
                    }
                    else{
                        _hasKey = NO;
                        [self failToResendMessages:nil];
                    }
                    
                } fail:^(NSError * error) {
                    _isGettingKey = NO;
                    _hasKey = NO;
                    [self failToResendMessages:error];
                }];
            }
            
        }
    }
    else{
        [self internalSendMessage:message success:successBlock fail:failBlock];
    }
}



- (void)cancelMessage:(UPWMessage*)message
{
    NSString* msgStr = [message toJSONString];
    if (UP_IS_NIL(msgStr)) {
        return;
    }
    NSString* udid = _operationMessageInfo[@([msgStr hash])];
    [_pendingOperations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MKNetworkOperation* op = (MKNetworkOperation*)obj;
        if ([op.uniqueIdentifier isEqualToString:udid]) {
            [op cancel];
            [_pendingOperations removeObject:obj];
            *stop = YES;
        }
    }];
    [_operationMessageInfo removeObjectForKey:@([msgStr hash])];
    
    
    [_resendEncMsgArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UPWHttpRequestObj* request = (UPWHttpRequestObj*)obj;
        if ([[request.message toJSONString] hash] == [msgStr hash]) {
            [_resendEncMsgArr removeObject:obj];
            *stop = YES;
        }
    }];
}


#pragma mark - 将获取的数据先解密，然后转化成JSON

- (id)responseJSONFromEncryptedString:(NSString*) encryptedString
{
    id responseJSON;
    NSString* decMessage = [UPWCryptUtil decryptMessage:encryptedString];
    if (!UP_IS_NIL(decMessage)) {
        // 上线测试偶尔发现responseData为空，导致Crash
        NSData* responseData = [decMessage dataUsingEncoding:NSUTF8StringEncoding];
        if (responseData) {
            responseJSON = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        }
    }
    return responseJSON;
}

#pragma mark - 接收到服务器返回，分发数据

- (void)dispatchResponseJSON:(id)responseJSON message:(UPWMessage*)message success:(http_success_block_t)successBlock fail:(http_fail_block_t)failBlock
{
    if (!responseJSON) {
        NSError* error = [NSError errorWithDomain:@"ErrorFromServer" code:kErrorEmptyData userInfo:@{NSLocalizedFailureReasonErrorKey:@(kErrorEmptyData),NSLocalizedDescriptionKey:UP_STR(@"String_Empty_Data")}];
        if (failBlock) {
            UPDERROR(@"dispatchResponseJSON empty response");
            failBlock(error);
        }
    }
    else {
        //web 发的消息不处理，交给 web 处理，提供踢出的插件
        if (message.isFromWeb) {
            if (successBlock) {
                successBlock(responseJSON);
            }
            return;
        }
        
        NSString* resp = responseJSON[kKeyRespCode];
        NSString* msg = responseJSON[kKeyMsg];
        
        if (NSOrderedSame == [resp compare:kKeySucceed options:NSCaseInsensitiveSearch]) {
            UPDNETMSG(@"sendMessage response: %@",responseJSON);

            if (successBlock) {
                successBlock(responseJSON);
            }
        }
        else {
            if (NSOrderedSame == [resp compare:kKeyUserStatusError options:NSCaseInsensitiveSearch])
            {
                //清除 key, 因为被提出肯定密钥超时了, 不做把 haskey 设成 NO, 那么可能出现 A 登录, B 登录, A 再登录一直401, 因为有三个超时时间内不交换密钥的规则
                _hasKey = NO;
                
                //登录超时或者被踢出,抛出一个通知, 通知 baseViewController 去处理, 弹一个 alert, 点重新登录登录
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginKicked object:msg];
                UPDERROR(@"dispatchResponseJSON login kicked");
            }
            else
            {
                //登录超时直接 pop 了, 所以 failblock 没执行到也没啥关系, 但是子 vc 一定要在 dealloc 时 dismiss 掉 waitingView 之类的j
                NSError* error = [NSError errorWithDomain:@"ErrorFromServer"
                                                     code:[resp integerValue]
                                                 userInfo:@{NSLocalizedFailureReasonErrorKey:resp,
                                                            NSLocalizedDescriptionKey:msg,
                                                            kDetailError:responseJSON}];
                if (failBlock) {
                    UPDERROR(@"dispatchResponseJSON error %@", responseJSON);
                    failBlock(error);
                }
            }
            

        }
    }
}

@end
