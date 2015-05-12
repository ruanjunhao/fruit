//
//  UPWBaseMapViewMgr.h
//  wallet
//
//  Created by jhyu on 14/12/31.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>

@interface UPWBaseMapViewMgr : NSObject

@property (nonatomic, readonly) MAMapView* mapViewForGaode;

// 用于地图显示的商家数组。
@property (nonatomic, copy) NSArray * pois;  // 商家数组
@property (nonatomic) BOOL isMapAll; // 是所有点都显示，还是只打单个点在地图上？
@property (nonatomic) BOOL isUserShow; // 是否显示用户当前所在位置？
//@property (nonatomic) EMapAnnotation eAnnotation; // Annotation类型

@end
