//
//  UPWDebug.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//


//使用内部测试服务器 ,还需要修改本地化字符串，每次从default拷贝
//#define UP_BUILD_FOR_DEVELOP

//使用测试室服务器, 表示不再修改字符串，只拷贝第一次
//#define UP_BUILD_FOR_TEST

//使用生产服务器, 表示不再修改字符串，只拷贝第一次
#define UP_BUILD_FOR_RELEASE

//web app本地测试地址
//#define UP_WEB_APP_LOCAL_URL

//打印LOG总开关
#define UP_ENABLE_LOG

//商户模式 连接PM环境
//#define UP_PM_ENV



#if !defined UP_BUILD_FOR_DEVELOP && !defined UP_BUILD_FOR_TEST && !defined UP_BUILD_FOR_RELEASE
#define UP_BUILD_FOR_DEVELOP
#endif
