//
//  UPWFruitTableViewCell.h
//  wallet
//
//  Created by gcwang on 15/3/12.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPWFruitListModel.h"

#define kFruitCellHeight 109

//typedef void(^putInShoppingCartBlock)(void);

@interface UPWFruitTableViewCell : UITableViewCell

//@property (nonatomic, strong) putInShoppingCartBlock putInShoppingCartBlock;

- (void)setCellWithModel:(UPWFruitListCellModel *)cellModel cellCount:(NSInteger)count indexPath:(NSIndexPath *)indexPath;

@end
