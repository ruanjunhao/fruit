//
//  UPWFeatureAppModel.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-10-10.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "JSONModel.h"

@protocol UPWFeaturedAppModel

@end


@interface UPWWebAppModel : JSONModel
@property (nonatomic, copy) NSString<Optional>* config;
@property (nonatomic, copy) NSString<Optional>* title;
@property (nonatomic, copy) NSString<Optional>* url;

@end


@interface UPWFeaturedAppModel : JSONModel

@property (nonatomic, copy) NSString<Optional>* imageUrl;
@property (nonatomic, copy) NSString<Optional>* appId;
@property (nonatomic, strong) UPWWebAppModel<Optional>* web;

@end


@interface UPWImgHotSecKillModel : JSONModel


@property (nonatomic, copy) NSArray<UPWFeaturedAppModel,Optional>* imageList;
@property (nonatomic, copy) NSArray<UPWFeaturedAppModel,Optional>* hotApps;
@property (nonatomic, copy) NSString<Optional>* seckillImageUrl;


@end