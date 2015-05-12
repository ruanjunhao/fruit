//
//  UPLocationService.h
//  UPWallet
//
//  Created by wxzhao on 14-6-16.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Pay Attention:
    UPWLocationService的设计基于单一原则，它提供的两种服务updatingLocation与updatingCity用户在使用中选其一，不要两者混用。定位服务基于MAMapView，是单例。
 */

typedef void(^lbs_success_block_t)(NSString* longitude, NSString* latitude, NSDictionary* city);
typedef void(^lbs_fail_block_t)(NSError* err);

#ifndef kLocationServiceBusyErrorCode
#define kLocationServiceBusyErrorCode -7777
#endif

@interface UPWLocationService : NSObject

// 有些定位请求是不需要返回City Name的，比如打开票券详情页面获取用户位置时
@property(nonatomic) BOOL retCityNm; // default is yes.

// 看设置中用户是否允许APP访问用户当前位置。
+ (BOOL)isLocationServiceEnable;

/*
请关注如下方法的返回值，因为我们这个类的设计采用单一原则，所以当前面的定位请求还没有返回时，我们会拒绝掉后续的定位请求，返回NO,并且执行相应的调用block, error代码是kLocationServiceBusyErrorCode。
 */

// 定位用户当前位置。
- (BOOL)updatingLocationWithSuccess:(lbs_success_block_t)successBlock fail:(lbs_fail_block_t)failBlock;

// 定位用户当前所在的城市。
- (BOOL)updatingCityWithSuccess:(lbs_success_block_t)successBlock fail:(lbs_fail_block_t)failBlock;

// 停止所有定位用户相关的操作。
- (void)stopUpdatingLocation;

@end
