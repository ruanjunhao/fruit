//
//  UPWDeliveryAddressModel.h
//  wallet
//
//  Created by gcwang on 15/3/16.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "JSONModel.h"

@protocol UPWDeliveryAddressCellModel <NSObject>

@end

@interface UPWAddrInfoModel : JSONModel

@property (nonatomic, strong) NSString<Optional> *province;
@property (nonatomic, strong) NSString<Optional>* city;
@property (nonatomic, strong) NSString<Optional>* region;
@property (nonatomic, strong) NSString<Optional> *detailAddr;

@end

@interface UPWDeliveryAddressCellModel : JSONModel

@property (nonatomic, strong) NSString<Optional> *userName;
@property (nonatomic, strong) NSString<Optional>* phoneNum;
@property (nonatomic, strong) UPWAddrInfoModel<Optional>* addrInfo;

@end

@interface UPWDeliveryAddressModel : JSONModel

@property (nonatomic, strong) NSMutableArray<UPWDeliveryAddressCellModel, Optional> *data;
@property (nonatomic, strong) NSString<Optional> *hasMore;

@end
