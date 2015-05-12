//
//  UPWTotalPricePanel.m
//  wallet
//
//  Created by gcwang on 15/3/14.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWTotalPricePanel.h"
#import "UPWConst.h"

#define kStringTotalPrice @"合计：￥%@"

@interface UPWTotalPricePanel ()
{
    UIButton *_selectButton;
    UIButton *_deleteButton;
    UILabel *_totalPriceLabel;
    UILabel *_freightLabel;
    UIButton *_submitButton;
}

@end

@implementation UPWTotalPricePanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
        
        CGFloat edge = 16;
        CGFloat x = edge;
        CGFloat height = 32;
        CGFloat y = (kHeightTotalPricePanel - height)/2;
        CGFloat width = 40;
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.frame = CGRectMake(x, y, width, height);
        [_selectButton setTitleColor:UP_COL_RGB(0x333333) forState:UIControlStateNormal];
        _selectButton.titleLabel.font = [UIFont systemFontOfSize:kConstantFont14];
        _selectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_selectButton setTitle:@"全选" forState:UIControlStateNormal];
        [_selectButton setTitle:@"反选" forState:UIControlStateSelected];
        [_selectButton setBackgroundImage:[UIImage imageNamed:@"btn_white"] forState:UIControlStateNormal];
        [_selectButton setBackgroundImage:[UIImage imageNamed:@"btn_gray"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_selectButton];
        
        x = CGRectGetMaxX(_selectButton.frame) + 10;
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(x, y, width, height);
        [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:kConstantFont14];
        _deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton setBackgroundColor:[UIColor redColor]];
        [_deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        width = 60;
        x = CGRectGetWidth(frame) - edge - width;
        y = (kHeightTotalPricePanel - height)/2;
        _submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _submitButton.frame = CGRectMake(x, y, width, height);
        [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitButton.titleLabel.font = [UIFont systemFontOfSize:kConstantFont14];
        _submitButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_submitButton setTitle:@"结算" forState:UIControlStateNormal];
        [_submitButton setBackgroundColor:[UIColor orangeColor]];
        [_submitButton addTarget:self action:@selector(submitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_submitButton];
        
        width = 60;
        x = CGRectGetMinX(_submitButton.frame) - 10 - width;
        y = (kHeightTotalPricePanel - 2*kConstantFont12 - 4)/2;
        _totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont12)];
        _totalPriceLabel.backgroundColor = [UIColor clearColor];
        _totalPriceLabel.textColor = [UIColor orangeColor];
        _totalPriceLabel.textAlignment = NSTextAlignmentRight;
        _totalPriceLabel.font = [UIFont systemFontOfSize:kConstantFont12];
        _totalPriceLabel.text = [NSString stringWithFormat:kStringTotalPrice, @"0.00"];
        [self addSubview:_totalPriceLabel];
        
        y = CGRectGetMaxY(_totalPriceLabel.frame) + 4;
        _freightLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont12)];
        _freightLabel.backgroundColor = [UIColor clearColor];
        _freightLabel.textColor = UP_COL_RGB(0x666666);
        _freightLabel.textAlignment = NSTextAlignmentRight;
        _freightLabel.font = [UIFont systemFontOfSize:kConstantFont12];
        _freightLabel.text = @"免运费";
        [self addSubview:_freightLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = CGSizeZero;
    CGRect rect = CGRectZero;
    
    if (self.totalPrice.length > 0) {
        NSString *totalPrice = [NSString stringWithFormat:kStringTotalPrice, self.totalPrice];
        CGSize size = [totalPrice sizeWithFont:[UIFont systemFontOfSize:kConstantFont12]];
        CGRect rect = _totalPriceLabel.frame;
        rect.origin.x = CGRectGetMaxX(rect) - size.width;
        rect.size.width = size.width;
        _totalPriceLabel.frame = rect;
        _totalPriceLabel.text = totalPrice;
    }
    
    if (self.noFreightCondition.length > 0) {
        size = [self.noFreightCondition sizeWithFont:[UIFont systemFontOfSize:kConstantFont12]];
        rect = _freightLabel.frame;
        rect.origin.x = CGRectGetMaxX(rect) - size.width;
        rect.size.width = size.width;
        _freightLabel.frame = rect;
        _freightLabel.text = self.noFreightCondition;
    }
}

#pragma mark -
#pragma mark - 全选、反选操作
- (void)selectButtonAction:(id)sender
{
    if (self.selectButtonActionBlock) {
        self.selectButtonActionBlock();
    }
}

#pragma mark -
#pragma mark - 删除操作
- (void)deleteButtonAction:(id)sender
{
    if (self.deleteButtonActionBlock) {
        self.deleteButtonActionBlock();
    }
}

- (void)setSelectAll:(BOOL)selectAll
{
    _selectAll = selectAll;
    [_selectButton setSelected:selectAll];
}

#pragma mark -
#pragma mark - 结算
- (void)submitButtonAction:(id)sender
{
    if (self.submitButtonActionBlock) {
        self.submitButtonActionBlock();
    }
}

#pragma mark -
#pragma mark - 设定panel样式
- (void)setPanelStyle:(ETotalPricePanelStyle)panelStyle
{
    switch (panelStyle) {
        case EShoppingCartPanelStyle:
        {
            _selectButton.hidden = NO;
            _deleteButton.hidden = NO;
            [_submitButton setTitle:@"结算" forState:UIControlStateNormal];
        }
            break;
        case EConfirmOrderPanelStyle:
        {
            _selectButton.hidden = YES;
            _deleteButton.hidden = YES;
            [_submitButton setTitle:@"确定" forState:UIControlStateNormal];
        }
            break;
        case EOrderDetailPanelStyle:
        {
            _selectButton.hidden = YES;
            _deleteButton.hidden = YES;
            [_submitButton setTitle:@"再次购买" forState:UIControlStateNormal];
        }
    }
}

@end
