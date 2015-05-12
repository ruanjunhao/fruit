//
//  UPWCommonTableListModel.m
//  wallet
//
//  Created by gcwang on 15/3/12.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWCommonTableListModel.h"

@implementation UPWCommonTableListModel

- (id)init
{
    self = [super init];
    if (self) {
        self.requestPage = 1;
        self.latestData = [[NSMutableArray alloc] init];
        
        self.loading = NO;
        self.loadMore = NO;
        self.pullToRefreshing = NO;
        
        self.deleteArray = [[NSMutableArray alloc] init];
        self.editing = NO;
    }
    
    
    return self;
}

@end
