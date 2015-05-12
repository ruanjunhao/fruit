//
//  UPWSMSButton.h
//  wallet
//
//  Created by qcao on 14/10/28.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPWCardSMSButton : UIButton

+ (instancetype)smsButton;

// 启动倒计时
- (void)startCounting;

// 停止倒计时，恢复到初始状态
- (void)stopCounting;

@end
