//
//  UPWMyOrderTableViewCell.h
//  wallet
//
//  Created by gcwang on 15/3/24.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPWMyOrderModel.h"

#define kHeightWaitPayingOrderCell 112

//订单状态
typedef NS_ENUM(NSInteger, UPWMyOrderStatus) {
    UPWMyOrderStatusNone = 0,//未知，默认为处理中
    UPWMyOrderStatusWaitToPay = 1,//待支付
    UPWMyOrderStatusVerifying = 2,//验证中
    UPWMyOrderStatusProcessing = 3,//处理中
    UPWMyOrderStatusDeliverying = 4,//配送中
    UPWMyOrderStatusDeliveryDone = 5,//配送完成
    UPWMyOrderStatusCancel = 6//取消
};

@interface UPWMyOrderTableViewCell : UITableViewCell

- (void)setCellWithModel:(UPWMyOrderCellModel *)cellModel;

@end
