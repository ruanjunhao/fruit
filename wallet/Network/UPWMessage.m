//
//  UPWMessage.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWMessage.h"
#import "UPWConst.h"
#import "UPWDeviceUtil.h"
#import "UPWAppUtil.h"
#import "UPWCryptUtil.h"
#import "UPWPathUtil.h"
#import "UPWEnvMgr.h"
#import "NSDictionary+RequestEncoding.h"
#import "UPWAppInfoModel.h"

#define KCMD_VER                @"1.0"
#define kMessageOSName          @"ios"
#define kMessageClientVersion   @11

#define kMockUrlPath @"http://172.17.248.51:8080/mobile/wallet/iOS/"

extern NSString* const UPRecmdUsrId;

NSString* URLEncode(id obj)
{
    NSString *escapedObj = obj;
    if ([obj isKindOfClass:[NSString class]]) {
        escapedObj = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)obj, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
    }
    
    return escapedObj;
}

NSString* commonPathWithVersion(NSString* version, NSString* cmd)
{
    NSMutableString* host =[[UPWEnvMgr chspServerUrl] mutableCopy];
    if ([cmd hasPrefix:@"/"]) {
        [host appendString:[NSString stringWithFormat:@"/%@%@",version,cmd]];
    } else {
        [host appendString:[NSString stringWithFormat:@"/%@/%@",version,cmd]];
    }
    return host;
}

NSString* commonPath(NSString* cmd)
{
//    return commonPathWithVersion(KCMD_VER, cmd);
    NSMutableString* host =[[UPWEnvMgr chspServerUrl] mutableCopy];
    if ([cmd hasPrefix:@"/"]) {
        [host appendString:[NSString stringWithFormat:@"%@", cmd]];
    } else {
        [host appendString:[NSString stringWithFormat:@"/%@", cmd]];
    }
    return host;
}

NSString* commonImagePathWithVersion(NSString* version, NSString* cmd)
{
    NSMutableString* host =[[UPWEnvMgr chspImgServerUrl] mutableCopy];
    if ([cmd hasPrefix:@"/"]) {
        [host appendString:[NSString stringWithFormat:@"/%@%@",version,cmd]];
    } else {
        [host appendString:[NSString stringWithFormat:@"/%@/%@",version,cmd]];
    }
    return host;
}

NSString* commonImagePath(NSString* cmd)
{
    NSMutableString* host =[[UPWEnvMgr chspImgServerUrl] mutableCopy];
    if ([cmd hasPrefix:@"/"]) {
        [host appendString:[NSString stringWithFormat:@"%@",cmd]];
    } else {
        [host appendString:[NSString stringWithFormat:@"/%@",cmd]];
    }
    return host;
}

NSDictionary *phoneInfo(void)
{
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    params[@"osName"] = kMessageOSName;
    params[@"osVersion"] = [UPWDeviceUtil deviceOSVersion];
    params[@"deviceModel"] = [NSString stringWithFormat:@"%@%@",@"Apple_",[UPWDeviceUtil machineType]];//Apple_iPhone6,2;
    params[@"deviceId"] = [UPWDeviceUtil vendorIdentifier];
    params[@"terminalResolution"] = [NSString stringWithFormat:@"%@*%@",[UPWDeviceUtil deviceWidth],[UPWDeviceUtil deviceHeight]];
    params[@"resVersion"] = [UPWAppUtil formatAppVersion];
    
    return params;
}

@implementation UPWMessageHeader

+ (instancetype)commonHeader
{
    UPWMessageHeader* header = [[UPWMessageHeader alloc] init];
    header.userAgent = @"userAgent";
    header.contentType = @"application/json";
    if (!UP_IS_NIL(UP_SHDAT.Authorization)) {
        header.Authorization = UP_SHDAT.Authorization;
    }
    return header;
}

+ (instancetype)chspHeader
{
    UPWMessageHeader* header = [[UPWMessageHeader alloc] init];
    header.userAgent = @"iPhone CHSP";
    header.contentType = @"application/json";
    if (!UP_IS_NIL(UP_SHDAT.uniIdentifier)) {
        header.uniIdentifier = UP_SHDAT.uniIdentifier;
    }
    return header;
}

+ (instancetype)encryptMsgHeader
{
    UPWMessageHeader* header = [UPWMessageHeader commonHeader];
    header.decrypt = @"1";
    return header;
}

+ (instancetype)encryptChspMsgHeader
{
    UPWMessageHeader* header = [UPWMessageHeader chspHeader];
    header.decrypt = @"1";
    return header;
}

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"User-Agent": @"userAgent",
                                                       @"Content-Type": @"contentType"}];
}

@end


@implementation UPWMessageBody

- (instancetype)initWithParams:(NSDictionary*)params
{

    self = [super init];
    if (self) {
        self.params = params;
    }
    return self;
}

@end


@implementation UPWMessage

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark -
#pragma mark - 初始化
+ (instancetype)sysInit
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"sys.init");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionary];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark -
#pragma mark - 版本检查
+ (instancetype)sysCheckversion:(NSString*)flag
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"sys.checkVersion");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionary];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark -
#pragma mark - 轮播图
+ (instancetype)messageWheelImageListWithParams:(NSDictionary *)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"fruit.wheelImageList");//commonPath(@"getWheelImages");//commonPath(@"fruit.wheelImageList");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark -
#pragma mark - 获取类别列表
+ (instancetype)messageCatagoryListWithParams:(NSDictionary *)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"fruit.catagoryList");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark -
#pragma mark - 获取鲜果、果切、果汁列表
+ (instancetype)messageFruitListWithParams:(NSDictionary *)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"fruit.fruitProList");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark -
#pragma mark - 获取购物车列表
+ (instancetype)messageShoppingCartListWithParams:(NSDictionary *)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"cart.shoppingCartList");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
    msg.body = wholeParams;
    return msg;
}

#pragma mark - 修改数量后，同步购物车数据
+ (instancetype)messageSyncShoppingCartListWithParams:(NSDictionary*)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"cart.uploadShoppingCartList");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark -
#pragma mark - 获取收货地址
+ (instancetype)messageDeliveryAddressWithParams:(NSDictionary *)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"user.deliveryAddressList");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark - 上送收货地址
+ (instancetype)messageUploadNewDeliveryAddrWithParams:(NSDictionary*)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"user.addDeliveryAddressList");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark -
#pragma mark - //用户信息查询
+ (instancetype)messageAccountInfoWithParams:(NSDictionary *)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"user.accountInfo");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark - 登录
+ (instancetype)messageLoginWithParams:(NSDictionary*)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"user.login");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark -
#pragma mark - 短信验证码
+ (instancetype)messageSmsWithParams:(NSDictionary*)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"sys.sms");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark - 注册
+ (instancetype)messageRegisterWithParams:(NSDictionary*)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"user.register");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark -
#pragma mark - 订单列表
+ (instancetype)messageOrderListWithParams:(NSDictionary *)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"order.orderList");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark - 退出登录
+ (instancetype)messageLogoutWithParams:(NSDictionary*)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"user.logout");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}

#pragma mark - 提交订单
+ (instancetype)messageCommitOrderWithParams:(NSDictionary*)params
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"order.commitOrder");
    NSMutableDictionary* wholeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    wholeParams[@"phoneInfo"] = phoneInfo();
//    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = wholeParams;
    return msg;
}


#pragma mark -
#pragma mark - 可能会用到的接口，借鉴
+ (instancetype)sysCheckkey
{
    //放入钱包时如果超时, 那么前一次的验证码肯定会错, 为了防止这样的情况发生, 在每一次后台回到前台, 检查上一次 sys.getKey 有没有超过半小时, 如果超过半小时, 发一个加密请求, 走401流程
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader encryptMsgHeader];
    msg.encrypt = YES;
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"sys.checkKey");
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    params[@"phoneInfo"] = phoneInfo();
    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = body;
    return msg;
    
}

+ (instancetype)sysGetkey
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader commonHeader];
    msg.httpMethod = KHTTP_METHOD_POST;
    msg.path = commonPath(@"sys.getKey");
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    NSString* encryptedTk = [UPWCryptUtil generateSessionKey];
    if (UP_IS_NIL(encryptedTk)) {
        return nil;
    }
    params[@"encryptedTk"] = encryptedTk;
    UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
    msg.body = body;
    return msg;
}

#pragma mark - 城市定位
+ (instancetype)regionLocatePosition:(NSString*)cityNm
{
    if (UP_IS_NIL(cityNm)) {
        return nil;
    }
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader chspHeader];
    msg.httpMethod = KHTTP_METHOD_GET;
    msg.path = commonPath(@"region.locateCity");
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    params[@"cityNm"] = cityNm;
    msg.params = params;
    return msg;
}

#pragma mark - GPS 纠偏
+ (instancetype)regionRelocatePosition:(NSString*)longitude latitude:(NSString*)latitude cityNm:(NSString*)cityNm
{
    if (UP_IS_NIL(longitude) || UP_IS_NIL(latitude) ) {
        return nil;
    }
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.header = [UPWMessageHeader chspHeader];
    msg.httpMethod = KHTTP_METHOD_GET;
    msg.path = commonPath(@"region.relocatePosition");
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    params[@"longitude"] = longitude;
    params[@"latitude"] = latitude;
    if (!UP_IS_NIL(cityNm)) {
        params[@"cityNm"] = cityNm;
    }
    msg.params = params;
    return msg;
}

#pragma mark -
#pragma mark 推送相关报文
+ (instancetype)uploadDeviceToken:(NSString *)deviceToken status:(BOOL)isOn {
    
    UPWMessage *message = [[UPWMessage alloc] init];
    message.header = [UPWMessageHeader commonHeader];
    message.httpMethod = KHTTP_METHOD_POST;
    message.path = commonPath(@"sys.deviceToken");
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    if(!UP_IS_NIL(deviceToken)) {
        params[@"deviceToken"] = deviceToken;
    }
    
    // op=0关闭  op=1打开
    params[@"op"] = (isOn ? @"1" : @"0");
    if([params count] >0) {
        UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
        message.body = body;
    }
    
    return message;
}

+ (instancetype)clearSystemMessage:(NSString *) deviceToken {
    
    UPWMessage *message = [[UPWMessage alloc] init];
    message.header = [UPWMessageHeader commonHeader];
    message.httpMethod = KHTTP_METHOD_POST;
    message.path = commonPath(@"sys.clearmsg");
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    
    if(!UP_IS_NIL(deviceToken)) {
        params[@"device_token"] = deviceToken;
    }
    
    if([params count] >0) {
        UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
        message.body = body;
    }
    
    return message;
    
}

#pragma mark - 通用Message请求接口, GET和POST都支持


#pragma mark - 普通票券下载
+ (instancetype)messageWithUrl:(NSString *)url params:(NSDictionary *)params encrypt:(BOOL)encrypt isPost:(BOOL)isPost hostType:(NSString *)hostType
{
    UPWMessage* msg = [[UPWMessage alloc] init];
    msg.encrypt = encrypt;
    msg.httpMethod = (isPost ? KHTTP_METHOD_POST : KHTTP_METHOD_GET);
    
    //hostType为1，往海洋前置发，默认往Top后台发
    if ([hostType isEqualToString:@"1"]) {
        if (encrypt) {
            msg.header = [UPWMessageHeader encryptMsgHeader];
        } else {
            msg.header = [UPWMessageHeader commonHeader];
        }
        if (isPost) {
            msg.path = commonPath(url);
            UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
            msg.body = body;
        }
        else {
            msg.params = params;
            msg.path = commonPath(url);
        }
    } else {
        if (encrypt) {
            msg.header = [UPWMessageHeader encryptChspMsgHeader];
        } else {
            msg.header = [UPWMessageHeader chspHeader];
        }
        
        if (isPost) {
            msg.path = commonPath(url);
            UPWMessageBody* body = [[UPWMessageBody alloc] initWithParams:params];
            msg.body = body;
        }
        else {
            msg.params = params;
            msg.path = commonPath(url);
        }
    }
    
    return msg;
}

@end
