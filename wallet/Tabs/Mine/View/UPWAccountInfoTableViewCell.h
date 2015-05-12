//
//  UPWAccountInfoTableViewCell.h
//  wallet
//
//  Created by gcwang on 15/3/18.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPWAccountInfoModel.h"

#define kHeightAccountInfoCell 88

@interface UPWAccountInfoTableViewCell : UITableViewCell

- (void)setCellWithModel:(UPWAccountInfoModel *)cellModel cellCount:(NSInteger)count indexPath:(NSIndexPath *)indexPath;

@end
