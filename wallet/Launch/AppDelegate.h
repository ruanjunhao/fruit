//
//  AppDelegate.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, UPDeviceTokenPrerequisite) {
    UPDeviceTokenPrerequisiteNone              = 0,
    UPDeviceTokenPrerequisiteSysInit           = 1 << 0,
    UPDeviceTokenPrerequisiteRegisterSuccess   = 1 << 1
};

@class UPWWelcomeViewController;
@class UPXPatternLockViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;

//支付控件是否显示,如果显示支付控件，则有推送账单消息时不提示等到消失之后再提示
@property (assign, nonatomic) BOOL isUPPayPluginShow;



//纪录服务器推送过来的信息
@property (nonatomic, retain) NSDictionary *remoteNotificationUserInfo;
@property (strong, nonatomic) UIViewController* visibleController;
@property (strong, nonatomic) UPWWelcomeViewController* rootViewController;
@property (nonatomic, retain) UIImageView *cover;
@property (nonatomic, strong) UPXPatternLockViewController *lockVC;

- (void)handlePushMessageInfo;
- (void)trySendUploadDeviceToken:(UPDeviceTokenPrerequisite)item;
- (void)loadWelcomeview;

@end

