//
//  UPWMyOrderModel.h
//  wallet
//
//  Created by gcwang on 15/3/24.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "JSONModel.h"
#import "UPWShoppingCartModel.h"

@protocol UPWMyOrderCellModel <NSObject>

@end

@interface UPWMyOrderCellModel : JSONModel

@property (nonatomic, strong) NSString<Optional> *orderId;
@property (nonatomic, strong) NSString<Optional> *orderStatus;
@property (nonatomic, strong) NSArray<Optional> *imageUrlList;
@property (nonatomic, strong) NSArray<Optional, UPWShoppingCartCellModel> *orderList;

@end

@interface UPWMyOrderModel : JSONModel

@property (nonatomic, strong) NSMutableArray<Optional, UPWMyOrderCellModel> *data;
@property (nonatomic, strong) NSString<Optional> *hasMore;
@property (nonatomic, strong) NSString<Optional> *noFreightCondition;//满足免运费条件

@end
