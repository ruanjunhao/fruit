//
//  UPWMyOrderTableViewCell.m
//  wallet
//
//  Created by gcwang on 15/3/24.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWMyOrderTableViewCell.h"
#import "UPWLightGridView.h"
#import "UPImageView.h"
#import "UPWConst.h"

#define kHeightImageList            60
#define kWidthImageList             60

@interface UPWMyOrderTableViewCell () <UPWLightGridViewDataSource>
{
    UILabel *_orderId;
    UILabel *_orderStatus;
    UPWLightGridView *_imageListGridView;
    
    UPWMyOrderCellModel *_cellModel;
}

@end

@implementation UPWMyOrderTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat x = 16;
        CGFloat y = 10;
        CGFloat width = (kScreenWidth - 2*x)/2;
        _orderId = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont14)];
        _orderId.backgroundColor = [UIColor clearColor];
        _orderId.textColor = UP_COL_RGB(0x333333);
        _orderId.font = [UIFont systemFontOfSize:kConstantFont14];
        [self.contentView addSubview:_orderId];
        
        x = CGRectGetMaxX(_orderId.frame);
        _orderStatus = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, kConstantFont14)];
        _orderStatus.backgroundColor = [UIColor clearColor];
        _orderStatus.textColor = UP_COL_RGB(0x333333);
        _orderStatus.textAlignment = NSTextAlignmentRight;
        _orderStatus.font = [UIFont systemFontOfSize:kConstantFont14];
        [self.contentView addSubview:_orderStatus];
        
        x = CGRectGetMinX(_orderId.frame);
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

NSString* stringOfOrderStatus(NSString *status)
{
    NSDictionary *orderStatusDict = @{@(UPWMyOrderStatusNone).stringValue:@"处理中", @(UPWMyOrderStatusWaitToPay).stringValue:@"待支付", @(UPWMyOrderStatusVerifying).stringValue:@"验证中", @(UPWMyOrderStatusProcessing).stringValue:@"处理中", @(UPWMyOrderStatusDeliverying).stringValue:@"配送中", @(UPWMyOrderStatusDeliveryDone).stringValue:@"已送达", @(UPWMyOrderStatusCancel).stringValue:@"取消"};
    
    return orderStatusDict[status];
}

- (void)setCellWithModel:(UPWMyOrderCellModel *)cellModel
{
    _cellModel = [[UPWMyOrderCellModel alloc] initWithDictionary:cellModel.toDictionary error:nil];
    _orderId.text = cellModel.orderId;
    _orderStatus.text = stringOfOrderStatus(cellModel.orderStatus);
    
    [_imageListGridView setNeedsLayout];
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
