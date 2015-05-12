//
//  UPWConfirmOrderTableViewCell.m
//  wallet
//
//  Created by gcwang on 15/3/16.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWConfirmOrderTableViewCell.h"
#import "UPImageView.h"
#import "UPWConst.h"

#define kStringPricePerUnit @"%@元/%@"

@interface UPWConfirmOrderTableViewCell ()
{
    UPImageView *_imageView;
    UILabel *_nameLabel;
    UILabel *_priceLabel;
    UIButton *_numButton;
}

@end

@implementation UPWConfirmOrderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat x = 16;
        CGFloat y = 15;
        _imageView = [[UPImageView alloc] initWithFrame:CGRectMake(x, y, 79, 79)];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.1].CGColor;
        _imageView.layer.borderWidth = 0.5;
        [self.contentView addSubview:_imageView];
        
        y = _imageView.frame.origin.y;
        x = x + _imageView.frame.size.width + 10;
        CGFloat width = kScreenWidth - x - CGRectGetMinX(_imageView.frame);
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont15)];
        _nameLabel.font = [UIFont systemFontOfSize:kConstantFont15];
        _nameLabel.textColor = UP_COL_RGB(0x666666);
        _nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_nameLabel];
        
        y = kHeightConfirmOrderCell - 15 -kConstantFont15;
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont15)];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = [UIFont systemFontOfSize:kConstantFont15];
        _priceLabel.textColor = UP_COL_RGB(0x666666);
        [self.contentView addSubview:_priceLabel];
        
        width = 80;
        x = kScreenWidth - CGRectGetMinX(_imageView.frame) - width;
        CGFloat height = 20;
        y = (kHeightConfirmOrderCell - height)/2;
        _numButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _numButton.frame = CGRectMake(x, y, width, height);
        [_numButton setTitleColor:UP_COL_RGB(0x333333) forState:UIControlStateNormal];
        _numButton.titleLabel.font = [UIFont systemFontOfSize:kConstantFont16];
        _numButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_numButton setTitle:@"数量：0个" forState:UIControlStateNormal];
        [_numButton setBackgroundColor:[UIColor clearColor]];
        _numButton.userInteractionEnabled = NO;
        [self.contentView addSubview:_numButton];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(UPWShoppingCartCellModel *)cellModel cellCount:(NSInteger)count indexPath:(NSIndexPath *)indexPath
{
    //画线
    //cell的dequeue属性，会重复利用线条，所以要先删除
    UIImageView *imageView2 = (UIImageView *)[self.contentView viewWithTag:999];
    [imageView2 removeFromSuperview];
    
    if (1 == count) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeightConfirmOrderCell-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else if (count > 1 && (0 == indexPath.row)) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kHeightConfirmOrderCell-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else if (count > 1 && (count-1 == indexPath.row)) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeightConfirmOrderCell-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kHeightConfirmOrderCell-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    }
    
    [_imageView setImageWithURL:cellModel.imageUrl withPlaceHolder:[UIImage imageNamed:@"coupon_placeholder"] withFailedImage:[UIImage imageNamed:@"coupon_placeholder"]];
    _nameLabel.text = cellModel.fruitName;
    _priceLabel.text = [NSString stringWithFormat:kStringPricePerUnit, cellModel.fruitPrice, cellModel.fruitPriceUnit];
    [_numButton setTitle:[NSString stringWithFormat:@"×%@", cellModel.fruitNum] forState:UIControlStateNormal];
}

@end
