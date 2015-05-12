//
//  UPWBaseViewController.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPWHttpMgr.h"
#import "UPXAlertView.h"
#import "UPWConst.h"
#import "UPWLoadingView.h"
#import "UPXConstKey.h"

@interface UPWBaseViewController : UIViewController
{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    // 放置各种subView
    UIView* _contentView;
    UIView* _loadingView;
    CGFloat _topOffset;
    UPWLoadingView* _loadingView2;

}

//@property(nonatomic,retain) UIActivityIndicatorView* activityView;
@property(nonatomic, strong, readonly) UIView * contentView;

//设置导航栏标题
- (void)setNaviTitle:(NSString*)title;
- (void)setNaviImage:(NSString*)image;
- (void)setNaviTitleView:(UIView *)view;

//设置导航栏左右按钮
- (void)setLeftButtonWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)action;
- (void)setRightButtonWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)action;
- (void)setRightButtonWithImage:(NSString*)imageName target:(id)target action:(SEL)action;
- (void)addBackButton;
- (void)backAction:(id)sender;
- (void)removeLeftButton;
- (void)removeRightButton;

#pragma mark -
#pragma mark 对话框/等待框相关函数
- (void)showWaitingView:(NSString*)title;
- (void)hideWaitingView;

- (void)showLoadingWithMessage:(NSString*)message;
- (void)dismissLoading;

- (void)showLoadingView2;
- (void)showLoadingView2WithCenter:(CGPoint)pt;
- (void)dismissLoading2;


- (void)showFlashInfo:(NSString*)info;
- (void)showFlashInfo:(NSString*)info withDismissBlock:(dispatch_block_t)dismissBlock;

- (void)showFlashInfo:(NSString*)info withImage:(UIImage*)image;
- (void)showFlashInfo:(NSString*)info withImage:(UIImage*)image withDismissBlock:(dispatch_block_t)dismissBlock;

- (UPXAlertView*)showAlertWithTitle:(NSString*)title
                   message:(NSString*)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
          otherButtonTitle:(NSString *)otherButtonTitle
             completeBlock:(UPXAlertViewBlock)block;

- (void)dismissAll;

- (NSString*)codeWithError:(NSError*)error;
- (NSString*)msgWithError:(NSError*)error;
- (NSDictionary*)detailWithError:(NSError*)error;
- (NSString*)stringWithError:(NSError*)error;

#pragma mark - 登录超时, 登录被踢出

- (void)handleLoginKicked:(NSNotification*)notification;

#pragma mark - 已发送消息进队，方便后续的cancel操作

- (void)addMessage:(UPWMessage*)msg;

- (void)cancelPendingMessages;

#pragma mark - 页面采集

- (void)trackPageBegin;

- (void)trackPageEnd;

@end
