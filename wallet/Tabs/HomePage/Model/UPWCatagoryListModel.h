//
//  UPWCatagoryListModel.h
//  wallet
//
//  Created by gcwang on 15/3/9.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "JSONModel.h"

@class UPWFruitListCellModel;

@protocol UPWCatagoryCellModel


@end

@interface UPWCatagoryCellModel : JSONModel

@property (nonatomic, strong) NSString <Optional> *title;//名字
@property (nonatomic, strong) NSString <Optional> *imageUrl;//
@property (nonatomic, strong) NSString <Optional> *detailUrl;
@property (nonatomic, strong) NSString <Optional> *localImageName;//图片名字
@property (nonatomic, copy) NSString<Optional>* subtitle;
@property (nonatomic, copy) NSString<Optional>* type;//参数：product, page
@property (nonatomic, strong) UPWFruitListCellModel<Optional> *product;//如果是产品，此model包含如下信息

@end

@interface UPWCatagoryListModel : JSONModel

@property (nonatomic, strong) NSArray <UPWCatagoryCellModel, Optional> *data;

@end
