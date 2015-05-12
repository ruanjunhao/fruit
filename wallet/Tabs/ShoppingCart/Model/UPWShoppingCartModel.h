//
//  UPWShoppingCartModel.h
//  wallet
//
//  Created by gcwang on 15/3/14.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "JSONModel.h"

@protocol UPWShoppingCartCellModel <NSObject>

@end

@interface UPWShoppingCartCellModel : JSONModel

@property (nonatomic, strong) NSString<Optional> *fruitName;//商品名字
@property (nonatomic, strong) NSString<Optional>* fruitDesc;//商品描述
@property (nonatomic, strong) NSString<Optional>* fruitId;//商品ID
@property (nonatomic, strong) NSString<Optional> *fruitPrice;
@property (nonatomic, strong) NSString<Optional> *fruitPriceUnit;//价格单位：盒，个，公斤
@property (nonatomic, strong) NSString<Optional>* imageUrl;//商品图片地址
@property (nonatomic, strong) NSString<Optional>* fruitType;//商品类型
@property (nonatomic, strong) NSString<Optional>* fruitNum;//商品数量
@property (nonatomic, strong) NSString<Optional>* checked;//是否选中
//@property (nonatomic, strong) NSString<Optional>* detailUrl;//商品详情地址

@end

@interface UPWShoppingCartModel : JSONModel

@property (nonatomic, strong) NSMutableArray<UPWShoppingCartCellModel, Optional> *data;
@property (nonatomic, strong) NSString<Optional> *hasMore;
@property (nonatomic, strong) NSString<Optional> *noFreightCondition;//满足免运费条件

@end
