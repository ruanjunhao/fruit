//
//  UPWBillWebPageViewController.h
//  CHSP
//
//  Created by jhyu on 13-10-25.
//
//

#import "CDVViewController.h"
#import "UPWWebData.h"
#import "UPWAppInfoModel.h"
#import "UPXWebAppAlertViewDelegate.h"

/*
 * UPWBillWebPageViewController主要用于展示与票券相关的详情页面，包含响应对票券操作的事件。
 *
 */
@interface UPWBillWebPageViewController : CDVViewController

// 整合随行里面的一些特殊需求，以及逻辑。
@property (nonatomic,weak) id<UPXWebAppAlertViewDelegate> webAppAlertViewDelegate;

// 设置NavigationBar的Title
@property (nonatomic,copy) NSString* title;

// 网页加载时，是否显示LoadingView，加载结束LoadingView消失，非阻塞
@property (nonatomic,assign) BOOL isLoadingView;

// 网页加载时，是否显示WaitingView，加载结束WaitingView消失，阻塞
@property (nonatomic,assign) BOOL isWaitingView;

//打开web app的view controller, 在js的closeWebApp调用后返回到这个vc
@property(nonatomic,assign) UIViewController* webAppHolder;

@property (nonatomic,strong) UPWAppInfoModel *appInfo;

@property(nonatomic,assign) BOOL hasToolbar;


- (id)initWithWebData:(UPWWebData *)webData;

// 插件里面需要调用这个方法来进行分享。
- (void)openSharePanel;

// 页面刷新
- (void)refreshPageAfterLoginSucceed;


#pragma mark -
#pragma mark 关闭web app, 返回web app holder
- (void)closeWebApp:(NSDictionary*)info;

- (void)getOrderPreHandle:(NSString *)tn;
// 发送order.postHandle 支付完毕后上送
- (void)getOrderPostHandle;

- (void)setNavigationBarHidden:(BOOL)hideNavigationBar;
- (void)setToolBarHidden:(BOOL)hideToolBar;

@end
