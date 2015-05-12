//
//  UPWShoppingCartTableViewCell.h
//  wallet
//
//  Created by gcwang on 15/3/14.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPWShoppingCartModel.h"

#define kShoppingCartCellHeight 109

typedef enum{
    increaseOneEditStyle,
    decreaseOneEditStyle,
    freeEditStyle
}EEditStyle;

typedef void(^EditNumberBlock)(EEditStyle editStyle);

@interface UPWShoppingCartTableViewCell : UITableViewCell

@property (nonatomic, strong) EditNumberBlock editNumberBlock;

- (void)setChecked:(BOOL)checked;
- (void)setCellWithModel:(UPWShoppingCartCellModel *)cellModel cellCount:(NSInteger)count indexPath:(NSIndexPath *)indexPath;

@end
