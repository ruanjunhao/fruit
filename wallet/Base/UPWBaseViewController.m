//
//  UPWBaseViewController.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWBaseViewController.h"
#import "NSString+UPEx.h"
#import "UPXWaitingView.h"
#import "UPXToast.h"
#import "UPWUiUtil.h"
#import "UPWNotificationName.h"

/* 定义一般Toast宽高 */
#define kCommonToastSize CGSizeMake(120, 30)

@interface UPWBaseViewController ()
{
    NSMutableArray* _toastArray;//toast
    NSMutableArray* _waitingViewArray;//waitingView
    NSMutableArray* _messageOperationArray;

}
@end

@implementation UPWBaseViewController

@synthesize contentView = _contentView;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;

        _toastArray = [[NSMutableArray alloc] initWithCapacity:5];
        _waitingViewArray = [[NSMutableArray alloc] initWithCapacity:5];
        
        _topOffset = UP_iOSgt7 ? (kNavigationBarHeight + kStatusBarHeight) : 0;

    }
    return self;
}

- (void)dealloc
{
    [self cancelPendingMessages];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    页面采集开始
    [self trackPageBegin];
   
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//   页面采集关闭
    [self trackPageEnd];
}

- (void)trackPageBegin
{
    
}

- (void)trackPageEnd
{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self addBackButton];
    [self setupContentView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _screenWidth = _contentView.frame.size.width;
    _screenHeight = _contentView.frame.size.height;
    
    if (UP_iOSgt7) {
        //使 contentView 从屏幕(0, 0)开始计算, 如果设为 None 会从导航栏底部开始计算, 设为 Top 使下面的 view 可以透过导航栏看到
        self.edgesForExtendedLayout = UIRectEdgeTop;
        //automaticallyAdjustsScrollViewInsets 只对 viewController 的 view 有效, contentView 上的 scrollview 无效
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    
    if (!UP_iOSgt7)
    {
        UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backAction:)];
        [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self.view addGestureRecognizer:gestureRecognizer];
    }
    
    // iOS6以后的系统，取消默认的阴影条
    if (!UP_iOSgt7) {
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginKicked:) name:kNotificationLoginKicked object:nil];
}

#pragma mark - 建立contentView
- (void)setupContentView
{
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    if (!UP_iOSgt7) {
        height -= kNavigationBarHeight;
    }
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _contentView.backgroundColor = UP_COL_RGB(0xf0f0f0);
    [self.view addSubview:_contentView];
    
}

#pragma mark -
#pragma mark 设置UINavigationBar title
- (void)setNaviTitle:(NSString *)title
{
    if (!title) {
        return;
    }
    
    CGSize titleSize = [title frameForFont:[UIFont systemFontOfSize:20]];
    UILabel* titleView = [[UILabel alloc] initWithFrame:CGRectMake((_screenWidth - titleSize.width)/2, 0, titleSize.width, kNavigationBarHeight)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.textColor = [UIColor whiteColor];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.text = title;
    titleView.font = [UIFont systemFontOfSize:17];
    self.navigationItem.titleView = titleView;
}

- (void)setNaviImage:(NSString *)imageName
{
    UIImage* image = [UIImage imageNamed:imageName];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, (kNavigationBarHeight - image.size.height)/2, image.size.width, image.size.height);
    self.navigationItem.titleView = imageView;
}

- (void)setNaviTitleView:(UIView *)view
{
    UIBarButtonItem *leftBarButtonItem = UP_iOSgt7?self.navigationItem.leftBarButtonItems[1]:self.navigationItem.leftBarButtonItems[0];
    CGRect leftBounds = leftBarButtonItem.customView.bounds;
    UIBarButtonItem *rightBarButtonItem = UP_iOSgt7?self.navigationItem.rightBarButtonItems[1]:self.navigationItem.rightBarButtonItems[0];
    CGRect rightBounds = rightBarButtonItem.customView.bounds;
    CGFloat lrWidth = (leftBounds.size.width>rightBounds.size.width)?leftBounds.size.width:rightBounds.size.width;
    CGFloat maxWidth = _screenWidth-2*lrWidth;
    
#warning 对frame的修改似乎没效果
    CGRect viewFrame = view.frame;
    viewFrame.size.width = (viewFrame.size.width > maxWidth)?maxWidth:viewFrame.size.width;
    viewFrame.size.height = (viewFrame.size.height > kNavigationBarHeight)?kNavigationBarHeight:viewFrame.size.height;
    viewFrame.origin.x = (_screenWidth-viewFrame.size.width)/2;
    viewFrame.origin.y = (kNavigationBarHeight-viewFrame.size.height)/2;
    view.frame = viewFrame;
    [view setNeedsLayout];
    self.navigationItem.titleView = view;
}

#pragma mark -
#pragma mark 添加返回按钮

- (void)addBackButton
{
    if (UP_iOSgt7) {
        // iOS7 用此技巧取消back button title
        self.navigationItem.title = @" ";
    }
    else
    {
        NSInteger count = [self.navigationController.viewControllers count];
        if (count >= 2)
        {
            [self setLeftButtonWithImageName:@"btn_back" title:nil target:self action:@selector(backAction:)];
        }
    }
}

// backAction只在iOS5，6上会被调用，不能被子类重载
- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark 设置UINavigationBar上的左右按钮

- (void)setLeftButtonWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)action
{
    UIButton* button = [self barButtonItemWithImageName:imageName title:title];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    button.exclusiveTouch = YES;
    
    if (UP_iOSgt7) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,barButtonItem, nil];
    }
    else {
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:barButtonItem, nil];
    }
}

- (void)setRightButtonWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)action
{
    UIButton* button = [self barButtonItemWithImageName:imageName title:title];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    button.exclusiveTouch = YES;
    
    if (UP_iOSgt7) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,barButtonItem, nil];
    }
    else {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:barButtonItem, nil];
    }
}

- (void)setRightButtonWithImage:(NSString*)imageName target:(id)target action:(SEL)action
{
    UIButton* button = [self barButtonItemWithImage:imageName];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    button.exclusiveTouch = YES;
    
    if (UP_iOSgt7) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,barButtonItem, nil];
    }
    else {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:barButtonItem, nil];
    }
}

- (UIButton*)barButtonItemWithImageName:(NSString*)imageName title:(NSString*)title
{
    //NavigationBar上左右按钮最长文字为4
    int  maxNavigationItemNameLength  = 6;
    int  fontSize = 13;
    
    if(title.length > maxNavigationItemNameLength) {
        
        title = [title substringToIndex:maxNavigationItemNameLength];
        
    }

    CGSize titleSize = [title frameForFont:[UIFont systemFontOfSize:fontSize]];
    
    UIImage* image = nil;
    if (!UP_IS_NIL(imageName)) {
        image = UP_GETIMG(imageName);
    }
    UIButton* btnView = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat x = 10;
    CGFloat y = 0;
    CGFloat width = 0;
    CGFloat height = kNavigationBarHeight;
    if (image && !title) {
        // 只有图片时，加大点击区域
        width = 5 + image.size.width + 5;
        if (UP_iOSgt7) {
            //6上面的 back 键太靠左
            x = -6;
        }
    }
    else if (image && title) {
        width = 5 + image.size.width + 5 + titleSize.width + 5;
        x = 0;
    }
    else {
        // 只有文字是，加大点击区域
        width = 5 + titleSize.width + 5;
    }
    width = MIN(width, 120);
    CGFloat offsetY = UP_iOSgt7 ? 20 : 0;
    btnView.frame = CGRectMake(0, offsetY, width, height);
    
    UIImageView* imageView = nil;
    if (imageName) {
        y = (height - image.size.height)/2;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, image.size.width, image.size.height)];
        imageView.image = image;
        imageView.userInteractionEnabled = NO;
        [btnView addSubview:imageView];
        x += imageView.frame.size.width;

    }
    
    
    if (title) {
        y = (height - titleSize.height)/2;
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, titleSize.width, titleSize.height)];
        label.text = title;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:fontSize];
        label.backgroundColor = [UIColor clearColor];
        label.userInteractionEnabled = NO;
        [btnView addSubview:label];
    }
    

    btnView.exclusiveTouch = YES;
    
    return btnView;
}

- (UIButton*)barButtonItemWithTitle:(NSString*)title imageName:(NSString*)imageName
{
    int fontSize = 15;
    CGSize titleSize = [title frameForFont:[UIFont systemFontOfSize:fontSize]];
    UIImage* image = [UIImage imageNamed:imageName];
    UIButton* btnView = [UIButton buttonWithType:UIButtonTypeCustom];
    btnView.backgroundColor = [UIColor clearColor];
    
    CGFloat x = 5;
    CGFloat y = 0;
    CGFloat width = 0;
    CGFloat height = kNavigationBarHeight;
    if (image && !title) {
        // 只有图片时，加大点击区域
        width = 5+ image.size.width + 5;
    }
    else if (image && title) {
        width = 5 + image.size.width + 5 + titleSize.width + 5;
    }
    else {
        // 只有文字是，加大点击区域
        width = 5 + titleSize.width + 5;
    }
    width = MIN(width, 120);
    CGFloat offsetY = UP_iOSgt7 ? 20 : 0;
    btnView.frame = CGRectMake(0, offsetY, width, height);
    
    UIImageView* imageView = nil;
    if (imageName) {
        y = (height - image.size.height)/2;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, image.size.width, image.size.height)];
        imageView.image = image;
        imageView.userInteractionEnabled = NO;
        [btnView addSubview:imageView];
        x += imageView.frame.size.width + 5;
    }
    
    if (title) {
        y = (height - 18)/2;
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, titleSize.width, titleSize.height)];
        label.text = title;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:fontSize];
        label.backgroundColor = [UIColor clearColor];
        label.userInteractionEnabled = NO;
        [btnView addSubview:label];
    }
    
    btnView.exclusiveTouch = YES;
    
    return btnView;
}

- (UIButton*)barButtonItemWithImage:(NSString*)imageName
{
    if (UP_IS_NIL(imageName)) {
        UPDERROR(@"barButtonItemWithImage empty imageName");
        return nil;
    }
    UIImage* image = [UIImage imageNamed:imageName];
    UIButton* btnView = [UIButton buttonWithType:UIButtonTypeCustom];
    btnView.backgroundColor = [UIColor clearColor];
    
    CGFloat width = 0;
    CGFloat height = kNavigationBarHeight;
    if (image) {
        width = image.size.width;
    }
    CGFloat offsetY = UP_iOSgt7 ? 20 : 0;
    btnView.frame = CGRectMake(0, offsetY, width, height);
    
    UIImageView* imageView = nil;
    CGFloat x = 0;
    CGFloat y = (height - image.size.height)/2;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, image.size.width, image.size.height)];
    imageView.image = image;
    imageView.userInteractionEnabled = NO;
    [btnView addSubview:imageView];
    btnView.exclusiveTouch = YES;
    return btnView;
}

- (void)removeLeftButton
{
    self.navigationItem.leftBarButtonItems = nil;
}

- (void)removeRightButton
{
    self.navigationItem.rightBarButtonItems = nil;
}

#pragma mark -
#pragma mark AlertView, Toast, Loading 相关函数


- (void)showWaitingView:(NSString*)title
{
    UPDINFO(@"showWaitingView : %@", title);
    if (!UP_IS_NIL(title)) {
        UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
        CGRect rt = window.bounds;
        UPXWaitingView *waitView = [[UPXWaitingView alloc] initWithFrame:rt];
        waitView.title = title;
        [_waitingViewArray addObject:waitView];
        [waitView show];
//        UP_RELEASE(waitView);
    }
}


- (void)hideWaitingView
{
    UPDINFO(@"hideWaitingView");
    [_waitingViewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj hide];
    }];
    [_waitingViewArray removeAllObjects];
}



- (void)showLoadingView2
{
    UPDINFO(@"showLoadingView2");
    [self dismissLoading2];
    CGFloat loadingWidth = UPFloat(50);
    CGFloat loadingHeight = UPFloat(50);
    if (!_loadingView2) {
        _loadingView2 = [[UPWLoadingView alloc] initWithFrame:CGRectMake((_screenWidth-loadingWidth)/2, (_screenHeight-loadingHeight)/2, loadingWidth, loadingHeight)];
        [_contentView addSubview:_loadingView2];
    }
    [_loadingView2 startAnimation];
}

- (void)showLoadingView2WithCenter:(CGPoint)pt
{
    UPDINFO(@"showLoadingView2WithCenter %@",NSStringFromCGPoint(pt));
    [self dismissLoading2];
    CGFloat loadingWidth = UPFloat(50);
    CGFloat loadingHeight = UPFloat(50);
    if (!_loadingView2) {
        _loadingView2 = [[UPWLoadingView alloc] initWithFrame:CGRectMake(pt.x-loadingWidth/2, pt.y-loadingHeight/2, loadingWidth, loadingHeight)];
        [_contentView addSubview:_loadingView2];
    }
    [_loadingView2 startAnimation];
}

- (void)dismissLoading2
{
    UPDINFO(@"dismissLoading2");
    if (_loadingView2) {
        [_loadingView2 stopAnimation];
        [_loadingView2 removeFromSuperview];
        _loadingView2 = nil;
    }
}

- (void)showLoadingWithMessage:(NSString*)message
{
    UPDINFO(@"showLoadingWithMessage:%@",message);

    [self dismissLoading];
    
    CGFloat offset = 5;
    CGFloat aivWidth = 30;
    CGFloat aivHeight = 30;
    
    CGFloat loadingViewWidth = 210;
    CGSize messageSize = [message sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake((loadingViewWidth-aivWidth-offset), MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat loadingViewHeight = messageSize.height;
    
    _loadingView = [[UIView alloc] initWithFrame:CGRectMake((_screenWidth-loadingViewWidth)/2, (_screenHeight-loadingViewHeight)/2, loadingViewWidth, loadingViewHeight)];
    _loadingView.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_loadingView];
    
    UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [aiv setFrame:CGRectMake((loadingViewWidth-(aivWidth+messageSize.width+offset))/2, (loadingViewHeight-aivHeight)/2, aivWidth, aivHeight)];
    [_loadingView addSubview:aiv];
    [aiv startAnimating];
    
    CGFloat x = aiv.frame.origin.x + aivWidth + offset;
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, loadingViewWidth-x, loadingViewHeight)];
    label.text = message;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:14];
    [_loadingView addSubview:label];
}

- (void)dismissLoading
{
    UPDINFO(@"dismissLoading");
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
}

- (void)hideFlashInfo
{
    [_toastArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeToast];
    }];
    [_toastArray removeAllObjects];
}

- (void)showFlashInfo:(NSString*)info
{
    [self showFlashInfo:info withDismissBlock:nil];
}

- (void)showFlashInfo:(NSString*)info withDismissBlock:(dispatch_block_t)dismissBlock
{
    UPDINFO(@"showFlashInfo:%@",info);
    
    [self hideFlashInfo];
    if (!UP_IS_NIL(info)) {
        CGSize size = UPSize(kCommonToastSize);
        UPXToast* toast = [[[[[UPXToast makeText:info]
                              setGravity:kToastGravityCenter]
                             setDuration:kToastDurationNormal]
                            setSize:size] setImage:nil];
        [toast show];
        [_toastArray addObject:toast];
        
        // 执行dismissBlock
        [self executeDismissBlock:dismissBlock withToast:toast];
    }
}

- (void)executeDismissBlock:(dispatch_block_t)dismissBlock withToast:(UPXToast *)toast
{
    if(dismissBlock) {
        dispatch_time_t delayInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, toast.theSettings.duration);
        dispatch_after(delayInNanoSeconds, dispatch_get_main_queue(), ^{
            dismissBlock();
        });
    }
}

- (void)showFlashInfo:(NSString*)info withImage:(UIImage*)image
{
    [self showFlashInfo:info withImage:image withDismissBlock:nil];
}

- (void)showFlashInfo:(NSString*)info withImage:(UIImage*)image withDismissBlock:(dispatch_block_t)dismissBlock
{
    UPDINFO(@"showFlashInfo:%@ withImage %@",info, image);
    [self hideFlashInfo];
    if (!UP_IS_NIL(info) || image) {
        CGSize size = kCommonToastSize;
        UPXToast* toast = [[[[[UPXToast makeText:info]
                              setGravity:kToastGravityCenter]
                             setDuration:kToastDurationNormal]
                            setSize:size] setImage:image];
        [toast show];
        [_toastArray addObject:toast];
        
        [self executeDismissBlock:dismissBlock withToast:toast];
    }
}

- (UPXAlertView*)showAlertWithTitle:(NSString*)title message:(NSString*)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle completeBlock:(UPXAlertViewBlock)block
{
    NSArray* otherTitles = nil;
    if (!UP_IS_NIL(otherButtonTitle)) {
        otherTitles = @[otherButtonTitle];
    }
    return [UPWUiUtil showAlertViewWithTitle:title message:message customView:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherTitles special:-1 tag:-1 completeBlock:block];
}


- (void)dismissAll
{
    UPDINFO(@" \n\n dismiss %@ ",NSStringFromClass([self class]));
    [self hideWaitingView];
    [self dismissLoading];
    [self hideFlashInfo];
}

#pragma mark - app进入后台, 处理alert于手势密码的冲突

- (void)appEnterBackground
{
//    if ([UPXPatternLockManager currentUserOpenPatternLock]) {
//        //这个输入框如果不消失, 弹出手势密码会被alert覆盖
//        [_alertArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            UPXAlertView* alert = (UPXAlertView*)obj;
//            [alert hideAnimated:NO];
//            alert.delegate = nil;
//        }];
//        
//        [_alertArray removeAllObjects];
//    }
}

#pragma mark - 已发送消息进队，方便后续的cancel操作

- (void)addMessage:(UPWMessage*)msg
{

    if (!_messageOperationArray) {
        _messageOperationArray = [[NSMutableArray alloc] init];
    }
    if (msg) {
        [_messageOperationArray addObject:msg];
    }
}

- (void)cancelPendingMessages
{
    for (UPWMessage* msg in _messageOperationArray) {
        [[UPWHttpMgr instance] cancelMessage:msg];
    }
    [_messageOperationArray removeAllObjects];
}

#pragma mark - 将NSError 转化成String

- (NSString*)codeWithError:(NSError*)error
{
    // 服务器端有些时候传过来的error code不是NSString类型，而是NSNumber类型。
    id code = [[error userInfo] objectForKey:NSLocalizedFailureReasonErrorKey];
    NSString * strCode = nil;
    
    if([code isKindOfClass:[NSString class]]) {
        strCode = code;
    }
    else if([code isKindOfClass:[NSNumber class]]) {
        strCode = [code stringValue];
    }
    
    return strCode;
}

- (NSString*)msgWithError:(NSError*)error
{
    NSString* msg = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
    return msg;
}

- (NSDictionary*)detailWithError:(NSError*)error
{
    NSDictionary* detail = [[error userInfo] objectForKey:kDetailError];
    return detail;
    
}

- (NSString*)stringWithError:(NSError*)error
{
    NSString* msg = [self msgWithError:error];
    
#ifdef UP_BUILD_FOR_DEVELOP
    NSString* code = [self codeWithError:error];
    return [NSString stringWithFormat:@"%@[%@]",msg,code];
#else
    return msg;
#endif
    
}

#pragma mark - 处理登录超时和踢出
- (void)handleLoginKicked:(NSNotification*)notification
{
    [self hideWaitingView];
    [self dismissLoading2];
}

@end
