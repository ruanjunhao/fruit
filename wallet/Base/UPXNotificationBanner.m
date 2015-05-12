//
//  UPXBanner.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-9-27.
//
//

#import "UPXNotificationBanner.h"
#import "AppDelegate.h"
#import "UPWWelcomeViewController.h"

//#define kBannerWidth 320
#define kBannerHeight 38
#define kBannerLeftMargin 0
#define kBannerTopMargin -8 //默认0,0的位置  -10 , 上面留2个像素的边距ß
#define kBannerTimeout 5.0 //5秒后消失ß
#define kStatusBarHeight                  20

typedef void (^UPXNotificationBannerPresenterFinishedBlock)();

@class UPXNotificationBannerWindow;

static UPXNotificationBannerWindow* g_bannerWindow = nil;

@interface UPXNotificationBanner : NSObject

@property (nonatomic,copy) NSString* title;
@property (nonatomic,retain) UIImage* leftImage;
@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, copy) UPXNotificationBannerTapHandlingBlock tapHandler;

- (id)initWithTitle:(NSString*)title
              image:(UIImage*)image
         tapHandler:(UPXNotificationBannerTapHandlingBlock)tapHandler;
@end



@interface UPXNotificationBannerView : UIView{
    UIImageView*    _backgroundView;
    UIImageView*    _leftImageView;
    UIImageView*    _lineView;
    UILabel*        _titleLabel;
    UIButton*       _closeButton;
}
@property (nonatomic, retain) UPXNotificationBanner* notificationBanner;

- (id)initWithNotification:(UPXNotificationBanner*)notification;
- (void)dismiss;

@end

//需要显示在statusbar, alertview前面, 所以windowslevel 为UIWindowLevelStatusBar+2
@interface UPXNotificationBannerWindow : UIWindow

@property (nonatomic,retain) UIView* bannerView;

@end



@implementation UPXNotificationCenter

+ (UPXNotificationCenter*) sharedCenter{
    static UPXNotificationCenter* sharedCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCenter = [[[self class] alloc] init];
    });
    return sharedCenter;
}

+ (void)presentNotificationWithTitle:(NSString*)title
                               image:(UIImage *)image
                          tapHandler:(UPXNotificationBannerTapHandlingBlock)tapHandler {
    UPXNotificationBanner* notification = [[UPXNotificationBanner alloc] initWithTitle:title
                                                                                 image:image
                                                                            tapHandler:tapHandler];
    [[self sharedCenter] presentNotification:notification];
}

- (void)presentNotificationWithTitle:(NSString*)title
                                image:(UIImage*)image
                           tapHandler:(UPXNotificationBannerTapHandlingBlock)tapHandler {
    UPXNotificationBanner* notification = [[UPXNotificationBanner alloc]
                                           initWithTitle:title
                                           image:image
                                           tapHandler:tapHandler];
    [self presentNotification:notification];
}

- (void)presentNotification:(UPXNotificationBanner*)notification {
    
    if (g_bannerWindow) {
        return;
    }
    
    UPXNotificationBannerWindow* window = [self newWindow];
    
    g_bannerWindow = window;
    
    UPXNotificationBannerView* bannerView = [self newBannerViewForNotification:notification];
    
    UIViewController* bannerViewController = [[UIViewController alloc] init];
    window.rootViewController = bannerViewController;
    
    UIView* containerView = [self newContainerViewForNotification:notification];

    window.bannerView = bannerView;

    [containerView addSubview:bannerView];
    bannerViewController.view = containerView;
    
    containerView.bounds = [UIScreen mainScreen].bounds;

    
    CGSize bannerSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,kBannerHeight);
    
    float deltaY = 0.0f;
    if (UP_IOS_VERSION >= 7.0)
    {
        deltaY = kStatusBarHeight/2;
    }
    bannerView.frame = CGRectMake(kBannerLeftMargin, kBannerTopMargin + deltaY, bannerSize.width, bannerSize.height);
    
    // timeout 消失
    if (notification.timeout > 0.0) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, notification.timeout * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [bannerView dismiss];
        });
    }
}



- (UIView*)newContainerViewForNotification:(UPXNotificationBanner*)notification {
    UIView* container = [[UIView alloc] init];
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    container.userInteractionEnabled = YES;
    container.opaque = NO;
    return container;
}

- (UPXNotificationBannerView*)newBannerViewForNotification:(UPXNotificationBanner*)notification {
    UPXNotificationBannerView* view = [[UPXNotificationBannerView alloc]
                                       initWithNotification:notification];
    view.userInteractionEnabled = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin;
    return view;
}

- (UPXNotificationBannerWindow*)newWindow {
    UPXNotificationBannerWindow* window = [[UPXNotificationBannerWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    window.userInteractionEnabled = YES;
    window.autoresizesSubviews = YES;
    window.opaque = NO;
    window.hidden = NO;
    //需要显示在statusbar, alertview前面, 所以windowslevel 为UIWindowLevelStatusBar+2
    window.windowLevel = UIWindowLevelStatusBar+2;
    return window;
}


@end


@implementation UPXNotificationBanner

- (UPXNotificationBanner*)initWithTitle:(NSString*)title
                                  image:(UIImage*)image
                             tapHandler:(UPXNotificationBannerTapHandlingBlock)tapHandler {
    
    return [self initWithTitle:title image:image timeout:kBannerTimeout tapHandler:tapHandler];
}


- (UPXNotificationBanner*)initWithTitle:(NSString*)title
                                  image:(UIImage*)image
                                timeout:(NSTimeInterval)timeout
                             tapHandler:(UPXNotificationBannerTapHandlingBlock)tapHandler{
    
    self = [super init];
    if (self) {
        self.title = title;
        self.leftImage = image;
        self.timeout = timeout;
        self.tapHandler = tapHandler;
    }
    return self;
}

@end


@implementation UPXNotificationBannerView

- (id)initWithNotification:(UPXNotificationBanner*)notification {
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        UIImage* bg = [UP_GETIMG(@"banner_bg") stretchableImageWithLeftCapWidth:6 topCapHeight:19];
        _backgroundView = [[UIImageView alloc] initWithImage:bg];
        
        _leftImageView = [[UIImageView alloc] initWithImage:notification.leftImage];
        
        _lineView = [[UIImageView alloc] initWithImage:UP_GETIMG(@"banner_line")];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.text = notification.title;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:UP_GETIMG(@"banner_close") forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self addSubview:_backgroundView];
        [self addSubview:_leftImageView];
        [self addSubview:_lineView];
        [self addSubview:_titleLabel];
        [self addSubview:_closeButton];
        
        UITapGestureRecognizer* tapRecognizer;
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:tapRecognizer];
        self.notificationBanner = notification;
    }
    return self;
}


- (void)layoutSubviews {
    if (!(self.frame.size.width > 0)) { return; }
    _backgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    _leftImageView.frame = CGRectMake(10, 10, 18, 18);
    _lineView.frame = CGRectMake(36, 0, 1, 38);
    _titleLabel.frame = CGRectMake(45, 9, 240, 20);
    _closeButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-30, 10, 20, 20);
    
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.notificationBanner && self.notificationBanner.tapHandler) {
        self.notificationBanner.tapHandler();
    }
    [self dismiss];
}

- (void)dismiss {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.frame = CGRectOffset(self.frame, 0, -self.frame.size.height);
                         self.alpha = 0;
                     } completion:^(BOOL didFinish) {
                         [self removeFromSuperview];
                         // Break the retain cycle
                         self.notificationBanner.tapHandler = nil;
                     }];
}

@end



@implementation UPXNotificationBannerWindow

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView* superHitView = [super hitTest:point withEvent:event];
    if (superHitView == self.bannerView || superHitView.superview == self.bannerView) {
        return superHitView;
    }
    else {
        UIWindow* nextWindow = nil;
        BOOL useNextWindow = NO;
        for (UIWindow* window in [[UIApplication sharedApplication].windows reverseObjectEnumerator]) {
            if (useNextWindow) {
                nextWindow = window;
                break;
            }
            
            if ([window isKindOfClass:[UPXNotificationBannerWindow class]]) {
                useNextWindow = YES;
            }
        }
        
        if (nextWindow) {
            return [nextWindow hitTest:point withEvent:event];
        }
        else {
            return superHitView;
        }
    }
}

@end