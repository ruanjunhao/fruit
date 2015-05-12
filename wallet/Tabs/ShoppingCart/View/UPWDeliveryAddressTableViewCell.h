//
//  UPWDeliveryAddressTableViewCell.h
//  wallet
//
//  Created by gcwang on 15/3/16.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPWDeliveryAddressModel.h"

#define kHeightDeliveryAddrCell 92

@interface UPWDeliveryAddressTableViewCell : UITableViewCell

- (void)setCellWithModel:(UPWDeliveryAddressCellModel *)cellModel cellCount:(NSInteger)count indexPath:(NSIndexPath *)indexPath;

@end
