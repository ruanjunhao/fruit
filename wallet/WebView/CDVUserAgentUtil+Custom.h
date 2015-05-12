//
//  CDVUserAgentUtil+Custom.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "CDVUserAgentUtil.h"

@interface CDVUserAgentUtil (Custom)

//修改user agent, 因为cordova的originalUserAgent会从文件读取, 有旧版本兼容性的风险, 也不想修改cordova源代码, 所以在这里直接用hack的方法更换掉CDVUserAgentUtil originalUserAgent方法
+ (NSString*)walletUserAgent;

@end
