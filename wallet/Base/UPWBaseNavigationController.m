//
//  UPWNavigationController.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWBaseNavigationController.h"

#import "UPWHomeViewController.h"
#import "UPWFruitViewController.h"
#import "UPWShoppingCartViewController.h"
#import "UPWMineViewController.h"
#import "UPXViewUtils.h"

@interface UPWBaseNavigationController ()
{
    BOOL _isTransiting;

}

@end

@implementation UPWBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

//    if (UP_iOSgt7) {
//        //透明 毛玻璃效果
//        [self.navigationBar.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            if ([obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
//                [[obj subviews] enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx, BOOL *stop) {
//                    if ([obj2 isKindOfClass:[UIImageView class]]) {
//                        UIImageView* imgView = (UIImageView*)obj2;
//                        if (imgView.frame.size.height == 0.5) {
//                            imgView.hidden = YES;
//                        }
//                    }
//                }];
//            }
//        }];
//        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, -kStatusBarHeight, CGRectGetWidth(self.navigationBar.frame), kStatusBarHeight+kNavigationBarHeight)];
//        view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.55f];
//        view.userInteractionEnabled = NO;
//        [self.navigationBar insertSubview:view atIndex:0];
//    }
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 多点触摸同时点击，会导致UPNavigationController 栈乱序，APP Crash，下面的处理过滤掉TabBar上的四个viewController
   
    NSArray* tabViewController = @[NSStringFromClass([UPWHomeViewController class]),
                                   NSStringFromClass([UPWFruitViewController class]),
                                   NSStringFromClass([UPWShoppingCartViewController class]),
                                   NSStringFromClass([UPWMineViewController class])];
    
    BOOL isTabVC = NO;
    for (NSString* tabClassName in tabViewController)
    {
        if ([NSStringFromClass([viewController class]) isEqualToString:tabClassName]) {
            isTabVC = YES;
            break;
        }
    }
    
    if (isTabVC) {
        [super pushViewController:viewController animated:YES];
    }
    else
    {
        // 禁止连续pushViewController
        if (_isTransiting) {
            return;
        }
        _isTransiting = YES;
        
        [super pushViewController:viewController animated:animated];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _isTransiting = NO;
        });
    }
}

- (UIViewController*)pushViewControllerByClass:(Class)cls removeVC:(UIViewController*)removeVC
{
    UIViewController* nextVC = [UPXViewUtils viewController:self ofClass:cls];
    if (!nextVC) {
        //没有在view stack中, new出来
        nextVC = [[cls alloc] init];
        
        NSMutableArray* vcs = [self.viewControllers mutableCopy];
        if (removeVC) {
            [vcs removeObject:removeVC];
        }
        [vcs addObject:nextVC];
        [self setViewControllers:vcs animated:YES];
    }
    else{
        [self popToViewController:nextVC animated:YES];
    }
    
    return nextVC;
}

@end
