//
//  UPWCommonTableListModel.h
//  wallet
//
//  Created by gcwang on 15/3/12.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "JSONModel.h"

@interface UPWCommonTableListModel : JSONModel

//基础参数
@property (nonatomic, assign) NSInteger requestPage;
@property (nonatomic, retain) NSMutableArray *latestData;

//加载状态
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL loadMore;
@property (nonatomic, assign) BOOL pullToRefreshing;

//编辑
@property (nonatomic, retain) NSMutableArray *deleteArray;
@property (nonatomic, assign) BOOL editing;

@end
