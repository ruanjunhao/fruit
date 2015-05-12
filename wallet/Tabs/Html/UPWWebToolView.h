//
//  UPWWebToolView.h
//  UPWallet
//
//  Created by jhyu on 14-9-24.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import <UIKit/UIKit.h>

// WEB底部导航栏

#define kWebToolViewHeight 44

@protocol UPWWebToolViewDelegate <NSObject>

@optional
// 加载完前一个WEB页面
- (void)didLoadBackPageContent;

// 加载完后一个WEB页面
- (void)didLoadForwardPageContent;

@end

@class UPWWebViewController;

@interface UPWWebToolView : UIView

- (instancetype)initWithWebViewController:(UPWWebViewController *)webVC;
// 更新back, forward等按钮的状态。
- (void)updateBtnsStatus;

@property (nonatomic, readonly) UIButton * btnGoBack;
@property (nonatomic, readonly) UIButton * btnGoForward;
@property (nonatomic, readonly) UIButton * btnReload;

@property (nonatomic, weak) id<UPWWebToolViewDelegate> delegate;

@end
