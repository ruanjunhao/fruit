//
//  UPCheckButton.m
//  UPWallet
//
//  Created by wxzhao on 14-7-16.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWCheckButton.h"

@implementation UPWCheckButton

@synthesize  isChecked;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor clearColor];
        self.isChecked = YES;
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:@"authen_check"] forState:UIControlStateNormal];
        [self addSubview:btn];
    }
    return self;
}

- (void)buttonAction:(id)sender
{
    self.isChecked = !self.isChecked;

    if (self.isChecked) {
        [sender setBackgroundImage:[UIImage imageNamed:@"authen_check"] forState:UIControlStateNormal];
    }
    else
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"authen_uncheck"] forState:UIControlStateNormal];
    }
}




@end
