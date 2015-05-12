//
//  UPImageTextField.m
//  UPWallet
//
//  Created by wxzhao on 14-7-11.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPImageTextField.h"
#import "UPWConst.h"

@interface UPImageTextField()
{
    UIImageView* _topLine;
    UIImageView* _bottomLine;
}

@end

@implementation UPImageTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

        self.layer.backgroundColor = [UIColor whiteColor].CGColor;
        self.font = [UIFont systemFontOfSize:kConstantFont14];

        _topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
        _topLine.image = [[UIImage imageNamed:@"separator"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        [self addSubview:_topLine];

        _bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height - 0.5, frame.size.width, 0.5)];
        _bottomLine.image = [[UIImage imageNamed:@"separator"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        _bottomLine.hidden = YES;
        [self addSubview:_bottomLine];
        
        // 加一个leftView，避免placeHolder太靠左边
        CGFloat height = self.frame.size.height;
        UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, height)];
        leftView.backgroundColor = [UIColor clearColor];
        self.leftView = leftView;
        self.leftViewMode = UITextFieldViewModeAlways;
        

    }
    return self;
}

- (void)setLeftImage:(NSString*)imageName
{
    CGFloat height = self.frame.size.height;
    UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 38, height)];
    leftView.backgroundColor = [UIColor clearColor];
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    NSInteger wh = 24;
    [imageView setFrame:CGRectMake(14, (height-wh)/2, wh, wh)];
    [leftView addSubview:imageView];
    
    self.leftView = leftView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setLast:(BOOL)last
{
    _bottomLine.hidden = NO;
}

- (NSString*)validFormat:(NSString*)text
{
    NSString* ret = nil;
    NSString* msg = self.alert;
    NSInteger min = self.lenMin;
    NSInteger max = self.lenMax;
    
    if (!([text length] >= min && [text length] <= max))
    {
        if (min == max)
        {
            ret = [NSString stringWithFormat:UP_STR(@"kStrLengthSameError"),msg,(long)min];
        }
        else
        {
            ret = [NSString stringWithFormat:UP_STR(@"kStrLengthMinMaxError"),msg,(long)min,(long)max];
        }
    }
    
    return ret;
}

@end
