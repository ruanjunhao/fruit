//
//  UPWMyOrderViewController.m
//  wallet
//
//  Created by gcwang on 15/3/24.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWMyOrderViewController.h"
#import "UPWMyOrderTableViewCell.h"
#import "UPWConfirmOrderViewController.h"
#import "UPWMyOrderModel.h"
#import "UPWCommonTableListModel.h"

#define kHeightCellHeader 20

@interface UPWMyOrderViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    UPWMyOrderModel *_myOrderModel;
    UPWCommonTableListModel *_commonTableModel;
}

@end

@implementation UPWMyOrderViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _commonTableModel = [[UPWCommonTableListModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _contentView.backgroundColor = UP_COL_RGB(0xefeff4);
    
    [self setNaviTitle:@"我的订单"];
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 上拉加载更多
- (void)loadMore
{
    if (_commonTableModel.pullToRefreshing || _commonTableModel.loadMore || !_myOrderModel.hasMore) {
        return;
    }
    
    _commonTableModel.loadMore = YES;
    
    __weak UPWMyOrderViewController* weakSelf = self;
    
    NSDictionary *params = @{@"userId":@"userId", @"orderStatus":@"0", @"requestPage":[NSNumber numberWithInteger:_commonTableModel.requestPage].stringValue, @"pageSize": UP_STR(@"kStrPageSize")};
    UPWMessage* message = [UPWMessage messageOrderListWithParams:params];
    [self addMessage:message];
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        [weakSelf receivedWithMessage:responseJSON];
    } fail:^(NSError *error) {
        [weakSelf receivedWithError:error];
    }];
}

#pragma mark -
#pragma mark - 获取订单列表
- (void)reloadData
{
    [self showNetworkLoading];
    
    __weak UPWMyOrderViewController* wself = self;
    
    NSDictionary *params = @{@"userId":@"userId", @"orderStatus":@"0", @"requestPage":[NSNumber numberWithInteger:_commonTableModel.requestPage].stringValue, @"pageSize": UP_STR(@"kStrPageSize")};
    UPWMessage* message = [UPWMessage messageOrderListWithParams:params];
    [self addMessage:message];
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        [wself hideNetworkStatusView];
        
        [wself receivedWithMessage:responseJSON];
    } fail:^(NSError *error) {
        [wself showNetworkFailed];
        
        [wself receivedWithError:error];
        
//#warning 测试数据
//        NSDictionary* params =  @{@"noFreightCondition":@"22", @"hasMore":@"0", @"data":@[@{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://youhui.95516.com/hybrid_v3/html/help/feedback.html", @"fruitName":@"苹果", @"fruitPrice":@"2.50", @"fruitNum":@"1", @"fruitPriceUnit":@"个", @"fruitId":@"000001", @"orderId":@"91326497631274231", @"imageUrlList":@[@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602"]}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"苹果", @"fruitPrice":@"2.50", @"fruitNum":@"1", @"fruitPriceUnit":@"盒", @"fruitId":@"000001", @"orderId":@"91326497631274231", @"imageUrlList":@[@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602"]}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"苹果", @"fruitPrice":@"2.50",  @"fruitNum":@"1.50", @"fruitPriceUnit":@"公斤", @"fruitId":@"000001", @"orderId":@"91326497631274231", @"imageUrlList":@[@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602"]}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"苹果", @"fruitPrice":@"2.50", @"fruitNum":@"1", @"fruitPriceUnit":@"个", @"fruitId":@"000001", @"orderId":@"91326497631274231", @"imageUrlList":@[@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602",@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602"]}]};
//        [self receivedWithMessage:params];
    }];
}

- (void)receivedWithMessage:(NSDictionary*)responseJSON
{
    [self hideNoContentView];
    [self hideNetworkStatusView];
    _commonTableModel.loadMore = NO;
    _commonTableModel.requestPage += 1;
    
    UPWMyOrderModel *latestModel = [[UPWMyOrderModel alloc] initWithDictionary:responseJSON error:nil];

    //此操作用于后面计算总价
    for (UPWMyOrderCellModel *orderCellModel in latestModel.data) {
        for (UPWShoppingCartCellModel *cartCellModel in orderCellModel.orderList) {
            cartCellModel.checked = [NSNumber numberWithBool:YES].stringValue;
        }
    }
    
    if (!_myOrderModel) {
        _myOrderModel = [[UPWMyOrderModel alloc] initWithDictionary:latestModel.toDictionary error:nil];
    } else {
        [_myOrderModel.data addObjectsFromArray:latestModel.data];
    }
    
    if (!_tableView) {
        UPWMyOrderViewController __weak *wself = self;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topOffset, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame)-_topOffset) style:UITableViewStylePlain];
        _tableView.backgroundColor = UP_COL_RGB(0xefeff4);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addInfiniteScrolling:_tableView withActionHandler:^{
            [wself loadMore];
        }];
        [_contentView addSubview:_tableView];
    }
    
    if (_myOrderModel.data.count <= 0) {
        [self showNoContentView:_tableView.center];
    }
    
    [_tableView reloadData];
    
    [self didFinishedInfiniteScrolling:_tableView showInfiniteScrolling:_myOrderModel.hasMore.boolValue];
}

- (void)receivedWithError:(NSError*)error
{
    [self didFinishedInfiniteScrolling:_tableView showInfiniteScrolling:YES];
    _commonTableModel.loadMore = NO;
    
    [self showFlashInfo:[self stringWithError:error]];
}

#pragma mark -
#pragma mark - tableView dataSource delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _myOrderModel.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"UPWMyOrderTableViewCell";
    UPWMyOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UPWMyOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.contentView.exclusiveTouch = YES;
    cell.contentView.multipleTouchEnabled = NO;

    [cell setCellWithModel:_myOrderModel.data[indexPath.section]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeightCellHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeightWaitPayingOrderCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kHeightCellHeader)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeightCellHeader-0.5, kScreenWidth, 0.5)];
    downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
    [headerView addSubview:downImageView];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UPWMyOrderCellModel *orderCellModel = _myOrderModel.data[indexPath.section];
    UPWShoppingCartModel *shoppingCartModel = [[UPWShoppingCartModel alloc] initWithDictionary:@{@"data":orderCellModel.toDictionary[@"orderList"]} error:nil];
    UPWConfirmOrderViewController *confirmOrderVC = [[UPWConfirmOrderViewController alloc] initWithShoppingCartModel:shoppingCartModel source:EWaitPayingSource];
    [self.navigationController pushViewController:confirmOrderVC animated:YES];
    
}

#pragma mark -
#pragma mark - 去除uitableview headerView的粘性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = kHeightCellHeader;
    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y >= sectionHeaderHeight)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

@end
