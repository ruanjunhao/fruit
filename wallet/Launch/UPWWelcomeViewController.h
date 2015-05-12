//
//  UPWWelcomeViewController.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWBaseViewController.h"

@interface UPWWelcomeViewController : UPWBaseViewController



@property (nonatomic, strong) UITabBarController* tabBarController;

@property (nonatomic, strong) UIImageView *dotImage;

- (void)checkVersion:(NSString*)flag;

- (void) showPushInfoOnMineTab;

- (void) hidePushInfoOnMineTab;

@end
