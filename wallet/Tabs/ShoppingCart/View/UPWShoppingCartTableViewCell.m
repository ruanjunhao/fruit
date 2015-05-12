//
//  UPWShoppingCartTableViewCell.m
//  wallet
//
//  Created by gcwang on 15/3/14.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWShoppingCartTableViewCell.h"
#import "UPImageView.h"
#import "UPWConst.h"

#define kStringPricePerUnit @"%@元/%@"

@interface UPWShoppingCartTableViewCell ()
{
    UIButton *_checkedButton;
    UPImageView *_imageView;
    UILabel *_nameLabel;
    UILabel *_priceLabel;
    UIButton *_numButton;
    UIButton *_increaseNumButton;//待用
    UIButton *_decreaseNumButton;//待用
}

@end

@implementation UPWShoppingCartTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat x = 10;
        CGFloat width = 22;
        CGFloat heigth = width;
        CGFloat y = (kShoppingCartCellHeight - heigth)/2;
        _checkedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkedButton.frame = CGRectMake(x, y, width, heigth);
        [_checkedButton setBackgroundImage:[UIImage imageNamed:@"cart_unchecked"] forState:UIControlStateNormal];
        [_checkedButton setBackgroundImage:[UIImage imageNamed:@"cart_checked"] forState:UIControlStateHighlighted];
        [_checkedButton setBackgroundImage:[UIImage imageNamed:@"cart_checked"] forState:UIControlStateSelected];
        [self addSubview:_checkedButton];
        
        x = CGRectGetMaxX(_checkedButton.frame) + 10;
        y = 15;
        _imageView = [[UPImageView alloc] initWithFrame:CGRectMake(x, y, 79, 79)];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.1].CGColor;
        _imageView.layer.borderWidth = 0.5;
        [self.contentView addSubview:_imageView];
        
        y = _imageView.frame.origin.y;
        x = x + _imageView.frame.size.width + 10;
        width = kScreenWidth - x - CGRectGetMinX(_imageView.frame);
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont15)];
        _nameLabel.font = [UIFont systemFontOfSize:kConstantFont15];
        _nameLabel.textColor = UP_COL_RGB(0x666666);
        _nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_nameLabel];
        
        y = kShoppingCartCellHeight - 15 -kConstantFont15;
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont15)];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = [UIFont systemFontOfSize:kConstantFont15];
        _priceLabel.textColor = UP_COL_RGB(0x666666);
        [self.contentView addSubview:_priceLabel];
        
        width = 80;
        x = kScreenWidth - CGRectGetMinX(_checkedButton.frame) - width;
        CGFloat height = 20;
        y = (kShoppingCartCellHeight - height)/2;
        _numButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _numButton.frame = CGRectMake(x, y, width, height);
        [_numButton setTitleColor:UP_COL_RGB(0x333333) forState:UIControlStateNormal];
        _numButton.titleLabel.font = [UIFont systemFontOfSize:kConstantFont16];
        _numButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_numButton setTitle:@"数量：0个" forState:UIControlStateNormal];
        [_numButton setBackgroundColor:[UIColor clearColor]];
        [_numButton addTarget:self action:@selector(editNumberAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_numButton];
        
        width = 40 + CGRectGetMinX(_checkedButton.frame);
        x = kScreenWidth - width;
        height = kShoppingCartCellHeight - CGRectGetMaxY(_numButton.frame) - 5;
        y = 0;
        _increaseNumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _increaseNumButton.frame = CGRectMake(x, y, width, height);
        [_increaseNumButton setBackgroundColor:[UIColor clearColor]];
        UIImageView *increaseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(_increaseNumButton.frame)-20, 20, 20)];
        increaseImageView.image = [UIImage imageNamed:@"cart_step_add"];
        [_increaseNumButton addSubview:increaseImageView];
        [_increaseNumButton addTarget:self action:@selector(editNumberAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_increaseNumButton];
        
        y = CGRectGetMaxY(_numButton.frame) + 5;
        _decreaseNumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _decreaseNumButton.frame = CGRectMake(x, y, width, height);
        [_decreaseNumButton setBackgroundColor:[UIColor clearColor]];
        UIImageView *decreaseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 20, 20)];
        decreaseImageView.image = [UIImage imageNamed:@"cart_step_reduce"];
        [_decreaseNumButton addSubview:decreaseImageView];
        [_decreaseNumButton addTarget:self action:@selector(editNumberAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_decreaseNumButton];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setChecked:(BOOL)checked
{
    [_checkedButton setSelected:checked];
}

- (void)editNumberAction:(id)sender
{
    if (self.editNumberBlock) {
        if ((UIButton *)sender == _increaseNumButton) {
            self.editNumberBlock(increaseOneEditStyle);
        } else if ((UIButton *)sender == _decreaseNumButton) {
            self.editNumberBlock(decreaseOneEditStyle);
        } else {
            self.editNumberBlock(freeEditStyle);
        }
    }
}

- (void)setCellWithModel:(UPWShoppingCartCellModel *)cellModel cellCount:(NSInteger)count indexPath:(NSIndexPath *)indexPath
{
    //画线
    //cell的dequeue属性，会重复利用线条，所以要先删除
    UIImageView *imageView2 = (UIImageView *)[self.contentView viewWithTag:999];
    [imageView2 removeFromSuperview];
    
    if (1 == count) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kShoppingCartCellHeight-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else if (count > 1 && (0 == indexPath.row)) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kShoppingCartCellHeight-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else if (count > 1 && (count-1 == indexPath.row)) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kShoppingCartCellHeight-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kShoppingCartCellHeight-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    }
    
    [_imageView setImageWithURL:cellModel.imageUrl withPlaceHolder:[UIImage imageNamed:@"coupon_placeholder"] withFailedImage:[UIImage imageNamed:@"coupon_placeholder"]];
    _nameLabel.text = cellModel.fruitName;
    _priceLabel.text = [NSString stringWithFormat:kStringPricePerUnit, cellModel.fruitPrice, cellModel.fruitPriceUnit];
    [_numButton setTitle:[NSString stringWithFormat:@"×%@", cellModel.fruitNum] forState:UIControlStateNormal];
    
    [self setChecked:cellModel.checked.boolValue];
}

@end
