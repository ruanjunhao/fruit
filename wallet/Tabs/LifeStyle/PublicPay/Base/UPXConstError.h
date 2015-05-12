//
//  UPXConstError.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-6-5.
//
//

/*
 用来保存网络连接错误码
 
 */
/* 网络正常返回00 */
#define kNetRespOkValue @"00"
/* 用户名密码验证失败 */
#define kNetRespUserPasswordWrong @"30"
/* 图片验证码不能为空 */
#define kNetRespEmptyVerify @"32"
/* 验证码输入错误 */
#define kNetRespInvalidVerify @"33"
/* 该用户在其他终端登录，被踢出 */
#define kNetRespUserKickedOut @"90"
/* 密码尝试次数超过限制 */
#define kNetRespPasswordAttemptsExceedsTheLimit @"98"
/* session 失效,登录超时 */
#define kNetRespSessionTimeOut @"99"
/* 没有优惠信息错误 */
#define kHaveNoPromotions 64

/* 网络SSL认证错误, 证书失效, 或者时间错误 */
#define kNetSSLError  1
/* 网络超时 */
#define kNetTimeOut  2
/* 服务器报文错误 */
#define kNetWrongResp -9999

#define kNetWrongRespError [NSError errorWithDomain:@"UPClient" code:kNetWrongResp userInfo:nil]

