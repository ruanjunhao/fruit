//
//  ShareMgr.h
//  ShareMgr
//
//  Created by jhyu on 14-6-18.
//  Copyright (c) 2014年 UP. All rights reserved.
//

#import <Foundation/Foundation.h>


//#define ErrorNo

typedef NS_OPTIONS(NSUInteger, EShareError) {
    EErrorNotSupport = 1,
    EErrorParamError
};

/*! @brief ShareMgrDataSource 分享预填内容数据结构
 */
@interface UPShareContent : NSObject
@property (nonatomic, copy) NSString*   title;
@property (nonatomic, copy) NSString*   body;
@property (nonatomic)       UIImage*    image;
@property (nonatomic, copy) NSString*   webUrl;
@end

@protocol ShareMgrDataSource;
@protocol ShareMgrDelegate;

@interface ShareMgr : NSObject

/** 错误码 */
@property (nonatomic, assign) int errCode;

@property (nonatomic, weak) id<ShareMgrDelegate> delegate;

+ (instancetype)instance;

// 看是否能够打开相应分享方式。

// 微信好友
- (BOOL)canOpenWeixinWithAppKey:(NSString *)key;

// 微信朋友圈
- (BOOL)canOpenWeixinGroupWithAppKey:(NSString *)key;

// 新浪微博
- (BOOL)canOpenSinaWeiboWithAppKey:(NSString *)key;

// 短信
- (BOOL)canOpenSms;

// 分享事件响应

// 微信好友
- (BOOL)openWeixinWithAppKey:(NSString *)key content:(UPShareContent *)content;

// 微信朋友圈
- (BOOL)openWeixinGroupWithAppKey:(NSString *)key content:(UPShareContent *)content;

// 新浪微博
- (BOOL)openSinaWeiboWithAppKey:(NSString *)key content:(UPShareContent *)content topVC:(UIViewController *)topVC;

// 短信
- (BOOL)openSmsWithContent:(UPShareContent *)content topVC:(UIViewController *)topVC;

/*! @brief 用于APP回调。
 *
 * @param mask 分享类型，用|连接。
 * @param url 回调URL
 * @return 可分享集合，每个元素为字典。
 */
- (BOOL)appDelegateOpenURL:(NSURL *)url;

@end


/*! @brief 分享返回状态
 *
 * 应用场景：分享事件执行后，可能需要通知上层APP执行结果。
 */
typedef NS_OPTIONS(NSUInteger, EShareResult) {
    EShareUndefined,
    EShareSuccess,
    EShareFailed,
    EShareCancelled
};

extern NSString* const kNotificationShareResult;
extern NSString* const kResultCode;

