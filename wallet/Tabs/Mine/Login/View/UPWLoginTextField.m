//
//  UPWLoginTextField.m
//  wallet
//
//  Created by qcao on 14/10/27.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWLoginTextField.h"

@implementation UPWLoginTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.borderStyle = UITextBorderStyleNone;
        self.font = [UIFont systemFontOfSize:16];
        self.textColor = UP_COL_RGB(0xffffff);
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.adjustsFontSizeToFitWidth = NO;
        self.placeHolderColor = [UIColor colorWithWhite:1.0 alpha:0.1];
        self.background = nil;
    }
    return self;
}
@end
