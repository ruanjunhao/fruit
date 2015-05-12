//
//  UPWLog.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//


#import "DDLog.h"

#ifdef UP_ENABLE_LOG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_OFF;
#endif

#define UPDERROR(xx, ...)  DDLogError(xx, ##__VA_ARGS__)

#define UPDWARNING(xx, ...)  DDLogWarn(xx, ##__VA_ARGS__)

#define UPDNETMSG(xx, ...)   DDLogInfo(xx, ##__VA_ARGS__)

#define UPDINFO(xx, ...)   DDLogDebug(xx, ##__VA_ARGS__)

#define UPDVerbose(xx, ...)   DDLogVerbose(xx, ##__VA_ARGS__)

#define UPDSTART()  DDLogVerbose(@"<<< %s",__PRETTY_FUNCTION__);

#define UPDEND()   DDLogVerbose(@">>> %s",__PRETTY_FUNCTION__);

