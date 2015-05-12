//
//  UPWPaymentSharePanel.m
//  wallet
//
//  Created by jhyu on 14/11/5.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWPaymentSharePanel.h"
#import "UPXCheckBox.h"
#import "UPXConstLayout.h"

static NSString * const kPaymentShareSwitch = @"kPaymentShareSwitch";

@interface UPWPaymentSharePanel () {
    UPXCheckBox* _checkBox;
}

@end

@implementation UPWPaymentSharePanel

- (void)show
{
    [super show];
    
    CGRect rc = ((UIView *)_overlayView.subviews.firstObject).frame;
    rc.origin.y = _overlayView.bounds.size.height / 2;
    rc.size.height = 22;
    _checkBox = [[UPXCheckBox alloc] initWithFrame:rc text:UP_STR(@"以后不再分享")];
    [_checkBox setTouchRect:UIEdgeInsetsMake(-kFormItemMultiBillContextMarginY, -kFormItemMultiBillContextMarginX, -kFormItemMultiBillContextMarginY, -kFormItemMultiBillContextMarginX)];
    //[_checkBox addTarget:self action:@selector(toggleAction:)];
    _checkBox.isChecked = NO;
}

- (void)toggleAction:(id)sender
{
    
}

- (void)dismiss
{
    [super dismiss];
    
    if(_checkBox.isChecked) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPaymentShareSwitch];
    }
}

@end
