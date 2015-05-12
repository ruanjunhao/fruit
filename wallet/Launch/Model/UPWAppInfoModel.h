//
//  UPWAppInfoModel.h
//  wallet
//
//  Created by qcao on 14/11/4.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "JSONModel.h"

@interface UPWAppInfoModel : JSONModel

@property (nonatomic, copy) NSString<Optional>* appId;
@property (nonatomic, copy) NSString<Optional>* version;
@property (nonatomic, copy) NSString<Optional>* name;
@property (nonatomic, copy) NSString<Optional>* config;
@property (nonatomic, copy) NSString<Optional>* iconUrl;
@property (nonatomic, copy) NSString<Optional>* type;
@property (nonatomic, copy) NSString<Optional>* dest;
@property (nonatomic, copy) NSString<Optional>* classification;
@property (nonatomic, copy) NSString<Optional>* perm;
@property (nonatomic, copy) NSString<Optional>* badgeUrl;
@property (nonatomic, copy) NSString<Optional>* badgeInfo;
@property (nonatomic, copy) NSString<Optional>* display;
@property (nonatomic, copy) NSString<Optional>* destParams;
@property (nonatomic, copy) NSString<Optional>* seq;


//@property (nonatomic, copy) NSString<Optional>* status;
//@property (nonatomic, copy) NSString<Optional>* bgColor;
//@property (nonatomic, copy) NSString<Optional>* osSupport;
//@property (nonatomic, copy) NSString<Optional>* iosVersion;
//@property (nonatomic, copy) NSString<Optional>* androidVersion;
//@property (nonatomic, copy) NSString<Optional>* maxIosVersion;
//@property (nonatomic, copy) NSString<Optional>* maxAndroidVersion;

- (BOOL)isThirdPartyApp;

#pragma mark - 应用是否默认应用

- (BOOL)isDefaultApp;

#pragma mark - 应用是否支持添加提醒日

- (BOOL)isSupportRemind;

#pragma mark - 应用是否热门

- (BOOL)isHotApp;

#pragma mark - 应用是否可删除

- (BOOL)isAppUnable4Delete;

#pragma mark - 应用能否显示

- (BOOL)shouldAppDisplay;

@end
