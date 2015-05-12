//
//  CDVUserAgentUtil+Custom.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "CDVUserAgentUtil+Custom.h"
#import "CDVAvailability.h"
#import "UPWConst.h"
#import "UPWEnvMgr.h"
#import "UPWAppUtil.h"

@implementation CDVUserAgentUtil (Custom)

+ (NSString*)walletUserAgent
{
    NSString* originalUserAgent = [self walletUserAgent];
    NSString* exUserAgent = [NSString stringWithFormat:@" (%@) (cordova %@) (updebug %@) (version %@)",[[NSBundle mainBundle] bundleIdentifier],CDV_VERSION,[UPWEnvMgr userAgentMode],[UPWAppUtil formatAppVersion]];
    return [originalUserAgent stringByAppendingString:exUserAgent];
}

@end
