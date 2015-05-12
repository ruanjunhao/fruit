//
//  UPWHomeTemplateView.m
//  wallet
//
//  Created by gcwang on 15/3/11.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWHomeTemplateView.h"
#import "UPWConst.h"

@interface UPWHomeTemplateView ()
{
    UILabel *_nameLabel;
    
//    NSMutableArray *_controlArray;
}

@end

@implementation UPWHomeTemplateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat gap = 0.5;
        
        CGFloat x = 16;
        CGFloat y = 0;
        CGFloat width = CGRectGetWidth(frame)*2/3;
        CGFloat height = 36;
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = UP_COL_RGB(0x333333);
        _nameLabel.font = [UIFont systemFontOfSize:kConstantFont14];
        [self addSubview:_nameLabel];
        
        x = CGRectGetWidth(frame)*2/3;
        width = CGRectGetWidth(frame) - x - 16;
        UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        moreButton.backgroundColor = [UIColor clearColor];
        [moreButton setTitleColor:UP_COL_RGB(0x333333) forState:UIControlStateNormal];
        [moreButton setTitle:@"更多>>" forState:UIControlStateNormal];
        moreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        moreButton.titleLabel.font = [UIFont systemFontOfSize:kConstantFont14];
        [moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:moreButton];
        
        x = 0;
        y = CGRectGetMaxY(_nameLabel.frame);
        width = CGRectGetWidth(frame)*2/3;
        height = (CGRectGetHeight(frame)-CGRectGetHeight(_nameLabel.frame))*2/3;
        UIControl *control1 = [[UIControl alloc] initWithFrame:CGRectMake(x, y, width, height)];
        control1.backgroundColor = [UIColor clearColor];
        control1.layer.borderWidth = 0.5;
        control1.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
        [control1 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control1];
        _controlArray = [[NSMutableArray alloc] initWithObjects:control1, nil];
        
        x = CGRectGetMaxX(control1.frame) + gap;
        width = (CGRectGetWidth(frame)-2*gap)*1/3;
        height = (CGRectGetHeight(frame)-CGRectGetHeight(_nameLabel.frame)-2*gap)*1/3;
        UIControl *control2 = [[UIControl alloc] initWithFrame:CGRectMake(x, y, width, height)];
        control2.backgroundColor = [UIColor clearColor];
        control2.layer.borderWidth = 0.5;
        control2.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
        [control2 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control2];
        [_controlArray addObject:control2];
        
        y = CGRectGetMaxY(control2.frame) + gap;
        UIControl *control3 = [[UIControl alloc] initWithFrame:CGRectMake(x, y, width, height)];
        control3.backgroundColor = [UIColor clearColor];
        control3.layer.borderWidth = 0.5;
        control3.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
        [control3 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control3];
        [_controlArray addObject:control3];
        
        x = 0;
        y = CGRectGetMaxY(control1.frame) + gap;
        UIControl *control4 = [[UIControl alloc] initWithFrame:CGRectMake(x, y, width, height)];
        control4.backgroundColor = [UIColor clearColor];
        control4.layer.borderWidth = 0.5;
        control4.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
        [control4 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control4];
        [_controlArray addObject:control4];
        
        x = CGRectGetWidth(control4.frame) + gap;
        UIControl *control5 = [[UIControl alloc] initWithFrame:CGRectMake(x, y, width, height)];
        control5.backgroundColor = [UIColor clearColor];
        control5.layer.borderWidth = 0.5;
        control5.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
        [control5 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control5];
        [_controlArray addObject:control5];
        
        x = CGRectGetMaxX(control5.frame) + gap;
        y = CGRectGetMaxY(control3.frame) + gap;
        UIControl *control6 = [[UIControl alloc] initWithFrame:CGRectMake(x, y, width, height)];
        control6.backgroundColor = [UIColor clearColor];
        control6.layer.borderWidth = 0.5;
        control6.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
        [control6 addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control6];
        [_controlArray addObject:control6];        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _nameLabel.text = [self.dataSource nameForHomeTemplateView:self];
    
    for (NSInteger i = 0; i < _controlArray.count; i++) {
        NSArray *subViewArray = [_controlArray[i] subviews];
        for (UIView* view in subViewArray)
        {
            [view removeFromSuperview];
        }
    }
    
    NSInteger count = [self.dataSource countOfCellForHomeTemplateView:self]<_controlArray.count?[self.dataSource countOfCellForHomeTemplateView:self]:_controlArray.count;
    for (int i = 0; i < count; i++)
    {
        UIControl *control = (UIControl *)_controlArray[i];
        
        UIView* subView = [self.dataSource homeTemplateView:self cellAtIndex:i];
        [control addSubview:subView];
    }
}

- (void)moreButtonAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeTemplateView:didSelectMore:)]) {
        [self.delegate homeTemplateView:self didSelectMore:sender];
    }
}

- (void)tapAction:(id)sender
{
    for (int i = 0; i < [_controlArray count]; i++)
    {
        if (sender == [_controlArray objectAtIndex:i])
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(homeTemplateView:didSelectAtIndex:)])
            {
                [self.delegate homeTemplateView:self didSelectAtIndex:i];
            }
            break;
        }
    }
}

@end
