//
//  UPWConfirmOrderViewController.h
//  wallet
//
//  Created by gcwang on 15/3/15.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWDataPresentBaseViewController.h"
#import "UPWShoppingCartModel.h"

typedef enum {
    EShoppingCartSource,
    EWaitPayingSource
}EPageSource;

@interface UPWConfirmOrderViewController : UPWDataPresentBaseViewController

- (id)initWithShoppingCartModel:(UPWShoppingCartModel *)model source:(EPageSource)pageSource;

@end
