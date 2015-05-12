//
//  UPWAccountInfoModel.h
//  wallet
//
//  Created by gcwang on 15/3/18.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "JSONModel.h"

@interface UPWAccountInfoModel : JSONModel

@property (nonatomic, strong) NSString<Optional> *userId;
@property (nonatomic, strong) NSString<Optional> *nickname;
@property (nonatomic, strong) NSString<Optional> *phoneNum;
@property (nonatomic, strong) NSString<Optional> *headImageUrl;
@property (nonatomic, strong) NSString<Optional> *token;
//本地
@property (nonatomic, strong) NSString<Optional> *localImageName;

//备用
@property (nonatomic, strong) NSArray<Optional> *consignees;// 收货地址，数组
@property (nonatomic, strong) NSString<Optional> *consigneeCompleted;// 是否拥有收货地址，false
@property (nonatomic, strong) NSString<Optional> *payType;// 默认支付方式，cash

@end
