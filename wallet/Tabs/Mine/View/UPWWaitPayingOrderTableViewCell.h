//
//  UPWWaitPayingOrderTableViewCell.h
//  wallet
//
//  Created by gcwang on 15/3/24.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPWWaitPayingOrderModel.h"

#define kHeightWaitPayingOrderCell 112

@interface UPWWaitPayingOrderTableViewCell : UITableViewCell

- (void)setCellWithModel:(UPWWaitPayingOrderCellModel *)cellModel;

@end
