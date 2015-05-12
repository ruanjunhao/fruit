//
//  UPWebBridge.h
//  UPWallet
//
//  Created by jhyu on 14-7-17.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef kStartPage
#define kStartPage  @"kStartPage"
#endif

#ifndef kMchntDetailUrl
#define kMchntDetailUrl @"hybrid_v3/html/mchnt/detail.html"
#endif

#define kUPWWebData @"kUPWWebData"


typedef NS_OPTIONS(NSInteger, ELaunchType) {
    ELaunchTypeNone = -1,
    ELaunchTypeLocalCoupon, // 本地页面启动详情页面
    ELaunchTypeLocalMerchant, // 从我的收藏页面启动商户详情页面
    ELaunchTypeLocalActivityList, // 活动列表页面
    ELaunchTypeLocalSecKill, // 本地启动超值优惠页面
    ELaunchTypeFeatureList, // 本地启动功能列表页面
    ELaunchTypePluginNewPageOpen, // WEB插件启动新页面
    ELaunchTypeUniversalWebDriven // WEB端优化设计，页面所有信息（包括标题栏）都是WEB端Driven.
};

typedef NS_OPTIONS(NSInteger, ERightBtn) {
    ERightBtnNone = 0x0,
    ERightBtnMap = 0x2,
    ERightBtnShare = 0x4,
    ERightBtnRating = 0x8,
    ERightBtnFavorite = 0x10,
    ERightBtnBill = 0x20  // 账单项目所用
};

// JS side define: 0:优惠券,1:电子票,2:积分商户,3:活动, 4:积分券，5:商户详情
typedef NS_OPTIONS(NSInteger, EShareType) {
    EShareTypeNone = -1,
    EShareTypeCoupon,
    EShareTypeETicket,
    EShareTypePointDeduction,
    EShareTypeActivity,
    EShareTypeRebate,
    EShareTypeMerchant,
    EShareTypeUniversalWebDriven, // 配合ELaunchTypeUniversalWebDriven，获取JS时，无需传票券类型。
    EShareTypeApp
};

@interface UPWWebData : NSObject
// 所有的内容由内部逻辑创建
@property (nonatomic, readonly) NSString* startPage;
@property (nonatomic, readonly) NSString* navigationBarTitle;
@property (nonatomic, readonly) ERightBtn eRightBtn;
@property (nonatomic, readonly) EShareType eShareType;

@property (nonatomic, readonly) ELaunchType eLaunchType;

/*! @brief 常规票券页面打开。
 *
 * @param launchType 打开页面类型。
 * @param poiData 页面参数，两种数据类型支持，NSDictionary和JSONModel
 * @return UPWWebData实例。
 */
- (id)initWithLaunchType:(ELaunchType)launchType poiData:(id)poiData;

// 为热门推荐等功能服务
- (id)initWithBrandId:(NSString *)brandId billId:(NSString *)billId billType:(NSString *)billType updTime:(NSString *)updTime;

// 为更多里面页面服务
- (id)initWithStartPage:(NSString *)startPage title:(NSString *)title rightBtn:(ERightBtn)eRightBtn shareType:(EShareType)eShareType;

/*! @brief 从第三方APP打开票券详情页面用如下接口。
 *
 * @param url 第三方页面启动URL
 * @return UPWWebData实例。
 */
- (id)initWith3rdPatyAppLunchUrl:(NSURL *)url;

@end


