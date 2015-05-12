//
//  UPWSelectDeliveryAddressViewController.h
//  wallet
//
//  Created by gcwang on 15/3/16.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWRefreshViewController.h"

typedef enum{
    EConfirmOrderPage,
    EMineInfoPage
}EDeliveryAddrPageSource;

@interface UPWSelectDeliveryAddressViewController : UPWRefreshViewController

- (id)initWithPageSource:(EDeliveryAddrPageSource)pageSource;

@end
