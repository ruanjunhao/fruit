//
//  UPMineGridViewCell.m
//  UPWallet
//
//  Created by wxzhao on 14-7-26.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWMineGridViewCell.h"

@interface UPWMineGridViewCell()
{
    UIImageView* _imageView;
    UILabel* _titleLabel;
    UILabel* _numberLabel;
    UIView* _rightLine;
    UIView* _bottomLine;
    UIImageView *_imageViewRedDot;
    
    NSString* _imageName;
    NSString* _title;
    NSString* _number;
    
    BOOL _isRightCell;
    BOOL _isLastLine;
    BOOL _hasRedDot;
}

@end

@implementation UPWMineGridViewCell

@synthesize imageName = _imageName;
@synthesize title = _title;
@synthesize number = _number;
@synthesize isRightCell = _isRightCell;
@synthesize isLastLine = _isLastLine;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        
        CGFloat x = (width-32)/2;
        CGFloat y = 20;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 32, 32)];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.image = [UIImage imageNamed:_imageName];
        [self addSubview:_imageView];
        
        x = 0;
        y = CGRectGetMaxY(_imageView.frame) + 11;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 12)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = UP_COL_RGB(0x666666);
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = _title;
        [self addSubview:_titleLabel];

        y = CGRectGetMaxY(_titleLabel.frame) + 8;
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, 12)];
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.textColor = UP_COL_RGB(0x999999);
        _numberLabel.font = [UIFont systemFontOfSize:12];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.text = _number;
        [self addSubview:_numberLabel];

        _rightLine = [[UIView alloc] initWithFrame:CGRectMake(width - 0.5, 0, 0.5, height)];
        _rightLine.layer.borderWidth = 0.5;
        _rightLine.layer.borderColor = UP_COL_RGB(0xe5e5e5).CGColor;
        [self addSubview:_rightLine];
        
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, height - 0.5, width, 0.5)];
        _bottomLine.layer.borderWidth = 0.5;
        _bottomLine.layer.borderColor = UP_COL_RGB(0xe5e5e5).CGColor;
        [self addSubview:_bottomLine];
        
        _imageViewRedDot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"push_info@2x.png"]];
        _imageViewRedDot.backgroundColor = [UIColor clearColor];
        _imageViewRedDot.frame = CGRectMake(frame.size.width - 28, 20, 8, 8);
        _imageViewRedDot.hidden = YES;
        [self addSubview:_imageViewRedDot];

    }
    return self;
}

- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    [_imageView setImage:[UIImage imageNamed:_imageName]];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = _title;
}

- (void)setNumber:(NSString *)number
{
    _number = number;
    _numberLabel.text = _number;
}

- (void)setIsRightCell:(BOOL)isRightCell
{
    _isRightCell = isRightCell;
    _rightLine.hidden = _isRightCell;
}

- (void)setIsLastLine:(BOOL)isLastLine
{
    _isLastLine = isLastLine;
    _bottomLine.hidden = NO;//_isLastLine;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = UP_COL_RGB(0xf9f9fb);
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (BOOL)hasRedDot
{
    return _hasRedDot;
}

- (void)setHasRedDot:(BOOL)hasRedDot
{
    _hasRedDot = hasRedDot;
    
    _imageViewRedDot.hidden = !hasRedDot;
}

@end

