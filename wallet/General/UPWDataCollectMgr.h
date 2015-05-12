//
//  UPWDataCollectMgr.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPWDataCollectMgr : NSObject

//开启收集
+ (void)startTrack;

//页面打开
+ (void)upTrackPageBegin:(NSString *)pageName;

//页面关闭
+ (void)upTrackPageEnd:(NSString *)pageName;

//为事件添加详尽的描述信息,可以更有效的对事件触发的条件和场景做分析。 您可以使用 NSDictionary 对象上传事件参数,key 类型必须是 NSString, value 可以是 NSString 戒者 NSNumber,一次事件最多只支持 10 个参数
+ (void)upTrackEvent:(NSString *)event_id label:(NSString *)label parameters:(NSDictionary *)dictionary;

//跟踪多个同类型事件,无需定义多个EventID,可以使用EventID做为目录 名,而使用 Label 标签来区分这些事件
+ (void)upTrackEvent:(NSString *)event_id label:(NSString *)label;

//在应用程序要跟踪的事件处加入下面格式的代码
+ (void)upTrackEvent:(NSString *)event_id;

//手机 GPS 坐标信息
+ (void)upTrackSetLatitude:(double)latitude longitude:(double)longitude;

@end
