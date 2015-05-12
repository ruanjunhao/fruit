//
//  UPWConfirmOrderTableViewCell.h
//  wallet
//
//  Created by gcwang on 15/3/16.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPWShoppingCartModel.h"

#define kHeightConfirmOrderCell 109

@interface UPWConfirmOrderTableViewCell : UITableViewCell

- (void)setCellWithModel:(UPWShoppingCartCellModel *)cellModel cellCount:(NSInteger)count indexPath:(NSIndexPath *)indexPath;

@end
