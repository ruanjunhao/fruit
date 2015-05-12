//
//  UPXPathUtils.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-5-22.
//
//

#import <Foundation/Foundation.h>

@interface UPWPathUtil : NSObject


+ (NSString*)documentDirectory;

+ (void)createDirectoryIfNotExist:(NSString *)fullPath;

+ (NSString*)localizedPlistPath;

+ (NSString*)publicPayPlistPath;

//同步提醒日
+ (NSString*)syncRemindDaysPlistPath;
//同步历史账单
+ (NSString*)syncBillHistoryPlistPath;

//用户消息，营销消息
+ (NSString*)userMessagePlistPath;

//用户信息
+ (NSString*)userInfoPlistPath;

//上传信息
+ (NSString*)uploadInfoPlistPath;

//全App info文件
+ (NSString*)allAppInfoPlistPath;

//设置过手势密码用户的随机字符串
+ (NSString*)userPatternRandomStringPlistPath;

//系统初始化
+ (NSString*)sysInitCachePath;

//城市列表
+ (NSString*)cityListCachePath;

//KV 图, 热门 app, 秒杀图
+ (NSString*)imgHotSecKillCachePath;

//精选推荐
+ (NSString*)hotBillListCachePath;

//生活 KV 图
+ (NSString*)lifeImageListCachePath;

//卡包演示卡数据
+ (NSString*)demoCardListPath;

//全部用户的目录
+ (NSString*)allUserDirectoryPath;

//用户的目录
+ (NSString*)userDirectoryPath:(NSString*)userID;

//已绑定卡数据, 用在信用卡还款中
+ (NSString*)cardListCachePath:(NSString*)userID;

//卡片详情格式
+ (NSString*)cardDetailFormatPath;

//添加银行卡证件类型
+ (NSString*)certTypePlistPath;

//默认城市
+ (NSString*)defaultCityPlistPath;

//默认appInfo
+ (NSString*)defaultAppInfoPlistPath;

//显示在生活的 app
+ (NSString*)appInfoPlistPath;

// 根据folder拼网络图片URL
+ (NSURL*)urlWithFolder:(NSString*)folder withURL:(NSString*)org;

//彩虹果
//轮播图
+ (NSString *)wheelImageListPlistPath;
+ (NSString *)catagoryListPlistPath;
+ (NSString *)freshFruitListPlistPath;
+ (NSString *)fruitCutListPlistPath;
+ (NSString *)fruitJuiceListPlistPath;
+ (NSString*)accountInfoPlistPath;
+ (NSString*)shoppingCartPlistPath;
+ (NSString*)deliveryAddrPlistPath;

@end
