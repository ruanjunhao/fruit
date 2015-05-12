//
//  UPWEnv.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#define kEnvDebug               @"debug"
#define kEnvTest                @"test"
#define kEnvPM                  @"pm"
#define kEnvProduct             @"product"
#define kEnvLocalWebDebug       @"localwebdebug"


#define kDebugAppUrl             @"http://101.231.114.217:8080/wallet/entry"
#define kDebugChspUrl @"http://172.17.248.33/wm-non-biz-web/v3"
#define kDebugChspImgUrl @"http://172.17.248.33"
#define kDebugGWJUrl @"http://120.204.69.168:1725/gwj"
#define kDebugPayPluginMode @"99"
#define kDebugTrackAppID @"9F80A5B9AE3816A6BCDA328B07648291"
#define kDebugUserAgentMode @"1"
#define kDebugCryptKey  @"18339517381827265589924728533530791541674643687500503344721874186609928362517014722973967303151827715043782042466947087865194401832757701016104883823897027828953449366207604025813090131703076984870991175766173974905587809645192009508901646318002302618083900727214673483516690000820211832760444973449926299789120899202804098591224226086247861612535531805572322268080615594684048283257614597787790957946872011823256136953139094716026094695746836047165485008327716161939923159581677221327606278261430875465662650876721559291872211463330899202377757406164311536265621835011235136282491700283466817468600502686393744683489"

// 上信PM
#define kPMAppUrl @"http://101.231.114.217:8080/app3/json"
#define kPMChspUrl @"http://wallet.95516.net:80/wm-non-biz-web/restlet"
#define kPMChspImgUrl @"http://wallet.95516.net"
#define kPMGWJUrl @"http://120.204.69.168:1725/gwj"
#define kPMPayPluginMode @"01"
#define kPMTrackAppID @"9F80A5B9AE3816A6BCDA328B07648291"
#define kPMUserAgentMode @"998"
#define kPMCryptKey  kDebugCryptKey

// 测试室
#define kTestAppUrl @"http://101.231.114.224:8900/wallet"
#define kTestChspUrl @"http://101.231.114.226/wm-non-biz-web/v3"
#define kTestChspImgUrl @"http://172.17.248.176:80"
#define kTestGWJUrl @"http://101.231.114.224:8010/gwj"
#define kTestPayPluginMode @"02"
#define kTestTrackAppID @"9F80A5B9AE3816A6BCDA328B07648291"
#define kTestUserAgentMode @"2"
#define kTestCryptKey   @"18339517381827265589924728533530791541674643687500503344721874186609928362517014722973967303151827715043782042466947087865194401832757701016104883823897027828953449366207604025813090131703076984870991175766173974905587809645192009508901646318002302618083900727214673483516690000820211832760444973449926299789120899202804098591224226086247861612535531805572322268080615594684048283257614597787790957946872011823256136953139094716026094695746836047165485008327716161939923159581677221327606278261430875465662650876721559291872211463330899202377757406164311536265621835011235136282491700283466817468600502686393744683489"

// 生产
#define kProductAppUrl @"https://mgate.unionpay.com/wl/entrya"
#define kProductChspUrl @"http://120.55.100.68:8080/transfer/ios"
#define kProductChspImgUrl @"https://youhui.95516.com"
#define kProductGWJUrl @"https://mgate.unionpay.com/gateway/jiaofeia"
#define kProductPayPluginMode @"00"
#define kProductTrackAppID @"E3758453A490355CB2D4D3D208D7024D"
#define kProductUserAgentMode @"0"
#define kProductCryptKey @"18339517381827265589924728533530791541674643687500503344721874186609928362517014722973967303151827715043782042466947087865194401832757701016104883823897027828953449366207604025813090131703076984870991175766173974905587809645192009508901646318002302618083900727214673483516690000820211832760444973449926299789120899202804098591224226086247861612535531805572322268080615594684048283257614597787790957946872011823256136953139094716026094695746836047165485008327716161939923159581677221327606278261430875465662650876721559291872211463330899202377757406164311536265621835011235136282491700283466817468600502686393744683489"

//本地 web 调试
#define kLocalWebDebugAppUrl kDebugAppUrl
#define kLocalWebDebugChspUrl kDebugChspUrl
#define kLocalWebDebugChspImgUrl kDebugChspImgUrl
#define kLocalWebDebugGWJUrl kDebugGWJUrl
#define kLocalWebDebugPayPluginMode kDebugPayPluginMode
#define kLocalWebDebugTrackAppID kDebugTrackAppID
#define kLocalWebDebugUserAgentMode @"999" //非PM环境999，PM环境998
#define kLocalWebCryptKey kDebugCryptKey


//编译脚本设置当前的环境
#ifdef UP_BUILD_FOR_DEVELOP
#define kWalletEnv kEnvDebug
#endif

#ifdef UP_BUILD_FOR_TEST
#define kWalletEnv kEnvTest
#endif

#ifdef UP_BUILD_FOR_RELEASE
#define kWalletEnv kEnvProduct
#endif

#ifdef UP_PM_ENV
#define kWalletEnv kEnvPM
#endif

#ifdef UP_WEB_APP_LOCAL_URL
#define kWalletEnv kEnvLocalWebDebug
#endif

