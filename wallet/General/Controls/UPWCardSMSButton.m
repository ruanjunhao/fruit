//
//  UPWSMSButton.m
//  wallet
//
//  Created by qcao on 14/10/28.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWCardSMSButton.h"

@interface UPWCardSMSButton()

@property(nonatomic, strong) NSTimer * smsTimer;
@property(nonatomic, assign) NSInteger countdown;
@property(nonatomic, assign) BOOL counting;

@end

@implementation UPWCardSMSButton


+ (instancetype)smsButton
{
    UPWCardSMSButton* button = [UPWCardSMSButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:UP_STR(@"String_Card_GetSMSVerificationCode") forState:UIControlStateNormal];
    UIImage* bg = [UP_GETIMG(@"card_sms_btn") resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, 0, 0.5, 0)];
    [button setBackgroundImage:bg forState:UIControlStateNormal];
    [button setBackgroundImage:bg forState:UIControlStateDisabled];
    [button setTitleColor:UP_COL_RGB(0x158cfb) forState:UIControlStateNormal];
    [button setTitleColor:UP_COL_RGB(0x999999) forState:UIControlStateDisabled];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    
    return button;
}


- (void)startCounting
{
    self.enabled = NO;

    if (!_smsTimer) {
        _smsTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(refreshSMSButtonTitle)
                                                   userInfo:nil
                                                    repeats:YES];
        _countdown = 1;
    }
    _counting = YES;

}

- (void)stopCounting
{
    [self stopCountingWithTitle:UP_STR(@"String_Card_ResendSMSVerificationCode")];
}

- (void)setEnabled:(BOOL)enabled
{
    if (_counting && enabled) {
        return;
    }
    [super setEnabled:enabled];
}

- (void)refreshSMSButtonTitle
{
    if (_countdown == 60) {
        [self stopCountingWithTitle:UP_STR(@"String_Card_ResendSMSVerificationCode")];
        return;
    }
    NSString* buttonTitle = [NSString stringWithFormat:@"%@%@",@(60 - _countdown),@"秒"];
    [self setTitle:buttonTitle forState:UIControlStateNormal];
    [self setNeedsLayout];
    _countdown ++;
}

- (void)stopCountingWithTitle:(NSString *)title
{
    [_smsTimer invalidate];
    self.smsTimer = nil;
    _counting = NO;
    self.enabled = YES;
    [self setTitle:title forState:UIControlStateNormal];
}

@end
