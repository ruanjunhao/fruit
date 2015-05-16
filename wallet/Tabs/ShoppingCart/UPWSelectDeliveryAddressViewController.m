//
//  UPWSelectDeliveryAddressViewController.m
//  wallet
//
//  Created by gcwang on 15/3/16.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWSelectDeliveryAddressViewController.h"
#import "UPWAddDeliveryAddressViewController.h"
#import "UPWDeliveryAddressTableViewCell.h"
#import "UPWCommonTableListModel.h"
#import "UPWDeliveryAddressModel.h"
#import "UPWNotificationName.h"

@interface UPWSelectDeliveryAddressViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    
    UPWCommonTableListModel *_commonTableModel;
    UPWDeliveryAddressModel *_deliveryAddrModel;
    
    EDeliveryAddrPageSource _pageSource;
}

@end

@implementation UPWSelectDeliveryAddressViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationAddNewDeliveryAddressSucceed object:nil];
}

- (id)initWithPageSource:(EDeliveryAddrPageSource)pageSource
{
    self = [super init];
    if (self) {
        _pageSource = pageSource;
        _commonTableModel = [[UPWCommonTableListModel alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_pageSource == EConfirmOrderPage) {
        [self setNaviTitle:@"选择收货地址"];
    } else if (_pageSource == EMineInfoPage) {
        [self setNaviTitle:@"我的地址"];
    }
    
    UIButton *addNewAddrButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addNewAddrButton.frame = CGRectMake(0, CGRectGetHeight(_contentView.frame)-44, CGRectGetWidth(_contentView.frame), 44);
    addNewAddrButton.layer.borderWidth = 0.5;
    addNewAddrButton.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
    [addNewAddrButton setBackgroundColor:[UIColor whiteColor]];
    [addNewAddrButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    addNewAddrButton.titleLabel.font = [UIFont systemFontOfSize:kConstantFont16];
    [addNewAddrButton setTitle:@"添加新收获地址" forState:UIControlStateNormal];
    [addNewAddrButton addTarget:self action:@selector(addNewAddr:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:addNewAddrButton];
    
    __weak UPWSelectDeliveryAddressViewController *wself = self;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topOffset, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame)-_topOffset-CGRectGetHeight(addNewAddrButton.frame)) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self addInfiniteScrolling:_tableView withActionHandler:^{
        [wself loadMore];
    }];
    [_contentView addSubview:_tableView];

    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewAddrSucceed:) name:kNotificationAddNewDeliveryAddressSucceed object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 上拉加载更多
- (void)loadMore
{
    if (_commonTableModel.loadMore || !_deliveryAddrModel.hasMore) {
        return;
    }
    
    _commonTableModel.loadMore = YES;
    
    [self getDeliveryAddressList];
}

#pragma mark -
#pragma mark - 点击屏幕刷新
- (void)reloadData
{
    [self showNetworkLoading:_tableView.center withRetryRect:_tableView.frame];
    [self getDeliveryAddressList];
}

#pragma mark -
#pragma mark - 获取我的地址列表
- (void)getDeliveryAddressList
{
    NSDictionary *params = @{@"communityId":@"communityId", @"userId":@"userId", @"requestPage":@"1", @"pageSize": @"1"};
    UPWMessage* message = [UPWMessage messageDeliveryAddressWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        //        wself.status |= UPWImgHotSecKillComplete;
        
        NSDictionary* params =  responseJSON;
        [wself updateDeliveryAddrListWithParams:params];
    } fail:^(NSError * error) {
        [wself updateDeliveryAddrListWithError:error];
        
#warning 测试数据
        NSDictionary* params =  @{@"hasMore":@"0", @"data":@[@{@"userName":@"鲜先生1", @"phoneNum":@"15893857483", @"userAddress":@"上海市浦东新区元泰路388号上海市浦东新区元泰路388号"}, @{@"userName":@"鲜先生2", @"phoneNum":@"15893857483", @"userAddress":@"上海市浦东新区元泰路388号"}, @{@"userName":@"鲜先生3", @"phoneNum":@"15893857483", @"userAddress":@"上海市浦东新区元泰路388号"}, @{@"userName":@"鲜先生4", @"phoneNum":@"15893857483", @"userAddress":@"上海市浦东新区元泰路388号"}]};
        [self updateDeliveryAddrListWithParams:params];
    }];
    [self addMessage:message];
}

- (void)updateDeliveryAddrListWithParams:(NSDictionary *)params
{
    [self hideNetworkStatusView];
    _commonTableModel.loadMore = NO;
    _commonTableModel.requestPage += 1;
    
    UPWDeliveryAddressModel *latestModel = [[UPWDeliveryAddressModel alloc] initWithDictionary:params error:nil];
    
    if (!_deliveryAddrModel) {
        _deliveryAddrModel = [[UPWDeliveryAddressModel alloc] initWithDictionary:latestModel.toDictionary error:nil];
    } else {
        [_deliveryAddrModel.data addObjectsFromArray:latestModel.data];
    }
    
    [_tableView reloadData];
    
    [self didFinishedRefreshing:_tableView showPullToRefresh:YES];
    [self didFinishedInfiniteScrolling:_tableView showInfiniteScrolling:_deliveryAddrModel.hasMore.boolValue];
}

- (void)updateDeliveryAddrListWithError:(NSError *)error
{
    [self didFinishedRefreshing:_tableView showPullToRefresh:YES];
    [self didFinishedInfiniteScrolling:_tableView showInfiniteScrolling:YES];
    [self showNetworkFailed];
    _commonTableModel.loadMore = NO;
    
    [self showFlashInfo:[self stringWithError:error]];
    //        wself.status |= UPWImgHotSecKillComplete;
}

#pragma mark -
#pragma mark - tableView dataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _deliveryAddrModel.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tag = @"UPWFruitTableViewCell";
    UPWDeliveryAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tag];
    if (cell==nil) {
        cell = [[UPWDeliveryAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tag];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.contentView.exclusiveTouch = YES;
    cell.contentView.multipleTouchEnabled = NO;
    
    UPWDeliveryAddressCellModel *cellModel = _deliveryAddrModel.data[indexPath.row];
    [cell setCellWithModel:cellModel cellCount:_deliveryAddrModel.data.count indexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeightDeliveryAddrCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UPWDeliveryAddressCellModel *cellModel = _deliveryAddrModel.data[indexPath.row];
    if (_pageSource == EConfirmOrderPage) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSelectedDeliveryAddress object:nil userInfo:@{@"deliveryAddr":cellModel}];
    } else if (_pageSource == EMineInfoPage) {
        UPWAddDeliveryAddressViewController *addDeliveryAddrVC = [[UPWAddDeliveryAddressViewController alloc] initWithDeliveryAddrModel:cellModel];
        [self.navigationController pushViewController:addDeliveryAddrVC animated:YES];
    }
}

#pragma mark -
#pragma mark - 添加新收获地址
- (void)addNewAddr:(id)sender
{
    UPWAddDeliveryAddressViewController *addDeliveryAddrVC = [[UPWAddDeliveryAddressViewController alloc] init];
    [self.navigationController pushViewController:addDeliveryAddrVC animated:YES];
}

#pragma mark -
#pragma mark - 添加新收获成功
- (void)addNewAddrSucceed:(NSNotification *)notification
{
    _commonTableModel.requestPage = 1;
    [_deliveryAddrModel.data removeAllObjects];
    
    [_tableView reloadData];
    
    [self reloadData];
}

@end
