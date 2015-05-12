//
//  UPWActionSheet.m
//  wallet
//
//  Created by jhyu on 14/12/22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWActionSheet.h"
#import "UPXConstKey.h"

@implementation UPWActionSheet

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [UP_NC addObserver:self selector:@selector(closeActionSheet) name:kNCEnterBackground object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [UP_NC removeObserver:self name:kNCEnterBackground object:nil];
}

- (void)closeActionSheet
{
    [self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:NO];
}

@end
