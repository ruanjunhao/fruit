//
//  UPWConst.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#define kUPWWalletClientVersion @"15"

#define kMessageOSName @"ios"

//定义错误信息
#define kErrorInvalidMsgCode            9990
#define kErrorGetKeyCode                9991  //sys.getKey失败造成的加密消息发送失败
#define kErrorLocationNoCityNameCode    9992  //定位成功, 但是没有 cityName
#define kErrorEmptyData                 9993    //服务器返回空数据
#define kErrorInvalidMsg                UP_STR(@"String_Msg_Internal_Error")
#define kErrorResendMsg                 UP_STR(@"String_Msg_Resend_Error")//sys.getKey失败造成的加密消息发送失败
#define kErrorNetworkMsg                UP_STR(@"String_Network_Error")
#define kErrorJSONFormat                UP_STR(@"String_JSON_Error")
#define kErrorLocationNoCityName        UP_STR(@"String_Location_No_City_Name")

/* 定义导航栏和Application的高宽 */
#define  kNavigationBarHeight               44
#define  kStatusBarHeight                   20
#define  kTabBarHeight                      49
#define  kWebViewToolBarHeight              44

#define  kScreenWidth             ([UIScreen mainScreen].bounds.size.width)
#define  kScreenHeight            ([UIScreen mainScreen].bounds.size.height - kStatusBarHeight)

//Tab 优惠
#define KSTR_FILTER_PREDICATE       @"(upIndex == %ld) && (upColumn == %ld)"

//字体大小
#define  kConstantFont10             10
#define  kConstantFont11             11
#define  kConstantFont12             12
#define  kConstantFont13             13
#define  kConstantFont14             14
#define  kConstantFont15             15
#define  kConstantFont16             16
#define  kConstantFont20             20
#define  kConstantFont27             27
#define  kConstantFont30             30

//定义UserDefault Key，后面数字代表UD版本号
#define kUDKeyCommunity @"kUDKeyCommunity_0"

//

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
#define kCGImageAlphaNoneSkipLast  (kCGBitmapByteOrderDefault | kCGImageAlphaNoneSkipLast)
#else
#define kCGImageAlphaNoneSkipLast  kCGImageAlphaNoneSkipLast
#endif

#pragma mark -
#pragma mark 信息上传
#define kUploadInfoAppDownload @"AppDownload"

#define kMessagePageReqStartIndex 1
