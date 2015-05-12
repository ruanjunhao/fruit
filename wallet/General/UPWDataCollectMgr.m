//
//  UPWDataCollectMgr.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWDataCollectMgr.h"
#import "TalkingData.h"

#ifdef UP_BUILD_FOR_DEVELOP
#define kTrackAppID @"426C5A620172F83B7F034505114E348C"
#endif

#ifdef UP_BUILD_FOR_TEST
#define kTrackAppID @"426C5A620172F83B7F034505114E348C"
#endif

#ifdef UP_BUILD_FOR_RELEASE
#define kTrackAppID @"CD19BA123952FEA59808596332E3CF5B"
#endif


@implementation UPWDataCollectMgr

#pragma mark 点采集方法



+ (void)startTrack
{
    //收集数据以及错误日志
    [TalkingData setExceptionReportEnabled:YES];
    
    [TalkingData sessionStarted:kTrackAppID withChannelId:@"00001"];
    [TalkingData openDebugLog:NO];
}


//页面打开
+ (void)upTrackPageBegin:(NSString *)pageName
{
    UPDINFO(@"##UpTrackPageBegin-pageName = %@",pageName);
    [TalkingData trackPageBegin:pageName];
}

//页面关闭
+ (void)upTrackPageEnd:(NSString *)pageName
{
    UPDINFO(@"##UpTrackPageEnd-pageName = %@",pageName);
    [TalkingData trackPageEnd:pageName];
}

//为事件添加详尽的描述信息,可以更有效的对事件触发的条件和场景做分析。 您可以使用 NSDictionary 对象上传事件参数,key 类型必须是 NSString, value 可以是 NSString 戒者 NSNumber,一次事件最多只支持 10 个参数
+ (void)upTrackEvent:(NSString *)event_id label:(NSString *)label parameters:(NSDictionary *)dictionary
{
    UPDINFO(@"##UpTrackEvent-event_id=%@-label=%@-parameters=%@",event_id,label,dictionary);
    [TalkingData trackEvent:event_id label:label parameters:dictionary];
}

//跟踪多个同类型事件,无需定义多个EventID,可以使用EventID做为目录 名,而使用 Label 标签来区分这些事件
+ (void)upTrackEvent:(NSString *)event_id label:(NSString *)label
{
    UPDINFO(@"##UpTrackEvent-event_id=%@-label=%@",event_id,label);
    [TalkingData trackEvent:event_id label:label];
}

//在应用程序要跟踪的事件处加入下面格式的代码
+ (void)upTrackEvent:(NSString *)event_id
{
    UPDINFO(@"##UpTrackEvent-event_id=%@",event_id);
    [TalkingData trackEvent:event_id];
}
+ (void)upTrackSetLatitude:(double)latitude longitude:(double)longitude
{
    UPDINFO(@"##UpTrackLatitude=%f-longitude=%f",latitude,longitude);
    [TalkingData setLatitude:latitude longitude:longitude];
}









@end
