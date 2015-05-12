//
//  UPWDeliveryAddressTableViewCell.m
//  wallet
//
//  Created by gcwang on 15/3/16.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWDeliveryAddressTableViewCell.h"
#import "UPImageView.h"
#import "UPWConst.h"

#define kStringPricePerUnit @"%@元/%@"

@interface UPWDeliveryAddressTableViewCell ()
{
    UILabel *_nameLabel;
    UILabel *_phoneLabel;
    UILabel *_addrLabel;
}

@end

@implementation UPWDeliveryAddressTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat x = 16;
        CGFloat y = 15;
        CGFloat width = (kScreenWidth - 2*x)/2;
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont15)];
        _nameLabel.font = [UIFont systemFontOfSize:kConstantFont15];
        _nameLabel.textColor = UP_COL_RGB(0x666666);
        _nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_nameLabel];
        
        x = CGRectGetMaxX(_nameLabel.frame) + 5;
        width = width - 15;
        _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont15)];
        _phoneLabel.backgroundColor = [UIColor clearColor];
        _phoneLabel.font = [UIFont systemFontOfSize:kConstantFont15];
        _phoneLabel.textColor = UP_COL_RGB(0x666666);
        _phoneLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_phoneLabel];
        
        x = CGRectGetMinX(_nameLabel.frame);
        y = CGRectGetMaxY(_nameLabel.frame) + 5;
        width = kScreenWidth - 2*x - 10;
        CGFloat height = 3*kConstantFont13;
        _addrLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _addrLabel.backgroundColor = [UIColor clearColor];
        _addrLabel.font = [UIFont systemFontOfSize:kConstantFont13];
        _addrLabel.textColor = UP_COL_RGB(0x666666);
        _addrLabel.numberOfLines = 0;
        [self.contentView addSubview:_addrLabel];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(UPWDeliveryAddressCellModel *)cellModel cellCount:(NSInteger)count indexPath:(NSIndexPath *)indexPath
{
    //画线
    //cell的dequeue属性，会重复利用线条，所以要先删除
    UIImageView *imageView2 = (UIImageView *)[self.contentView viewWithTag:999];
    [imageView2 removeFromSuperview];
    
    if (1 == count) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeightDeliveryAddrCell-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else if (count > 1 && (0 == indexPath.row)) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kHeightDeliveryAddrCell-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else if (count > 1 && (count-1 == indexPath.row)) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeightDeliveryAddrCell-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kHeightDeliveryAddrCell-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    }
    
    _nameLabel.text = [NSString stringWithFormat:@"收货人：%@", cellModel.userName];
    _phoneLabel.text = cellModel.phoneNum;
    _addrLabel.text = [NSString stringWithFormat:@"收货地址：%@%@%@%@", cellModel.addrInfo.province, cellModel.addrInfo.city, cellModel.addrInfo.region, cellModel.addrInfo.detailAddr];
}

@end
