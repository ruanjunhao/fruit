//
//  UPSmsButton.m
//  UPWallet
//
//  Created by wxzhao on 14-7-12.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWSmsButton.h"

@interface UPWSmsButton()
{
    UILabel* _label;
    NSTimer* _timer;
    NSInteger _interval;
    NSMutableString* _normalTitle;
}

@end

@implementation UPWSmsButton

@synthesize phoneNumber;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _normalTitle = [[NSMutableString alloc] init];

        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.numberOfLines = 0;
        _label.backgroundColor = [UIColor clearColor];
        _label.hidden = YES;
        [self addSubview:_label];
    }
    return self;
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    [super setTitleColor:color forState:state];
    
    if (state == UIControlStateNormal) {
        _label.textColor = color;
    }
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    
    if (state == UIControlStateNormal && [title length] > 0) {
        [_normalTitle setString:title];
    }
}

- (void)startTimerWithInterval:(NSInteger)interval
{
    self.enabled = NO;

    _interval = interval;
    [self setTitle:@"" forState:UIControlStateNormal];
    [self setTitle:@"" forState:UIControlStateDisabled];
    
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    
    _label.hidden = NO;
    _label.text = [NSString stringWithFormat:@"(%ld)秒后重新获取",(long)_interval];
    _label.font = self.titleLabel.font;
}

- (void)stopTimer
{
    [_timer invalidate];
    _interval = 0;
    _label.hidden = YES;
    
    if (self.phoneNumber) {
        self.enabled = [self.phoneNumber.text length] > 0?YES:NO;
    }
    else {
        self.enabled = YES;
    }

    [self setTitle:_normalTitle forState:UIControlStateNormal];
    [self setTitle:_normalTitle forState:UIControlStateDisabled];
}

- (void)timerAction:(NSTimer*)timer
{
    _interval--;
    _label.text = [NSString stringWithFormat:@"(%ld)秒后重新获取",(long)_interval];
    
    if (_interval == 0)
    {
        [self stopTimer];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    // 正在倒计时，不能设置enable
    if (_interval != 0) {
        return;
    }
    
    [super setEnabled:enabled];
}

@end
