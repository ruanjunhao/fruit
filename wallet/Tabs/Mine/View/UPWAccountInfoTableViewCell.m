//
//  UPWAccountInfoTableViewCell.m
//  wallet
//
//  Created by gcwang on 15/3/18.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWAccountInfoTableViewCell.h"
#import "UPImageView.h"
#import "UPWConst.h"

@interface UPWAccountInfoTableViewCell ()
{
    UPImageView *_headImageView;
    UILabel *_nicknameLabel;
    UILabel *_phoneNumLabel;
}

@end

@implementation UPWAccountInfoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat x = 16;
        CGFloat y = 10;
        CGFloat width = 65;
        y = (kHeightAccountInfoCell - width)/2;
        _headImageView = [[UPImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
        [self.contentView addSubview:_headImageView];
        
        x = CGRectGetMaxX(_headImageView.frame) + 10;
        y = (kHeightAccountInfoCell - kConstantFont16 - kConstantFont14 - 10)/2;
        width = kScreenWidth - CGRectGetMaxX(_headImageView.frame) - 10 - 40;
        _nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont16)];
        _nicknameLabel.backgroundColor = [UIColor clearColor];
        _nicknameLabel.textColor = UP_COL_RGB(0x333333);
        _nicknameLabel.font = [UIFont systemFontOfSize:kConstantFont16];
        [self.contentView addSubview:_nicknameLabel];
        
        y = CGRectGetMaxY(_nicknameLabel.frame) + 10;
        _phoneNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont14)];
        _phoneNumLabel.backgroundColor = [UIColor clearColor];
        _phoneNumLabel.textColor = UP_COL_RGB(0x333333);
        _phoneNumLabel.font = [UIFont systemFontOfSize:kConstantFont14];
        [self.contentView addSubview:_phoneNumLabel];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(UPWAccountInfoModel *)cellModel cellCount:(NSInteger)count indexPath:(NSIndexPath *)indexPath
{
    //画线
    //cell的dequeue属性，会重复利用线条，所以要先删除
    UIImageView *imageView2 = (UIImageView *)[self.contentView viewWithTag:999];
    [imageView2 removeFromSuperview];
    
    if (1 == count) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeightAccountInfoCell-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else if (count > 1 && (0 == indexPath.row)) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kHeightAccountInfoCell-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else if (count > 1 && (count-1 == indexPath.row)) {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeightAccountInfoCell-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    } else {
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kHeightAccountInfoCell-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        downImageView.tag = 999;
        [self.contentView addSubview:downImageView];
    }
    
    UIImage* image = [UIImage imageWithContentsOfFile:cellModel.localImageName];
    if (image) {
        [_headImageView setImage:image];
    } else {
        [_headImageView setImage:[UIImage imageNamed:@"head_image"]];
    }
    
//    [_headImageView setImageWithURL:cellModel.headImageUrl withPlaceHolder:[UIImage imageNamed:@"coupon_placeholder"] withFailedImage:[UIImage imageNamed:@"coupon_placeholder"]];
    _nicknameLabel.text = cellModel.nickname;
    _phoneNumLabel.text = cellModel.phoneNum;
}

@end
