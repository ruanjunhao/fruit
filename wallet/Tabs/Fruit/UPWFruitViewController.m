//
//  UPWFruitViewController.m
//  wallet
//
//  Created by gcwang on 15/3/12.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWFruitViewController.h"
#import "UPWAddToCartWebViewController.h"
#import "UPSegmentedControl.h"
#import "UPWFruitTableViewCell.h"
#import "UPWFruitListModel.h"
#import "UPWCommonTableListModel.h"
#import "UPWShoppingCartModel.h"
#import "UPWNotificationName.h"
#import "UPWFileUtil.h"
#import "UPWPathUtil.h"
#import "UPWBussUtil.h"

@interface UPWFruitViewController () <UPSegmentedControlDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_freshFruitTableView;
    UITableView *_fruitCutTableView;
    UITableView *_fruitJuiceTableView;
    
    UPWFruitListModel *_freshFruitListModel;
    UPWFruitListModel *_fruitCutListModel;
    UPWFruitListModel *_fruitJuiceListModel;
    
    UPWCommonTableListModel *_freshFruitCommonTableModel;
    UPWCommonTableListModel *_fruitCutCommonTableModel;
    UPWCommonTableListModel *_fruitJuiceCommonTableModel;
    
    NSInteger _segmentIndex;
}

@end

@implementation UPWFruitViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationPutInShoppingCart object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = NO;
        _freshFruitCommonTableModel = [[UPWCommonTableListModel alloc] init];
        _fruitCutCommonTableModel = [[UPWCommonTableListModel alloc] init];
        _fruitJuiceCommonTableModel = [[UPWCommonTableListModel alloc] init];
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
    
    //加载鲜果，果切，果汁segment
    NSArray *segmentedArray = [NSArray arrayWithObjects:@"鲜果", @"果切", @"果汁", nil];
    UPSegmentedControl *segmentedControl = [[UPSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 200, kHeightSegmentView) Items:segmentedArray];
    segmentedControl.delegate = self;
    [self setNaviTitleView:segmentedControl];
    
    UPWFruitViewController __weak *wself = self;
    _freshFruitTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topOffset, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame)-_topOffset) style:UITableViewStylePlain];
    _freshFruitTableView.backgroundColor = [UIColor whiteColor];
    _freshFruitTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _freshFruitTableView.dataSource = self;
    _freshFruitTableView.delegate = self;
    [self addPullToRefresh:_freshFruitTableView withActionHandler:^{
        [wself pullToRefresh];
    }];
    [self addInfiniteScrolling:_freshFruitTableView withActionHandler:^{
        [wself loadMore];
    }];
    [_contentView addSubview:_freshFruitTableView];
    
    _fruitCutTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topOffset, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame)-_topOffset) style:UITableViewStylePlain];
    _fruitCutTableView.backgroundColor = [UIColor whiteColor];
    _fruitCutTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _fruitCutTableView.dataSource = self;
    _fruitCutTableView.delegate = self;
    [self addPullToRefresh:_fruitCutTableView withActionHandler:^{
        [wself pullToRefresh];
    }];
    [self addInfiniteScrolling:_fruitCutTableView withActionHandler:^{
        [wself loadMore];
    }];
    [_contentView addSubview:_fruitCutTableView];
    
    _fruitJuiceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topOffset, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame)-_topOffset) style:UITableViewStylePlain];
    _fruitJuiceTableView.backgroundColor = [UIColor whiteColor];
    _fruitJuiceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _fruitJuiceTableView.dataSource = self;
    _fruitJuiceTableView.delegate = self;
    [self addPullToRefresh:_fruitJuiceTableView withActionHandler:^{
        [wself pullToRefresh];
    }];
    [self addInfiniteScrolling:_fruitJuiceTableView withActionHandler:^{
        [wself loadMore];
    }];
    [_contentView addSubview:_fruitJuiceTableView];
    
    [segmentedControl setSelectedSegmentIndex:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(putInShoppingCart:) name:kNotificationPutInShoppingCart object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - segment delegate
- (void)segmentedControlAction:(NSInteger)index
{
    _segmentIndex = index;
    switch (_segmentIndex) {
        case 0:
        {
            [_contentView bringSubviewToFront:_freshFruitTableView];
            if (_freshFruitListModel.data.count == 0) {
                [self reloadData];
            }
        }
            break;
        case 1:
        {
            [_contentView bringSubviewToFront:_fruitCutTableView];
            if (_fruitCutListModel.data.count == 0) {
                [self reloadData];
            }
        }
            break;
        case 2:
        {
            [_contentView bringSubviewToFront:_fruitJuiceTableView];
            if (_fruitJuiceListModel.data.count == 0) {
                [self reloadData];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark - 下拉刷新
- (void)pullToRefresh
{
    switch (_segmentIndex) {
        case 0:
        {
            if (_freshFruitCommonTableModel.pullToRefreshing || _freshFruitCommonTableModel.loadMore) {
                return;
            }
            
            _freshFruitCommonTableModel.pullToRefreshing = YES;
            
            _freshFruitCommonTableModel.requestPage = 1;
            [self getFreshFruitList];
        }
            break;
        case 1:
        {
            if (_fruitCutCommonTableModel.pullToRefreshing || _fruitCutCommonTableModel.loadMore) {
                return;
            }
            
            _fruitCutCommonTableModel.pullToRefreshing = YES;
            
            _fruitCutCommonTableModel.requestPage = 1;
            [self getFruitCutList];
        }
            break;
        case 2:
        {
            if (_fruitJuiceCommonTableModel.pullToRefreshing || _fruitJuiceCommonTableModel.loadMore) {
                return;
            }
            
            _fruitJuiceCommonTableModel.pullToRefreshing = YES;
            
            _fruitJuiceCommonTableModel.requestPage = 1;
            [self getFruitJuiceList];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark - 上拉加载更多
- (void)loadMore
{
    switch (_segmentIndex) {
        case 0:
        {
            if (_freshFruitCommonTableModel.pullToRefreshing || _freshFruitCommonTableModel.loadMore || !_freshFruitListModel.hasMore) {
                return;
            }
            
            _freshFruitCommonTableModel.loadMore = YES;
            
            [self getFreshFruitList];
        }
            break;
        case 1:
        {
            if (_fruitCutCommonTableModel.pullToRefreshing || _fruitCutCommonTableModel.loadMore || !_fruitCutListModel.hasMore) {
                return;
            }
            
            _fruitCutCommonTableModel.loadMore = YES;
            
            [self getFruitCutList];
        }
            break;
        case 2:
        {
            if (_fruitJuiceCommonTableModel.pullToRefreshing || _fruitJuiceCommonTableModel.loadMore || !_fruitJuiceListModel.hasMore) {
                return;
            }
            
            _fruitJuiceCommonTableModel.loadMore = YES;
            
            [self getFruitJuiceList];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 
#pragma mark - 点击屏幕刷新
- (void)reloadData
{
    switch (_segmentIndex) {
        case 0:
        {
#warning 把_networkStatusView放在_freshFruitTableView上，而不是_contentView上。以解决segment切换时_networkStatusView显示问题
            [self showNetworkLoading:_freshFruitTableView.center withRetryRect:_freshFruitTableView.frame];
            [self getFreshFruitList];
        }
            break;
        case 1:
        {
            [self showNetworkLoading:_fruitCutTableView.center withRetryRect:_fruitCutTableView.frame];
            [self getFruitCutList];
        }
            break;
        case 2:
        {
            [self showNetworkLoading:_fruitJuiceTableView.center withRetryRect:_fruitJuiceTableView.frame];
            [self getFruitJuiceList];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark - 鲜果，果切，果汁 网络请求
- (void)getFreshFruitList
{
    NSDictionary *params = @{@"communityId":@"communityId", @"fruitType":@"1", @"requestPage":[NSNumber numberWithInteger:_freshFruitCommonTableModel.requestPage].stringValue, @"pageSize":UP_STR(@"kStrPageSize")};
    UPWMessage* message = [UPWMessage messageFruitListWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        NSDictionary* params = responseJSON;
        [wself updateFreshFruitListWithParams:params];
    } fail:^(NSError * error) {
        [wself updateFreshFruitListWithError:error];
        
//#warning 测试数据
//        NSDictionary* params = @{@"hasMore":@"0", @"data":@[@{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://youhui.95516.com/hybrid_v3/html/help/feedback.html", @"fruitName":@"苹果", @"fruitPrice":@"2.50", @"fruitPriceUnit":@"个", @"fruitId":@"001"}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"苹果", @"fruitPrice":@"2.50", @"fruitPriceUnit":@"盒", @"fruitId":@"002"}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"苹果", @"fruitPrice":@"2.50", @"fruitPriceUnit":@"公斤", @"fruitId":@"003"}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"苹果", @"fruitPrice":@"2.50", @"fruitPriceUnit":@"个", @"fruitId":@"004"}]};
//        [self updateFreshFruitListWithParams:params];
    }];
    [self addMessage:message];
}

- (void)updateFreshFruitListWithParams:(NSDictionary *)params
{
    [self didFinishedRefreshing:_freshFruitTableView showPullToRefresh:YES];
    [self didFinishedInfiniteScrolling:_freshFruitTableView showInfiniteScrolling:_freshFruitListModel.hasMore.boolValue];
    [self hideNetworkStatusView];
    _freshFruitCommonTableModel.loadMore = NO;
    _freshFruitCommonTableModel.requestPage += 1;
    
    UPWFruitListModel *latestModel = [[UPWFruitListModel alloc] initWithDictionary:params error:nil];
    if (!_freshFruitListModel) {
        _freshFruitListModel = [[UPWFruitListModel alloc] initWithDictionary:latestModel.toDictionary error:nil];
    } else {
        if (_freshFruitCommonTableModel.pullToRefreshing) {
            _freshFruitCommonTableModel.pullToRefreshing = NO;
            [_freshFruitListModel.data removeAllObjects];
        }
        [_freshFruitListModel.data addObjectsFromArray:latestModel.data];
    }
    
    if (_freshFruitListModel.data.count == 0) {
        [self showNoContentView:_freshFruitTableView.center];
    }
    
    [_freshFruitTableView reloadData];
}

- (void)updateFreshFruitListWithError:(NSError *)error
{
    [self didFinishedRefreshing:_freshFruitTableView showPullToRefresh:YES];
    [self didFinishedInfiniteScrolling:_freshFruitTableView showInfiniteScrolling:YES];
    [self showNetworkFailed];
    _freshFruitCommonTableModel.pullToRefreshing = NO;
    _freshFruitCommonTableModel.loadMore = NO;
    
    [self showFlashInfo:[self stringWithError:error]];
}

- (void)getFruitCutList
{
    NSDictionary *params = @{@"communityId":@"communityId", @"fruitType":@"2", @"requestPage":[NSNumber numberWithInteger:_fruitCutCommonTableModel.requestPage].stringValue, @"pageSize": UP_STR(@"kStrPageSize")};
    UPWMessage* message = [UPWMessage messageFruitListWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        //        wself.status |= UPWImgHotSecKillComplete;
        
        // 缓存数据
        NSDictionary* params = responseJSON;
        [wself updateFruitCutListWithParams:params];
    } fail:^(NSError * error) {
        [wself updateFruitCutListWithError:error];
        
//        #warning 测试数据
//        NSDictionary* params = @{@"hasMore":@"0", @"data":@[@{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://youhui.95516.com/hybrid_v3/html/help/feedback.html", @"fruitName":@"三合一果切杯", @"fruitPrice":@"2.50", @"fruitPriceUnit":@"个", @"fruitId":@"101"}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"三合一果切杯", @"fruitPrice":@"2.50", @"fruitPriceUnit":@"盒", @"fruitId":@"102"}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"三合一果切杯", @"fruitPrice":@"2.50", @"fruitPriceUnit":@"公斤", @"fruitId":@"103"}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"三合一果切杯", @"fruitPrice":@"2.50", @"fruitPriceUnit":@"个", @"fruitId":@"104"}]};
//        [wself updateFruitCutListWithParams:params];
    }];
    [self addMessage:message];
}

- (void)updateFruitCutListWithParams:(NSDictionary *)params
{
    [self didFinishedRefreshing:_fruitCutTableView showPullToRefresh:YES];
    [self didFinishedInfiniteScrolling:_fruitCutTableView showInfiniteScrolling:_fruitCutListModel.hasMore.boolValue];
    [self hideNetworkStatusView];
    _fruitCutCommonTableModel.loadMore = NO;
    _fruitCutCommonTableModel.requestPage += 1;
    
    UPWFruitListModel *latestModel = [[UPWFruitListModel alloc] initWithDictionary:params error:nil];
    if (!_fruitCutListModel) {
        _fruitCutListModel = [[UPWFruitListModel alloc] initWithDictionary:latestModel.toDictionary error:nil];
    } else {
        if (_fruitCutCommonTableModel.pullToRefreshing) {
            _fruitCutCommonTableModel.pullToRefreshing = NO;
            [_fruitCutListModel.data removeAllObjects];
        }
        [_fruitCutListModel.data addObjectsFromArray:latestModel.data];
    }
    
    if (_fruitCutListModel.data.count == 0) {
        [self showNoContentView:_fruitCutTableView.center];
    }
    
    [_fruitCutTableView reloadData];
}

- (void)updateFruitCutListWithError:(NSError *)error
{
    [self didFinishedRefreshing:_fruitCutTableView showPullToRefresh:YES];
    [self didFinishedInfiniteScrolling:_fruitCutTableView showInfiniteScrolling:YES];
    [self showNetworkFailed];
    _fruitCutCommonTableModel.pullToRefreshing = NO;
    _fruitCutCommonTableModel.loadMore = NO;
    
    [self showFlashInfo:[self stringWithError:error]];
    //        wself.status |= UPWImgHotSecKillComplete;
}

- (void)getFruitJuiceList
{
    NSDictionary *params = @{@"communityId":@"communityId", @"fruitType":@"3", @"requestPage":[NSNumber numberWithInteger:_fruitJuiceCommonTableModel.requestPage].stringValue, @"pageSize": UP_STR(@"kStrPageSize")};
    UPWMessage* message = [UPWMessage messageFruitListWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        NSDictionary* params = responseJSON;
        [wself updateFruitJuiceListWithParams:params];
    } fail:^(NSError * error) {
        [wself updateFruitJuiceListWithError:error];
        
//#warning 测试数据
//        NSDictionary* params = @{@"hasMore":@"0", @"data":@[@{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://youhui.95516.com/hybrid_v3/html/help/feedback.html", @"fruitName":@"炫夏果汁", @"fruitPrice":@"2.50", @"fruitPriceUnit":@"个", @"fruitId":@"201"}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"炫夏果汁", @"fruitPrice":@"2.50", @"fruitPriceUnit":@"盒", @"fruitId":@"202"}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"炫夏果汁", @"fruitPrice":@"2.50", @"fruitPriceUnit":@"公斤", @"fruitId":@"203"}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"炫夏果汁", @"fruitPrice":@"2.50", @"fruitPriceUnit":@"个", @"fruitId":@"204"}]};
//        [wself updateFruitJuiceListWithParams:params];
    }];
    [self addMessage:message];
}

- (void)updateFruitJuiceListWithParams:(NSDictionary *)params
{
    [self didFinishedRefreshing:_fruitJuiceTableView showPullToRefresh:YES];
    [self didFinishedInfiniteScrolling:_fruitJuiceTableView showInfiniteScrolling:_fruitJuiceListModel.hasMore.boolValue];
    [self hideNetworkStatusView];
    _fruitJuiceCommonTableModel.loadMore = NO;
    _fruitJuiceCommonTableModel.requestPage += 1;
    
    UPWFruitListModel *latestModel = [[UPWFruitListModel alloc] initWithDictionary:params error:nil];
    if (!_fruitJuiceListModel) {
        _fruitJuiceListModel = [[UPWFruitListModel alloc] initWithDictionary:latestModel.toDictionary error:nil];
    } else {
        if (_fruitJuiceCommonTableModel.pullToRefreshing) {
            _fruitJuiceCommonTableModel.pullToRefreshing = NO;
            [_fruitJuiceListModel.data removeAllObjects];
        }
        [_fruitJuiceListModel.data addObjectsFromArray:latestModel.data];
    }
    
    if (_fruitJuiceListModel.data.count == 0) {
        [self showNoContentView:_fruitJuiceTableView.center];
    }
    
    [_fruitJuiceTableView reloadData];
}

- (void)updateFruitJuiceListWithError:(NSError *)error
{
    [self didFinishedRefreshing:_fruitJuiceTableView showPullToRefresh:YES];
    [self didFinishedInfiniteScrolling:_fruitJuiceTableView showInfiniteScrolling:YES];
    [self showNetworkFailed];
    _fruitJuiceCommonTableModel.pullToRefreshing = NO;
    _fruitJuiceCommonTableModel.loadMore = NO;
    
    [self showFlashInfo:[self stringWithError:error]];
    //        wself.status |= UPWImgHotSecKillComplete;
}

#pragma mark -
#pragma mark - tableView dataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _freshFruitTableView) {
        return _freshFruitListModel.data.count;
    } else if (tableView == _fruitCutTableView) {
        return _fruitCutListModel.data.count;
    } else if (tableView == _fruitJuiceTableView) {
        return _fruitJuiceListModel.data.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tag = @"UPWFruitTableViewCell";
    UPWFruitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tag];
    if (cell==nil) {
        cell = [[UPWFruitTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tag];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.contentView.exclusiveTouch = YES;
    cell.contentView.multipleTouchEnabled = NO;
    
    if (tableView == _freshFruitTableView) {
        [cell setCellWithModel:_freshFruitListModel.data[indexPath.row] cellCount:_freshFruitListModel.data.count indexPath:indexPath];
    } else if (tableView == _fruitCutTableView) {
        [cell setCellWithModel:_fruitCutListModel.data[indexPath.row] cellCount:_fruitCutListModel.data.count indexPath:indexPath];
    } else if (tableView == _fruitJuiceTableView) {
        [cell setCellWithModel:_fruitJuiceListModel.data[indexPath.row] cellCount:_fruitJuiceListModel.data.count indexPath:indexPath];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kFruitCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (tableView == _freshFruitTableView) {
        UPWFruitListCellModel* model = _freshFruitListModel.data[indexPath.row];
        UPWAddToCartWebViewController *addToCartVC = [[UPWAddToCartWebViewController alloc] initWithCellModel:model];
        addToCartVC.startPage = model.detailUrl;
        [self.navigationController pushViewController:addToCartVC animated:YES];
    } else if (tableView == _fruitCutTableView) {
        UPWFruitListCellModel* model = _fruitCutListModel.data[indexPath.row];
        UPWAddToCartWebViewController *addToCartVC = [[UPWAddToCartWebViewController alloc] initWithCellModel:model];
        addToCartVC.startPage = model.detailUrl;
        [self.navigationController pushViewController:addToCartVC animated:YES];
    } else if (tableView == _fruitJuiceTableView) {
        UPWFruitListCellModel* model = _fruitJuiceListModel.data[indexPath.row];
        UPWAddToCartWebViewController *addToCartVC = [[UPWAddToCartWebViewController alloc] initWithCellModel:model];
        addToCartVC.startPage = model.detailUrl;
        [self.navigationController pushViewController:addToCartVC animated:YES];
    }
}

#pragma mark -
#pragma mark - 放入购物车
- (void)putInShoppingCart:(NSNotification *)notification
{
    //添加放入购物车动画
    //get the location of label in table view
    NSValue *value = notification.userInfo[@"position"];
    CGPoint lbCenter = value.CGPointValue;
    
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
    CGPoint endpoint = CGPointMake(200, CGRectGetHeight(_contentView.frame)+44);//[self.view convertPoint:btnCenter fromView:carBG];
    UIBezierPath *path = [UIBezierPath bezierPath];
    //动画起点
    CGPoint startPoint = [self.view convertPoint:lbCenter fromView:_freshFruitTableView];
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
    NSIndexPath *indexPath = notification.userInfo[@"indexPath"];
    UPWFruitListCellModel *fruitCellModel = nil;
    if (0 == _segmentIndex) {
        fruitCellModel = _freshFruitListModel.data[indexPath.row];
    } else if (1 == _segmentIndex) {
        fruitCellModel = _fruitCutListModel.data[indexPath.row];
    } else if (2 == _segmentIndex) {
        fruitCellModel = _fruitJuiceListModel.data[indexPath.row];
    }
    
    UPWShoppingCartCellModel *cartCellModel = [[UPWShoppingCartCellModel alloc] initWithDictionary:fruitCellModel.toDictionary error:nil];
    cartCellModel.fruitNum = @"1";
    UPWShoppingCartModel *cartModel = [[UPWShoppingCartModel alloc] initWithDictionary:[UPWFileUtil readContent:[UPWPathUtil shoppingCartPlistPath]] error:nil];
    if (!cartModel) {
        //本地购物车plist中没有数据，创造数据
        cartModel = [[UPWShoppingCartModel alloc] initWithDictionary:@{@"noFreightCondition":@"0", @"hasMore":@"0", @"data":@[cartCellModel.toDictionary]} error:nil];
    } else {
        //本地购物车plist中有数据，进行比对
        BOOL found = NO;
        for (NSInteger i = 0; i < cartModel.data.count; i++) {
            UPWShoppingCartCellModel *cellModel = cartModel.data[i];
            if ([cartCellModel.fruitId isEqualToString:cellModel.fruitId]) {
                cellModel.fruitNum = [NSString stringWithFormat:@"%d", cellModel.fruitNum.integerValue+1];
                [cartModel.data replaceObjectAtIndex:i withObject:cellModel];
                found = YES;
            }
        }
        if (!found) {
            [cartModel.data addObject:cartCellModel];
        }
    }
    [UPWFileUtil writeContent:cartModel.toDictionary path:[UPWPathUtil shoppingCartPlistPath]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshShoppingCart object:nil];
    
    [self showFlashInfo:@"已放入购物车"];
    
    [UPWBussUtil refreshCartDot];
}

@end
