//
//  UPWTotalPricePanel.h
//  wallet
//
//  Created by gcwang on 15/3/14.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kHeightTotalPricePanel 54

typedef void(^SelectButtonActionBlock)(void);
typedef void(^DeleteButtonActionBlock)(void);
typedef void(^SubmitButtonActionBlock)(void);

typedef enum{
    EShoppingCartPanelStyle,
    EConfirmOrderPanelStyle,
    EOrderDetailPanelStyle
}ETotalPricePanelStyle;

@interface UPWTotalPricePanel : UIView

@property (nonatomic, strong) SelectButtonActionBlock selectButtonActionBlock;
@property (nonatomic, strong) DeleteButtonActionBlock deleteButtonActionBlock;
@property (nonatomic, strong) SubmitButtonActionBlock submitButtonActionBlock;

@property (nonatomic, assign) BOOL selectAll;
@property (nonatomic, strong) NSString *totalPrice;
@property (nonatomic, strong) NSString *noFreightCondition;

@property (nonatomic, assign) ETotalPricePanelStyle panelStyle;

@end
