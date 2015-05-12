//
//  UPWAddToCartPanel.h
//  wallet
//
//  Created by gcwang on 15/4/2.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kHeightAddToCartPanel 54

typedef void(^AddToCartActionBlock)(void);

@interface UPWAddToCartPanel : UIView

@property (nonatomic, strong) AddToCartActionBlock addToCartActionBlock;

@property (nonatomic, strong) NSString *fruitNum;

@end
