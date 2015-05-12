//
//  UPWAddToCartWebViewController.m
//  wallet
//
//  Created by gcwang on 15/4/4.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWAddToCartWebViewController.h"
#import "UPWWebViewController.h"
#import "UPWBaseNavigationController.h"
#import "UPWShoppingCartViewController.h"
#import "UPWAddToCartPanel.h"
#import "UPWShoppingCartModel.h"
#import "UPWFileUtil.h"
#import "UPWPathUtil.h"
#import "UPWNotificationName.h"
#import "UPWBussUtil.h"

@interface UPWAddToCartWebViewController ()
{
    UPWAddToCartPanel *_addToCartPanel;
    UPWFruitListCellModel *_fruitCellModel;
    UPWShoppingCartModel *_cartModel;
}

@end

@implementation UPWAddToCartWebViewController

- (id)initWithCellModel:(UPWFruitListCellModel *)cellModel
{
    self = [super init];
    if (self) {
        _fruitCellModel = [[UPWFruitListCellModel alloc] initWithDictionary:cellModel.toDictionary error:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNaviTitle:@"详情"];
    
    UPWWebViewController *webVC = [[UPWWebViewController alloc] init];
    webVC.startPage = self.startPage;
    [self addChildViewController:webVC];
    [self.view addSubview:webVC.view];
    
//    UPWBaseNavigationController *cartNaviVC = self.tabBarController.viewControllers[2];
//    UPWShoppingCartViewController *shoppingCartVC = (UPWShoppingCartViewController *)cartNaviVC.viewControllers[0];
    _cartModel = [[UPWShoppingCartModel alloc] initWithDictionary:[UPWFileUtil readContent:[UPWPathUtil shoppingCartPlistPath]] error:nil];
    
    UPWAddToCartWebViewController __weak *wself = self;
    _addToCartPanel = [[UPWAddToCartPanel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_contentView.frame)-kHeightAddToCartPanel, CGRectGetWidth(_contentView.frame), kHeightAddToCartPanel)];
    _addToCartPanel.backgroundColor = [UIColor whiteColor];
    _addToCartPanel.addToCartActionBlock = ^(){
        [wself addToCart];
    };
    
    NSInteger badgeValue= 0;
    for (UPWShoppingCartCellModel *cellModel in _cartModel.data) {
        badgeValue += cellModel.fruitNum.integerValue;
    }
    _addToCartPanel.fruitNum = [NSNumber numberWithInteger:badgeValue].stringValue;//shoppingCartVC.fruitNum?shoppingCartVC.fruitNum:
    [self.view addSubview:_addToCartPanel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 放入购物车
- (void)addToCart
{
    //添加放入购物车动画
    //get the location of label in table view
    CGPoint lbCenter = CGPointMake(260, CGRectGetHeight(_contentView.frame)-44);
    
    //the image which will play the animation soon
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"head_image"]];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.frame = CGRectMake(0, 0, 30, 30);
    imageView.hidden = YES;
    imageView.center = lbCenter;
    
    //the container of image view
    CALayer *layer = [[CALayer alloc]init];
    layer.contents = imageView.layer.contents;
    layer.frame = imageView.frame;
    layer.opacity = 1;
    [self.view.layer addSublayer:layer];
    
    //    CGPoint btnCenter = carButton.center;
    //动画 终点 都以sel.view为参考系
    CGPoint endpoint = CGPointMake(44, CGRectGetHeight(_contentView.frame)+15);//[self.view convertPoint:btnCenter fromView:carBG];
    UIBezierPath *path = [UIBezierPath bezierPath];
    //动画起点
    CGPoint startPoint = lbCenter;//[self.view convertPoint:lbCenter fromView:_freshFruitTableView];
    [path moveToPoint:startPoint];
    //贝塞尔曲线控制点
    float sx = startPoint.x;
    float sy = startPoint.y;
    float ex = endpoint.x;
    float ey = endpoint.y;
    float x = sx + (ex - sx) / 3;
    float y = sy + (ey - sy) * 0.5 - 400;
    CGPoint centerPoint=CGPointMake(x, y);
    [path addQuadCurveToPoint:endpoint controlPoint:centerPoint];
    
    //key frame animation to show the bezier path animation
    CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path.CGPath;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 0.8;
    animation.delegate = self;
    animation.autoreverses = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [layer addAnimation:animation forKey:@"buy"];
    
    //存储购物车数据到本地
    UPWShoppingCartCellModel *cartCellModel = [[UPWShoppingCartCellModel alloc] initWithDictionary:_fruitCellModel.toDictionary error:nil];
    cartCellModel.fruitNum = @"1";
    if (!_cartModel) {
        //本地购物车plist中没有数据，创造数据
        _cartModel = [[UPWShoppingCartModel alloc] initWithDictionary:@{@"noFreightCondition":@"0", @"hasMore":@"0", @"data":@[cartCellModel.toDictionary]} error:nil];
    } else {
        //本地购物车plist中有数据，进行比对
        BOOL found = NO;
        for (NSInteger i = 0; i < _cartModel.data.count; i++) {
            UPWShoppingCartCellModel *cellModel = _cartModel.data[i];
            if ([cartCellModel.fruitId isEqualToString:cellModel.fruitId]) {
                cellModel.fruitNum = [NSString stringWithFormat:@"%d", cellModel.fruitNum.integerValue+1];
                [_cartModel.data replaceObjectAtIndex:i withObject:cellModel];
                found = YES;
            }
        }
        if (!found) {
            [_cartModel.data addObject:cartCellModel];
        }
    }
    [UPWFileUtil writeContent:_cartModel.toDictionary path:[UPWPathUtil shoppingCartPlistPath]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshShoppingCart object:nil];
    
    [self showFlashInfo:@"已放入购物车"];
    
//    UPWBaseNavigationController *cartNaviVC = self.tabBarController.viewControllers[2];
//    UPWShoppingCartViewController *shoppingCartVC = (UPWShoppingCartViewController *)cartNaviVC.viewControllers[0];
    NSInteger badgeValue= 0;
    for (UPWShoppingCartCellModel *cellModel in _cartModel.data) {
        badgeValue += cellModel.fruitNum.integerValue;
    }
    _addToCartPanel.fruitNum = [NSNumber numberWithInteger:badgeValue].stringValue;//shoppingCartVC.fruitNum?shoppingCartVC.fruitNum:
    
    [UPWBussUtil refreshCartDot];
}

@end
