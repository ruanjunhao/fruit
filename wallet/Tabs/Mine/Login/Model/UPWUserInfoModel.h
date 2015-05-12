//
//  UPWUserInfoModel.h
//  wallet
//
//  Created by qcao on 14/10/31.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "JSONModel.h"

@interface UPWUserInfoModel : JSONModel

@property (nonatomic, copy) NSString<Optional>* question1;
@property (nonatomic, copy) NSString<Optional>* securityInfo;
@property (nonatomic, copy) NSString<Optional>* userId;
@property (nonatomic, copy) NSString<Optional>* userIdC;
@property (nonatomic, copy) NSString<Optional>* username;
@property (nonatomic, copy) NSString<Optional>* email;
@property (nonatomic, copy) NSString<Optional>* mobilePhone; //String	M	手机


@end


@interface UPWBigUserInfoModel : JSONModel

@property (nonatomic, copy) NSString<Optional>* couponNum;
@property (nonatomic, copy) NSString<Optional>* distance;
@property (nonatomic, copy) NSString<Optional>* encryptCdhdUsrId;
@property (nonatomic, copy) NSString<Optional>* favoriteNum;
@property (nonatomic, copy) NSString<Optional>* messageNum;

@property (nonatomic, copy) NSString<Optional>* orderCount;
@property (nonatomic, copy) NSString<Optional>* pointAt;
@property (nonatomic, copy) NSString<Optional>* promotionMsgCount;
@property (nonatomic, copy) NSString<Optional>* remindDayNum;

//登录和userGet的时候，现在会返supDownloadBill字段，1表示支持，0表示不支持；
//如果不支持，下载票券时，需要补充手机号，发送user.upgradeMobile命令
//请求字段只有一个 contactMobile
@property (nonatomic, copy) NSString<Optional>* supDownloadBill;



@property (nonatomic, copy) UPWUserInfoModel<Optional>* userInfo;

@end





