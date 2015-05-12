//
//  UPSmsButton.h
//  UPWallet
//
//  Created by wxzhao on 14-7-12.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPWSmsButton : UIButton

@property(nonatomic,strong)UITextField* phoneNumber;

- (void)startTimerWithInterval:(NSInteger)interval;
- (void)stopTimer;

@end
