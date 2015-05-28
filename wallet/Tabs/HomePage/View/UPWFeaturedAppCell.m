//
//  UPBusiGridViewCell.m
//  UPWallet
//
//  Created by wxzhao on 14-7-16.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWFeaturedAppCell.h"
#import "UIImageView+WebCache.h"
#import "UPWFeaturedAppModel.h"
#import "UPWPathUtil.h"
#import "UPWAppInfoModel.h"

@interface UPWFeaturedAppCell()
{
    UIImageView* _imageView;
    UILabel* _textLabel;
}
@end

@implementation UPWFeaturedAppCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        CGFloat imageWidth = kHotAppWidth;
        CGFloat imageHeight = kHotAppWidth;

        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-imageWidth)/2, 15, imageWidth, imageHeight)];
        [self addSubview:_imageView];
        
        CGFloat y = CGRectGetMaxY(_imageView.frame) + 15;
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, frame.size.width, 15)];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = UP_COL_RGB(0x666666);
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)setCellModel:(UPWCatagoryCellModel*)model
{
    _textLabel.text = model.title;
    if (model.localImageName) {
        _imageView.image = [UIImage imageNamed:model.localImageName];
    } else {
        [_imageView setImageWithURL:[NSURL URLWithString:model.imageUrl] placeholderImage:UP_GETIMG(@"icon_failed_to_load")];
    }
}

- (void)setCellModelWithImage:(UIImage *)image text:(NSString *)text
{
    // 此函数主要是为了热门应用中的“更多”添加的
    _imageView.image = image;
    _textLabel.text = text;
}

@end
