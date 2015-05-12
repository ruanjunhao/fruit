//
//  UPWUpdateInfoModel.h
//  wallet
//
//  Created by qcao on 14/11/4.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "JSONModel.h"

@interface UPWUpdateInfoModel : JSONModel

@property (nonatomic, copy) NSString<Optional>* desc;
@property (nonatomic, copy) NSString<Optional>* updateUrl;
@property (nonatomic, copy) NSString<Optional>* needUpdate;

@end
