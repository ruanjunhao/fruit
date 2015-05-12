//
//  UPWAddToCartPanel.m
//  wallet
//
//  Created by gcwang on 15/4/2.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWAddToCartPanel.h"
#import "UPWConst.h"

@interface UPWAddToCartPanel ()
{
    UIImageView *_cartImageView;
    UILabel *_cartNumLabel;
    UIButton *_addToCartButton;
}

@end

@implementation UPWAddToCartPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
        
        CGFloat edge = 16;
        CGFloat x = edge;
        CGFloat height = 44;
        CGFloat y = (kHeightAddToCartPanel - height)/2;
        CGFloat width = height;
        _cartImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _cartImageView.image = [UIImage imageNamed:@"fruit_add_to_cart"];
        [self addSubview:_cartImageView];
        
        y = 0;
        width = 14;
        height = width;
        x = CGRectGetWidth(_cartImageView.frame) - width;
        _cartNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _cartNumLabel.backgroundColor = [UIColor clearColor];
        _cartNumLabel.layer.cornerRadius = width/2;
        _cartNumLabel.layer.backgroundColor = [UIColor redColor].CGColor;
        _cartNumLabel.textColor = [UIColor whiteColor];
        _cartNumLabel.textAlignment = NSTextAlignmentCenter;
        _cartNumLabel.font = [UIFont systemFontOfSize:kConstantFont10];
        [_cartImageView addSubview:_cartNumLabel];
        
        width = 90;
        height = 44;
        x = CGRectGetWidth(frame) - edge - width;
        y = (kHeightAddToCartPanel - height)/2;
        _addToCartButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _addToCartButton.frame = CGRectMake(x, y, width, height);
        [_addToCartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _addToCartButton.titleLabel.font = [UIFont systemFontOfSize:kConstantFont14];
        _addToCartButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_addToCartButton setTitle:@"放入购物车" forState:UIControlStateNormal];
        [_addToCartButton setBackgroundColor:[UIColor orangeColor]];
        [_addToCartButton addTarget:self action:@selector(addToCartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addToCartButton];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /*
    if (self.fruitNum.length > 0) {
        CGSize size = [self.fruitNum sizeWithFont:[UIFont systemFontOfSize:kConstantFont10]];
        CGRect rect = _cartNumLabel.frame;
        rect.origin.x = CGRectGetMaxX(rect) - size.width;
        rect.size.width = size.width;
        _cartNumLabel.frame = rect;
        _cartNumLabel.layer.cornerRadius = rect.size.width/2;
        _cartNumLabel.layer.backgroundColor = [UIColor redColor].CGColor;
        _cartNumLabel.text = self.fruitNum;
    }
     */
}

- (void)setFruitNum:(NSString *)fruitNum
{
    _fruitNum = fruitNum;
    if (self.fruitNum.length > 0) {
        _cartNumLabel.text = self.fruitNum;
    }
}

#pragma mark -
#pragma mark - 放入购物车
- (void)addToCartButtonAction:(id)sender
{
    if (self.addToCartActionBlock) {
        self.addToCartActionBlock();
    }
}

@end
