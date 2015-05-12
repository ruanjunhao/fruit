//
//  UPFaceImageView.m
//  UPWallet
//
//  Created by wxzhao on 14-8-19.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWFaceImageView.h"

@interface UPWFaceImageView()
{
    UIView *_borderView;
    UIImageView* _faceImageView;
}

@end

@implementation UPWFaceImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _borderView = [[UIView alloc] initWithFrame:self.bounds];
        _borderView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.08];
        _borderView.layer.cornerRadius = frame.size.width/2;
        _borderView.layer.masksToBounds = YES;
        _borderView.layer.borderWidth = 0.5;
        _borderView.layer.borderColor = UP_COL_RGB(0xacadc8).CGColor;
        [self addSubview:_borderView];
        
        _faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, CGRectGetWidth(frame)-10, CGRectGetHeight(frame)-10)];
        _faceImageView.backgroundColor = [UIColor clearColor];
        _faceImageView.layer.cornerRadius = (frame.size.width-10)/2;
        _faceImageView.layer.masksToBounds = YES;
        [self addSubview:_faceImageView];
    }
    return self;
}

- (void)setFaceImage:(UIImage *)image
{
    _faceImageView.image = image;
}

@end
