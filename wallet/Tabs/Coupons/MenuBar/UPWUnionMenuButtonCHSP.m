//
//  UPUnionMenuButtonCHSP.m
//  ttttttestv
//
//  Created by TZ_JSKFZX_CAOQ on 13-11-11.
//  Copyright (c) 2013年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWUnionMenuButtonCHSP.h"

@interface UPWUnionMenuButtonCHSP()
{
    UILabel* _title;
    UIImageView* _rightImageView;
}
@property (nonatomic, retain) UIImage *imageForNoraml;
@property (nonatomic, retain) UIImage *imageForHighlighted;

@end

@implementation UPWUnionMenuButtonCHSP

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = UP_COL_RGB(0xffffff);
        
        _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)-10-10, 14,10,6)];
        [self addSubview:_rightImageView];
        [self setNormalImage:[UIImage imageNamed:@"orderDownArrow"]];
        [self setHighlightedImage:[UIImage imageNamed:@"orderUpArrow"]];
        _rightImageView.image = self.imageForNoraml;
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(14, 8, CGRectGetMinX(_rightImageView.frame)-14-2, 17)];
        _title.textAlignment = NSTextAlignmentLeft;
        _title.backgroundColor = [UIColor clearColor];
        [_title setTextColor:UP_COL_RGB(0x333333)];
        [_title setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_title];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _rightImageView.frame = CGRectMake(CGRectGetWidth(self.frame)-10-10, 14,10,6);
    _title.frame = CGRectMake(14, 8, CGRectGetMinX(_rightImageView.frame)-14-2, 17);
}

- (void)setNormalImage:(UIImage*)image
{
    self.imageForNoraml = image;
}
- (void)setHighlightedImage:(UIImage*)image
{
    self.imageForHighlighted = image;
}

- (void)setButtonSelected:(BOOL)selected
{
    [super setButtonSelected:selected];
    if (selected) {
        [_title setTextColor:UP_COL_RGB(0xea9c00)];
        _rightImageView.image = self.imageForHighlighted;
    }
    else{
        [_title setTextColor:UP_COL_RGB(0x333333)];
        _rightImageView.image = self.imageForNoraml;
    }
}

- (void)setButtonTitle:(NSString *)title showWordsLength:(NSInteger)length
{
    //最多显示4个字，其余用...表示
    NSString* text = title;
//    if (title.length > length) {
//        text = [title substringToIndex:length];
//    }
    [_title setText:text];
    [self setNeedsLayout];
}

@end
