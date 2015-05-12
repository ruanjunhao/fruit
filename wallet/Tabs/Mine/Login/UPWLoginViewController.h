//
//  UPWLoginViewController.h
//  wallet
//
//  Created by qcao on 14/10/27.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPFormBaseViewController.h"

typedef void (^completionBlock)(void);

@interface UPWLoginViewController : UPFormBaseViewController

@property (nonatomic, strong) completionBlock successBlock;//登录成功 block
@property (nonatomic, strong) completionBlock cancelBlock;//取消登录 block

- (void)fillinUserName:(NSString*)name password:(NSString*)password;

// 打开注册页面
- (void)openRegisterPage;

@end
