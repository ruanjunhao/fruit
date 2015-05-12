//
//  UPWNavigationController.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPWBaseNavigationController : UINavigationController

- (UIViewController*)pushViewControllerByClass:(Class)cls removeVC:(UIViewController*)removeVC;

@end
