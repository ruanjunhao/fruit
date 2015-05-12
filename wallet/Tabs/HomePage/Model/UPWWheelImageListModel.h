//
//  UPWWheelImageListModel.h
//  wallet
//
//  Created by gcwang on 15/3/9.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "JSONModel.h"

@class UPWFruitListCellModel;

@protocol UPWWheelImageModel


@end


@interface UPWWheelImageModel : JSONModel

@property (nonatomic, strong) NSString <Optional> *imageUrl;//轮播图图片地址
@property (nonatomic, copy) NSString<Optional>* detailUrl;//轮播图详情地址
@property (nonatomic, copy) NSString<Optional>* title;
@property (nonatomic, copy) NSString<Optional>* subtitle;
@property (nonatomic, copy) NSString<Optional>* type;//参数：product, page
@property (nonatomic, strong) UPWFruitListCellModel<Optional> *product;//如果是产品，此model包含如下信息


@end

@interface UPWWheelImageListModel : JSONModel

@property (nonatomic, strong) NSArray <UPWWheelImageModel, Optional> *data;

@end
