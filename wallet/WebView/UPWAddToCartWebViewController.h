//
//  UPWAddToCartWebViewController.h
//  wallet
//
//  Created by gcwang on 15/4/4.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWBaseViewController.h"
#import "UPWFruitListModel.h"

@interface UPWAddToCartWebViewController : UPWBaseViewController

@property (nonatomic, strong) NSString *startPage;

- (id)initWithCellModel:(UPWFruitListCellModel *)cellModel;

@end
