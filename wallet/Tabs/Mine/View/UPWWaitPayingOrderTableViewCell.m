//
//  UPWWaitPayingOrderTableViewCell.m
//  wallet
//
//  Created by gcwang on 15/3/24.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWWaitPayingOrderTableViewCell.h"
#import "UPWLightGridView.h"
#import "UPImageView.h"
#import "UPWConst.h"

#define kHeightImageList            60
#define kWidthImageList             60

@interface UPWWaitPayingOrderTableViewCell () <UPWLightGridViewDataSource>
{
    UILabel *_orderId;
    UPWLightGridView *_imageListGridView;
    
    UPWWaitPayingOrderCellModel *_cellModel;
}

@end

@implementation UPWWaitPayingOrderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat x = 16;
        CGFloat y = 10;
        CGFloat width = kScreenWidth - 2*x;
        _orderId = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont12)];
        _orderId.backgroundColor = [UIColor clearColor];
        _orderId.textColor = UP_COL_RGB(0x333333);
        _orderId.font = [UIFont systemFontOfSize:kConstantFont12];
        [self.contentView addSubview:_orderId];
        
        y = CGRectGetMaxY(_orderId.frame) + 9.5;
        width = kScreenWidth - x;
        UIImageView *lineImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, 0.5)];
        lineImageView1.backgroundColor = UP_COL_RGB(0xd4d4d4);
        [self.contentView addSubview:lineImageView1];
        
        x = 16;
        y = CGRectGetMaxY(lineImageView1.frame) + 10;
        width = kScreenWidth - x - 38;
        _imageListGridView = [[UPWLightGridView alloc] initWithFrame:CGRectMake(x, y, width, kHeightImageList)];
        _imageListGridView.userInteractionEnabled = YES;
        _imageListGridView.customDataSource = self;
        [self.contentView addSubview:_imageListGridView];
        
        y = kHeightWaitPayingOrderCell - 0.5;
        width = kScreenWidth;
        UIImageView *lineImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, width, 0.5)];
        lineImageView2.backgroundColor = UP_COL_RGB(0xd4d4d4);
        [self.contentView addSubview:lineImageView2];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(UPWWaitPayingOrderCellModel *)cellModel
{
    _cellModel = [[UPWWaitPayingOrderCellModel alloc] initWithDictionary:cellModel.toDictionary error:nil];
    _orderId.text = cellModel.orderId;
    
    [_imageListGridView layoutSubviews];
}

#pragma mark -
#pragma mark UPLightGridView \ UPLightGridViewDatasource

- (NSInteger)countOfCellForLightGridView:(UPWLightGridView*)gridView
{
    return [_cellModel.imageUrlList count];
}

- (NSInteger)columnNumberForLightGridView:(UPWLightGridView*)gridView
{
    return [_cellModel.imageUrlList count];
}

- (CGFloat)borderMarginForLightGridView:(UPWLightGridView*)gridView
{
    return 15;
}

- (CGFloat)innerMarginForLightGridView:(UPWLightGridView*)gridView
{
    return 14;
}

- (CGSize)itemSizeForLightGridView:(UPWLightGridView*)gridView
{
    return CGSizeMake(kWidthImageList, kHeightImageList);
}

- (UIView*)lightGridView:(UPWLightGridView*)gridView cellAtIndex:(NSInteger)index
{
    UPImageView *imageView = [[UPImageView alloc] initWithFrame:CGRectMake(0, 0, kWidthImageList, kHeightImageList)];
    [imageView setImageWithURL:_cellModel.imageUrlList[index] withPlaceHolder:[UIImage imageNamed:@"coupon_placeholder"] withFailedImage:[UIImage imageNamed:@"coupon_placeholder"]];
    
    return imageView;
}

@end
