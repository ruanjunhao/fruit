//
//  UPWHomeViewController.m
//  wallet
//
//  Created by gcwang on 15/3/9.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWHomeViewController.h"
#import "UPWWebViewController.h"
#import "UPWAddToCartWebViewController.h"
#import "UPWWelcomeViewController.h"
#import "UPWBaseNavigationController.h"
#import "UPWFruitViewController.h"
#import "UPWCarouselView.h"
#import "UPWLightGridView.h"
#import "UPWHomeTemplateView.h"
#import "UPWFeaturedAppCell.h"
#import "UIImageView+MKNetworkKitAdditions_johankool.h"
#import "UPWWheelImageListModel.h"
#import "UPWCatagoryListModel.h"
#import "UPWFruitListModel.h"
#import "UPWMessage.h"
#import "UPWHttpMgr.h"
#import "UPWFileUtil.h"
#import "UPWPathUtil.h"
#import "AppDelegate.h"

#define kWheelImageHeight 110
#define kCatagoryHeight 100
#define kFreshFruitHeight 36+kScreenWidth*2/3
#define kFruitCutHeight kFreshFruitHeight
#define kFruitJuiceHeight kFreshFruitHeight

#define kModuleGap 10

@interface UPWHomeViewController () <UPWCarouselViewDatasource, UPWCarouselViewDelegate, UPWLightGridViewDataSource, UPWLightGridViewDelegate, UPWHomeTemplateViewDataSource, UPWHomeTemplateViewDelegate>
{
    UIScrollView *_scrollView;
    
    UPWCarouselView* _wheelImageCarouselView;
    UPWLightGridView* _catagoryGridView;
    UPWHomeTemplateView *_freshFruitTempView;
    UPWHomeTemplateView *_fruitCutTempView;
    UPWHomeTemplateView *_fruitJuiceTempView;
    
    UPWWheelImageListModel *_wheelImageListModel;
    UPWCatagoryListModel *_catagoryListModel;
    UPWFruitListModel *_freshFruitListModel;
    UPWFruitListModel *_fruitCutListModel;
    UPWFruitListModel *_fruitJuiceListModel;
    
//    NSCache *_imageCellCache;
//    NSCache *_hotAppCellCache;
//    NSCache *_freshFruitCellCache;
//    NSCache *_fruitCutCellCache;
//    NSCache *_fruitJuiceCellCache;
}

@end

@implementation UPWHomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = NO;
//        _catagoryListModel = [[UPWCatagoryListModel alloc] initWithDictionary:@{@"data":@[@{@"localImageName":@"home_clock", @"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/ic_home_courtesy.png", @"title":@"今日时令", @"detailUrl":@"http://www.baidu.com"}, @{@"localImageName":@"home_bomb", @"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/ic_home_courtesy.png", @"title":@"今日爆款", @"detailUrl":@"http://www.baidu.com"}, @{@"localImageName":@"home_solution", @"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/ic_home_courtesy.png", @"title":@"解决方案", @"detailUrl":@"http://www.baidu.com"}, @{@"localImageName":@"home_business", @"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/ic_home_courtesy.png", @"title":@"企业合作", @"detailUrl":@"http://www.baidu.com"}]} error:nil];
//        _imageCellCache = [[NSCache alloc] init];
//        _hotAppCellCache = [[NSCache alloc] init];
//        _freshFruitCellCache = [[NSCache alloc] init];
//        _fruitCutCellCache = [[NSCache alloc] init];
//        _fruitJuiceCellCache = [[NSCache alloc] init];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect frame = _contentView.frame;
    frame.size.height -= kTabBarHeight;
    [_contentView setFrame:frame];
    
    [self setNaviTitle:@"鲜果管家"];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _topOffset, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame)-_topOffset)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.bounces = YES;
    _scrollView.alwaysBounceVertical = YES;
    [_contentView addSubview:_scrollView];
    
    //添加轮播图
    _wheelImageCarouselView = [[UPWCarouselView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_scrollView.frame), kWheelImageHeight)];
    _wheelImageCarouselView.delegate = self;
    _wheelImageCarouselView.datasource = self;
    _wheelImageCarouselView.backgroundColor = [UIColor whiteColor];
    _wheelImageCarouselView.pageControlButtomMargin = 5;
    [_scrollView addSubview:_wheelImageCarouselView];
    
    _catagoryGridView = [[UPWLightGridView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_wheelImageCarouselView.frame)+kModuleGap, CGRectGetWidth(_scrollView.frame), kCatagoryHeight)];
    _catagoryGridView.customDataSource = self;
    _catagoryGridView.customDelegate = self;
    _catagoryGridView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:_catagoryGridView];
    
    _freshFruitTempView = [[UPWHomeTemplateView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_catagoryGridView.frame)+kModuleGap, CGRectGetWidth(_scrollView.frame), kFreshFruitHeight)];
    _freshFruitTempView.backgroundColor = [UIColor whiteColor];
    _freshFruitTempView.dataSource = self;
    _freshFruitTempView.delegate = self;
    [_scrollView addSubview:_freshFruitTempView];
    
    _fruitCutTempView = [[UPWHomeTemplateView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_freshFruitTempView.frame)+kModuleGap, CGRectGetWidth(_scrollView.frame), kFruitCutHeight)];
    _fruitCutTempView.backgroundColor = [UIColor whiteColor];
    _fruitCutTempView.dataSource = self;
    _fruitCutTempView.delegate = self;
    [_scrollView addSubview:_fruitCutTempView];
    
    _fruitJuiceTempView = [[UPWHomeTemplateView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_fruitCutTempView.frame)+kModuleGap, CGRectGetWidth(_scrollView.frame), kFruitJuiceHeight)];
    _fruitJuiceTempView.backgroundColor = [UIColor whiteColor];
    _fruitJuiceTempView.dataSource = self;
    _fruitJuiceTempView.delegate = self;
    [_scrollView addSubview:_fruitJuiceTempView];
    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(_scrollView.frame), CGRectGetMaxY(_fruitJuiceTempView.frame));
    
    UPWHomeViewController __weak *wself = self;
    [self addPullToRefresh:_scrollView withActionHandler:^{
        [wself pullToRefresh];
    }];
    
    [self triggerPullToRefresh:_scrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 下拉刷新
- (void)pullToRefresh
{
    NSLog(@"pullToRefresh");
    [self getWheelImageList];
    [self getCatagoryList];
    [self getFreshFruitList];
    [self getFruitCutList];
    [self getFruitJuiceList];
}

#pragma mark -
#pragma mark - 轮播图
- (void)getWheelImageList
{
    NSDictionary *params = @{@"communityId":@"communityId"};
    UPWMessage* message = [UPWMessage messageWheelImageListWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
//        wself.status |= UPWImgHotSecKillComplete;
        
        // 缓存数据
        NSDictionary* params = responseJSON;//@{@"data":@[@{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/imageHotSeckill_kv_1.png", @"detailUrl":@"http://youhui.95516.com/hybrid_v3/html/help/feedback.html"}, @{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/tucao2.jpg", @"detailUrl":@"http://www.baidu.com"}, @{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/imageHotSeckill_kv_3.png", @"detailUrl":@"http://www.baidu.com"}, @{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/imageHotSeckill_kv_2.png", @"detailUrl":@"http://www.baidu.com"}]};
        [UPWFileUtil writeContent:params path:[UPWPathUtil wheelImageListPlistPath]];
        [wself updateWheelImageListWithParams:params];
    } fail:^(NSError * error) {
        [wself didFinishedRefreshing:_scrollView showPullToRefresh:YES];
        
        [wself showFlashInfo:[wself stringWithError:error]];
        // 网络失败，读取缓存数据
        NSDictionary* params =  [UPWFileUtil readContent:[UPWPathUtil wheelImageListPlistPath]];
        if ([params count] > 0 ) {
            [wself updateWheelImageListWithParams:params];
        }
//        wself.status |= UPWImgHotSecKillComplete;
    }];
    [self addMessage:message];
}

- (void)updateWheelImageListWithParams:(NSDictionary *)params
{
    [self didFinishedRefreshing:_scrollView showPullToRefresh:YES];
    
    NSError *error;
    _wheelImageListModel = [[UPWWheelImageListModel alloc] initWithDictionary:params error:&error];
    if (!error) {
        [_wheelImageCarouselView setNeedsLayout];
    }
}

- (NSInteger)countOfCellForCarouselView:(UPWCarouselView*)carouselView
{
    return _wheelImageListModel.data.count;
}

- (UIView*)carouselView:(UPWCarouselView*)carouselView cellAtIndex:(NSInteger)index
{
    UPWWheelImageModel* model = _wheelImageListModel.data[index];
    UIImageView* cell = nil;
    
//    cell = [_imageCellCache objectForKey:model.imageUrl];
    if (!cell) {
        cell = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, carouselView.frame.size.width, carouselView.frame.size.height)];
        
        [cell mk_setImageAtURL:[NSURL URLWithString:model.imageUrl] forceReload:NO showActivityIndicator:YES loadingImage:nil fadeIn:NO notAvailableImage:UP_GETIMG(@"icon_failed_to_load") size:carouselView.frame.size onCompletion:nil];
//        [_imageCellCache setObject:cell forKey:model.imageUrl];
    }
    
    return cell;
}

- (void)carouselView:(UPWCarouselView *)carouselView didSelectAtIndex:(NSInteger)index
{
    UPWWheelImageModel* model = _wheelImageListModel.data[index];
    if ([model.type isEqualToString:UP_STR(@"String_PageType")]) {
        UPWWebViewController *webVC = [[UPWWebViewController alloc] init];
        webVC.startPage = model.detailUrl;
        webVC.title = model.title;
        [self.navigationController pushViewController:webVC animated:YES];
    } else if ([model.type isEqualToString:UP_STR(@"String_ProductType")]) {
        UPWFruitListCellModel* cellModel = [[UPWFruitListCellModel alloc] initWithDictionary:model.product.toDictionary error:nil];
        UPWAddToCartWebViewController *addToCartVC = [[UPWAddToCartWebViewController alloc] initWithCellModel:cellModel];
        addToCartVC.startPage = model.detailUrl;
        addToCartVC.title = model.title;
        [self.navigationController pushViewController:addToCartVC animated:YES];
    }
}

#pragma mark -
#pragma mark - 类别
- (void)getCatagoryList
{
    NSDictionary *params = @{@"communityId":@"communityId"};
    UPWMessage* message = [UPWMessage messageCatagoryListWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        // 缓存数据
        NSDictionary* params = responseJSON;//@{@"data":@[@{@"imageName":@"1", @"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/ic_home_courtesy.png", @"title":@"今日时令"}, @{@"imageName":@"1", @"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/ic_home_courtesy.png", @"title":@"纯干货 "}, @{@"imageName":@"1", @"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/ic_home_courtesy.png", @"title":@"解决方案"}, @{@"imageName":@"1", @"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/ic_home_courtesy.png", @"title":@"企业合作"}]};
        [UPWFileUtil writeContent:params path:[UPWPathUtil catagoryListPlistPath]];
        [wself updateCatagoryListWithParams:params];
    } fail:^(NSError * error) {
        [wself didFinishedRefreshing:_scrollView showPullToRefresh:YES];
        
        [wself showFlashInfo:[wself stringWithError:error]];
        // 网络失败，读取缓存数据
        NSDictionary* params =  [UPWFileUtil readContent:[UPWPathUtil catagoryListPlistPath]];
        if ([params count] > 0 ) {
            [wself updateCatagoryListWithParams:params];
        }
    }];
    [self addMessage:message];
}

- (void)updateCatagoryListWithParams:(NSDictionary *)params
{
    [self didFinishedRefreshing:_scrollView showPullToRefresh:YES];
    
    NSError *error;
    _catagoryListModel = [[UPWCatagoryListModel alloc] initWithDictionary:params error:&error];
    if (!error) {
        [_catagoryGridView setNeedsLayout];
    }
}

- (NSInteger)countOfCellForLightGridView:(UPWLightGridView*)gridView
{
    return _catagoryListModel.data.count;
}

- (NSInteger)columnNumberForLightGridView:(UPWLightGridView*)gridView
{
    return _catagoryListModel.data.count;
}

- (CGFloat)borderMarginForLightGridView:(UPWLightGridView*)gridView
{
    return 24;
}

- (CGFloat)innerMarginForLightGridView:(UPWLightGridView*)gridView
{
    // 对于正好4个的时候，平均分配
    if (_catagoryListModel.data.count == 4) {
        return (CGRectGetWidth(gridView.bounds) - 4 * UPFloat(kHotAppWidth) - 2 * [gridView.customDataSource borderMarginForLightGridView:gridView])/3;
    } else {
        return 24;
    }
}

- (CGSize)itemSizeForLightGridView:(UPWLightGridView*)gridView
{
    return CGSizeMake(UPFloat(kHotAppWidth), UPFloat(kHotAppHeight));
}

- (UIView*)lightGridView:(UPWLightGridView*)gridView cellAtIndex:(NSInteger)index
{
    UPWCatagoryCellModel *cellModel = _catagoryListModel.data[index];
    
    NSString* key = @(index).stringValue;
    UPWFeaturedAppCell *cell = nil;//[_hotAppCellCache objectForKey:key];
    if (!cell)
    {
        // 如果重用cell，在原有图片缓存策略的情况下，图片显示的时候会有不断变化的问题，所以去掉重用
        cell = [[UPWFeaturedAppCell alloc] initWithFrame:CGRectMake(0, 0, UPFloat(kHotAppWidth), UPFloat(kHotAppHeight))];
//        [_hotAppCellCache setObject:cell forKey:key];
    }
    cell.backgroundColor = [UIColor clearColor];
    [cell setCellModel:cellModel];
    return cell;
}

- (void)lightGridView:(UPWLightGridView *)lightGridView didSelectAtIndex:(NSInteger)index cell:(UIControl *)cell
{
#warning 点击进入相应列表
//    UPWCatagoryCellModel *cellModel = _catagoryListModel.data[index];
//    UPWWebViewController *webVC = [[UPWWebViewController alloc] init];
//    webVC.startPage = cellModel.detailUrl;
//    [self.navigationController pushViewController:webVC animated:YES];
//    
//    
    UPWCatagoryCellModel* model = _catagoryListModel.data[index];
    if ([model.type isEqualToString:UP_STR(@"String_PageType")]) {
        UPWWebViewController *webVC = [[UPWWebViewController alloc] init];
        webVC.startPage = model.detailUrl;
        webVC.title = model.title;
        [self.navigationController pushViewController:webVC animated:YES];
    } else if ([model.type isEqualToString:UP_STR(@"String_ProductType")]) {
        UPWFruitListCellModel* cellModel = [[UPWFruitListCellModel alloc] initWithDictionary:model.product.toDictionary error:nil];
        UPWAddToCartWebViewController *addToCartVC = [[UPWAddToCartWebViewController alloc] initWithCellModel:cellModel];
        addToCartVC.startPage = model.detailUrl;
        addToCartVC.title = model.title;
        [self.navigationController pushViewController:addToCartVC animated:YES];
    }
}

#pragma mark -
#pragma mark - 鲜果，果切，果汁  
#pragma mark -  0：全部  1:鲜果  2:果切  3:果汁
- (void)getFreshFruitList
{
    NSDictionary *params = @{@"communityId":@"communityId", @"fruitType":@"1", @"requestPage":@"1", @"pageSize":UP_STR(@"String_HomeFruitPageSize")};
    UPWMessage* message = [UPWMessage messageFruitListWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        // 缓存数据
        NSDictionary* params =  responseJSON;//@{@"data":@[@{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/imageHotSeckill_kv_1.png", @"detailUrl":@"http://youhui.95516.com/hybrid_v3/html/help/feedback.html"}, @{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/tucao2.jpg", @"detailUrl":@"http://www.baidu.com"}, @{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/imageHotSeckill_kv_3.png", @"detailUrl":@"http://www.baidu.com"}, @{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/imageHotSeckill_kv_2.png", @"detailUrl":@"http://www.baidu.com"}]};
        [UPWFileUtil writeContent:params path:[UPWPathUtil freshFruitListPlistPath]];
        [wself updateFreshFruitListWithParams:params];
    } fail:^(NSError * error) {
        [wself didFinishedRefreshing:_scrollView showPullToRefresh:YES];
        
        [wself showFlashInfo:[wself stringWithError:error]];
        // 网络失败，读取缓存数据
        NSDictionary* params =  [UPWFileUtil readContent:[UPWPathUtil freshFruitListPlistPath]];
        if ([params count] > 0 ) {
            [wself updateFreshFruitListWithParams:params];
        }
        //        wself.status |= UPWImgHotSecKillComplete;
    }];
    [self addMessage:message];
}

- (void)updateFreshFruitListWithParams:(NSDictionary *)params
{
    [self didFinishedRefreshing:_scrollView showPullToRefresh:YES];
    
    NSError *error;
    _freshFruitListModel = [[UPWFruitListModel alloc] initWithDictionary:params error:&error];
    if (!error) {
        [_freshFruitTempView setNeedsLayout];
    }
}

- (void)getFruitCutList
{
    NSDictionary *params = @{@"communityId":@"communityId", @"fruitType":@"2", @"requestPage":@"1", @"pageSize":UP_STR(@"String_HomeFruitPageSize")};
    UPWMessage* message = [UPWMessage messageFruitListWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        //        wself.status |= UPWImgHotSecKillComplete;
        
        // 缓存数据
        NSDictionary* params = responseJSON;//@{@"data":@[@{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/imageHotSeckill_kv_1.png", @"detailUrl":@"http://youhui.95516.com/hybrid_v3/html/help/feedback.html"}, @{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/tucao2.jpg", @"detailUrl":@"http://www.baidu.com"}, @{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/imageHotSeckill_kv_3.png", @"detailUrl":@"http://www.baidu.com"}, @{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/imageHotSeckill_kv_2.png", @"detailUrl":@"http://www.baidu.com"}]};
        [UPWFileUtil writeContent:params path:[UPWPathUtil fruitCutListPlistPath]];
        [wself updateFruitCutListWithParams:params];
    } fail:^(NSError * error) {
        [wself didFinishedRefreshing:_scrollView showPullToRefresh:YES];
        
        [wself showFlashInfo:[wself stringWithError:error]];
        // 网络失败，读取缓存数据
        NSDictionary* params =  [UPWFileUtil readContent:[UPWPathUtil fruitCutListPlistPath]];
        if ([params count] > 0 ) {
            [wself updateFruitCutListWithParams:params];
        }
        //        wself.status |= UPWImgHotSecKillComplete;
    }];
    [self addMessage:message];
}

- (void)updateFruitCutListWithParams:(NSDictionary *)params
{
    [self didFinishedRefreshing:_scrollView showPullToRefresh:YES];
    
    NSError *error;
    _fruitCutListModel = [[UPWFruitListModel alloc] initWithDictionary:params error:&error];
    if (!error) {
        [_fruitCutTempView setNeedsLayout];
    }
}

- (void)getFruitJuiceList
{
    NSDictionary *params = @{@"communityId":@"communityId", @"fruitType":@"3", @"requestPage":@"1", @"pageSize":UP_STR(@"String_HomeFruitPageSize")};
    UPWMessage* message = [UPWMessage messageFruitListWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        //        wself.status |= UPWImgHotSecKillComplete;
        
        // 缓存数据
        NSDictionary* params = responseJSON;//@{@"data":@[@{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/imageHotSeckill_kv_1.png", @"detailUrl":@"http://youhui.95516.com/hybrid_v3/html/help/feedback.html"}, @{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/tucao2.jpg", @"detailUrl":@"http://www.baidu.com"}, @{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/imageHotSeckill_kv_3.png", @"detailUrl":@"http://www.baidu.com"}, @{@"imageUrl":@"https://mgate.unionpay.com/s/wl/icon/imageHotSeckill_kv_2.png", @"detailUrl":@"http://www.baidu.com"}]};
        [UPWFileUtil writeContent:params path:[UPWPathUtil fruitJuiceListPlistPath]];
        [wself updateFruitJuiceListWithParams:params];
    } fail:^(NSError * error) {
        [wself didFinishedRefreshing:_scrollView showPullToRefresh:YES];
        
        [wself showFlashInfo:[wself stringWithError:error]];
        // 网络失败，读取缓存数据
        NSDictionary* params =  [UPWFileUtil readContent:[UPWPathUtil fruitJuiceListPlistPath]];
        if ([params count] > 0 ) {
            [wself updateFruitJuiceListWithParams:params];
        }
        //        wself.status |= UPWImgHotSecKillComplete;
    }];
    [self addMessage:message];
}

- (void)updateFruitJuiceListWithParams:(NSDictionary *)params
{
    [self didFinishedRefreshing:_scrollView showPullToRefresh:YES];
    
    NSError *error;
    _fruitJuiceListModel = [[UPWFruitListModel alloc] initWithDictionary:params error:&error];
    if (!error) {
        [_fruitJuiceTempView setNeedsLayout];
    }
}

- (NSString *)nameForHomeTemplateView:(UPWHomeTemplateView *)templateView
{
    if (templateView == _freshFruitTempView) {
        return @"精品鲜果";
    } else if (templateView == _fruitCutTempView) {
        return @"精品果切";
    } else if (templateView == _fruitJuiceTempView) {
        return @"精品果汁";
    } else {
        return nil;
    }
}

- (NSInteger)countOfCellForHomeTemplateView:(UPWHomeTemplateView *)templateView
{
    if (templateView == _freshFruitTempView) {
        return _freshFruitListModel.data.count;
    } else if (templateView == _fruitCutTempView) {
        return _fruitCutListModel.data.count;
    } else if (templateView == _fruitJuiceTempView) {
        return _fruitJuiceListModel.data.count;
    } else {
        return 0;
    }
}

- (UIView *)homeTemplateView:(UPWHomeTemplateView *)templateView cellAtIndex:(NSInteger)index
{
    if (templateView == _freshFruitTempView) {
        UPWFruitListCellModel *model= _freshFruitListModel.data[index];
        UIControl *control = templateView.controlArray[index];
        UIImageView* cell = nil;//[_freshFruitCellCache objectForKey:model.imageUrl];
        if (!cell) {
            cell = [[UIImageView alloc] initWithFrame:control.bounds];
            
            [cell mk_setImageAtURL:[NSURL URLWithString:model.imageUrl] forceReload:NO showActivityIndicator:YES loadingImage:nil fadeIn:NO notAvailableImage:UP_GETIMG(@"icon_failed_to_load") size:control.frame.size onCompletion:nil];
//            [_freshFruitCellCache setObject:cell forKey:model.imageUrl];
        }
        return cell;
    } else if (templateView == _fruitCutTempView) {
        UPWFruitListCellModel *model= _fruitCutListModel.data[index];
        UIControl *control = templateView.controlArray[index];
        UIImageView* cell = nil;//[_fruitCutCellCache objectForKey:model.imageUrl];
        if (!cell) {
            cell = [[UIImageView alloc] initWithFrame:control.bounds];
            
            [cell mk_setImageAtURL:[NSURL URLWithString:model.imageUrl] forceReload:NO showActivityIndicator:YES loadingImage:nil fadeIn:NO notAvailableImage:UP_GETIMG(@"icon_failed_to_load") size:control.frame.size onCompletion:nil];
//            [_fruitCutCellCache setObject:cell forKey:model.imageUrl];
        }
        return cell;
    } else if (templateView == _fruitJuiceTempView) {
        UPWFruitListCellModel *model= _fruitJuiceListModel.data[index];
        UIControl *control = templateView.controlArray[index];
        UIImageView* cell = nil;//[_fruitJuiceCellCache objectForKey:model.imageUrl];
        if (!cell) {
            cell = [[UIImageView alloc] initWithFrame:control.bounds];
            
            [cell mk_setImageAtURL:[NSURL URLWithString:model.imageUrl] forceReload:NO showActivityIndicator:YES loadingImage:nil fadeIn:NO notAvailableImage:UP_GETIMG(@"icon_failed_to_load") size:control.frame.size onCompletion:nil];
//            [_fruitJuiceCellCache setObject:cell forKey:model.imageUrl];
        }
        return cell;
    } else {
        return nil;
    }
}

- (void)homeTemplateView:(UPWHomeTemplateView *)templateView didSelectMore:(id)sender
{
    self.tabBarController.selectedIndex = 1;
}

- (void)homeTemplateView:(UPWHomeTemplateView *)templateView didSelectAtIndex:(NSInteger)index
{
    if (templateView == _freshFruitTempView) {
        if (!_freshFruitListModel || index >= _freshFruitListModel.data.count) {
            return;
        }
        UPWFruitListCellModel* model = _freshFruitListModel.data[index];
        UPWAddToCartWebViewController *addToCartVC = [[UPWAddToCartWebViewController alloc] initWithCellModel:model];
        addToCartVC.startPage = model.detailUrl;
        [self.navigationController pushViewController:addToCartVC animated:YES];
    } else if (templateView == _fruitCutTempView) {
        if (!_fruitCutListModel || index >= _fruitCutListModel.data.count) {
            return;
        }
        UPWFruitListCellModel* model = _fruitCutListModel.data[index];
        UPWAddToCartWebViewController *addToCartVC = [[UPWAddToCartWebViewController alloc] initWithCellModel:model];
        addToCartVC.startPage = model.detailUrl;
        [self.navigationController pushViewController:addToCartVC animated:YES];
    } else if (templateView == _fruitJuiceTempView) {
        if (!_fruitJuiceListModel || index >= _fruitJuiceListModel.data.count) {
            return;
        }
        UPWFruitListCellModel* model = _fruitJuiceListModel.data[index];
        UPWAddToCartWebViewController *addToCartVC = [[UPWAddToCartWebViewController alloc] initWithCellModel:model];
        addToCartVC.startPage = model.detailUrl;
        [self.navigationController pushViewController:addToCartVC animated:YES];
    } else {
    }
}

@end
