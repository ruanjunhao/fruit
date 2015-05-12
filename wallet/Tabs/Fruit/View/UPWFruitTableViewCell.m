//
//  UPWFruitTableViewCell.m
//  wallet
//
//  Created by gcwang on 15/3/12.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWFruitTableViewCell.h"
#import "UPImageView.h"
#import "UPWConst.h"
#import "UPWNotificationName.h"

#define kStringPricePerBox %@元/盒
#define kStringPriceOfSingle %@元/个
#define kStringPricePerKg %@元/公斤
#define kStringPricePerUnit @"%@元/%@"

@interface UPWFruitTableViewCell ()
{
    UPImageView *_imageView;
    UILabel *_nameLabel;
    UILabel *_priceLabel;
    UIButton *_buyButton;
    
    NSIndexPath *_indexPath;
}

@end

@implementation UPWFruitTableViewCell

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
        
        y = kFruitCellHeight - 15 -kConstantFont15;
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont15)];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = [UIFont systemFontOfSize:kConstantFont15];
        _priceLabel.textColor = UP_COL_RGB(0x666666);
        [self.contentView addSubview:_priceLabel];
        
        width = 44;
        x = kScreenWidth - CGRectGetMinX(_imageView.frame) - width;
        y = (kFruitCellHeight - width)/2;
        _buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _buyButton.frame = CGRectMake(x, y, width, width);
//        [_buyButton setTitleColor:UP_COL_RGB(0x333333) forState:UIControlStateNormal];
//        _buyButton.titleLabel.font = [UIFont systemFontOfSize:kConstantFont16];
//        _buyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//        [_buyButton setTitle:@"放入购物车" forState:UIControlStateNormal];
        [_buyButton setBackgroundImage:[UIImage imageNamed:@"fruit_add_to_cart"] forState:UIControlStateNormal];
        [_buyButton addTarget:self action:@selector(putInShoppingCart:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_buyButton];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)putInShoppingCart:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPutInShoppingCart object:nil userInfo:@{@"position":[NSValue valueWithCGPoint:[self convertPoint:_buyButton.center toView:self.superview]], @"indexPath":_indexPath}];
}

- (void)setCellWithModel:(UPWFruitListCellModel *)cellModel cellCount:(NSInteger)count indexPath:(NSIndexPath *)indexPath
{
    _indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    //画线
    //cell的dequeue属性，会重复利用线条，所以要先删除
    UIImageView *imageView2 = (UIImageView *)[self.contentView viewWithTag:999];
    [imageView2 removeFromSuperview];
    
    if (1 == count) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kFruitCellHeight-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else if (count > 1 && (0 == indexPath.row)) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kFruitCellHeight-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else if (count > 1 && (count-1 == indexPath.row)) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kFruitCellHeight-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kFruitCellHeight-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    }
    
    [_imageView setImageWithURL:cellModel.imageUrl withPlaceHolder:[UIImage imageNamed:@"coupon_placeholder"] withFailedImage:[UIImage imageNamed:@"coupon_placeholder"]];
    _nameLabel.text = cellModel.fruitName;
    _priceLabel.text = [NSString stringWithFormat:kStringPricePerUnit, cellModel.fruitPrice, cellModel.fruitPriceUnit];
}

@end
