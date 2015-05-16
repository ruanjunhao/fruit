//
//  UPWShoppingCartViewController.m
//  wallet
//
//  Created by gcwang on 15/3/14.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWShoppingCartViewController.h"
#import "UPWConfirmOrderViewController.h"
#import "UPWTotalPricePanel.h"
#import "UPWShoppingCartTableViewCell.h"
#import "UPWActionSheet.h"
#import "UPWCommonTableListModel.h"
#import "UPWShoppingCartModel.h"
#import "UPWNotificationName.h"
#import "UPWFileUtil.h"
#import "UPWPathUtil.h"
#import "UPWBussUtil.h"

@interface UPWShoppingCartViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    UITableView *_tableView;
    UPWTotalPricePanel *_totalPricePanel;
    
    UPWCommonTableListModel *_commonTableModel;
    UPWShoppingCartModel *_shoppingCartListModel;
    
    UPWActionSheet *_initiativeDelActionSheet;
    UPWActionSheet *_passiveDelActionSheet;
    
    UIButton *_addFruitButton;
}

@end

@implementation UPWShoppingCartViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationRefreshShoppingCart object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = NO;
        _commonTableModel = [[UPWCommonTableListModel alloc] init];
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
    
    [self setNaviTitle:@"购物车"];
    
    __weak UPWShoppingCartViewController *wself = self;
    _totalPricePanel = [[UPWTotalPricePanel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_contentView.frame)-kHeightTotalPricePanel, CGRectGetWidth(_contentView.frame), kHeightTotalPricePanel)];
    _totalPricePanel.backgroundColor = [UIColor whiteColor];
    _totalPricePanel.selectAll = YES;
    _totalPricePanel.totalPrice = @"0";
    _totalPricePanel.noFreightCondition = @"";
    _totalPricePanel.selectButtonActionBlock = ^(){
        [wself selectAllAction];
    };
    _totalPricePanel.deleteButtonActionBlock = ^(){
        [wself deleteAction];
    };
    _totalPricePanel.submitButtonActionBlock = ^(){
        [wself submitAction];
    };
    [_contentView addSubview:_totalPricePanel];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topOffset, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame)-_topOffset-CGRectGetHeight(_totalPricePanel.frame)) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self addPullToRefresh:_tableView withActionHandler:^{
        [wself pullToRefresh];
    }];
    [_contentView addSubview:_tableView];
    
    _addFruitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addFruitButton.frame = _tableView.frame;
    [_addFruitButton setBackgroundColor:[UIColor clearColor]];
    [_addFruitButton addTarget:self action:@selector(addFruitToCart) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_addFruitButton];
    CGFloat width = 80;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_addFruitButton.frame)-width)/2, (CGRectGetHeight(_addFruitButton.frame)-width)/2, width, width)];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = [UIImage imageNamed:@"cart_add_fruit"];
    [_addFruitButton addSubview:imageView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame)+10, CGRectGetWidth(_addFruitButton.frame), 20)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = UP_COL_RGB(0x666666);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:kConstantFont16];
    label.text  = @"添加宝贝到购物车";
    [_addFruitButton addSubview:label];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kNotificationRefreshShoppingCart object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - 添加水果到购物车
- (void)addFruitToCart
{
    self.tabBarController.selectedIndex = 1;
}

#pragma mark -
#pragma mark - 获取本地购物车数据，一期做本地
- (void)getLocalShoppingCartData
{
    [self didFinishedRefreshing:_tableView showPullToRefresh:YES];
    
    _shoppingCartListModel = [[UPWShoppingCartModel alloc] initWithDictionary:[UPWFileUtil readContent:[UPWPathUtil shoppingCartPlistPath]] error:nil];
    
    if (!_shoppingCartListModel) {
        [self showFlashInfo:@"购物车本地数据为空"];
    } else {
        //拉取数据后，购物车默认全选
        for (UPWShoppingCartCellModel *cellModel in _shoppingCartListModel.data) {
            cellModel.checked = [NSNumber numberWithBool:YES].stringValue;
        }
    }
    
    [self calculateTotalPrice];
    [_tableView reloadData];
    
    [UPWBussUtil refreshCartDot];
}

#pragma mark -
#pragma mark - 下拉刷新
- (void)pullToRefresh
{
    if (_commonTableModel.pullToRefreshing) {
        return;
    }
     
    _commonTableModel.pullToRefreshing = YES;

    [self getLocalShoppingCartData];
    
    /*
    if ([UPWGlobalData sharedData].hasLogin) {
        //用户已登录，也不从后台拿数据，以本地数据为准
        [self getShoppingCartList];
    } else {
        //未登录，从本地拿数据
        [self getLocalShoppingCartData];
    }
     */
}

#pragma mark -
#pragma mark - 点击屏幕刷新
- (void)reloadData
{
    [self getLocalShoppingCartData];
    
    /*
    if ([UPWGlobalData sharedData].hasLogin) {
        //用户已登录，也不从后台拿数据，以本地数据为准
        [self showNetworkLoading:_tableView.center withRetryRect:_tableView.frame];
        [self getShoppingCartList];
    } else {
        //未登录，从本地拿数据
        [self getLocalShoppingCartData];
    }
     */
}

#pragma mark -
#pragma mark - 获取购物车数据
- (void)getShoppingCartList
{
    NSDictionary *params = @{@"communityId":@"communityId", @"userId":[UPWGlobalData sharedData].accountInfo.userId};
    UPWMessage* message = [UPWMessage messageShoppingCartListWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        [wself receivedWithParams:responseJSON[@"data"]];
    } fail:^(NSError * error) {
        [wself failedWithError:error];
        
//#warning 测试数据
//        NSDictionary* params =  @{@"noFreightCondition":@"22", @"hasMore":@"0", @"data":@[@{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://youhui.95516.com/hybrid_v3/html/help/feedback.html", @"fruitName":@"苹果", @"fruitPrice":@"2.50", @"fruitNum":@"1", @"fruitPriceUnit":@"个", @"fruitId":@"000001"}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"苹果", @"fruitPrice":@"2.50", @"fruitNum":@"1", @"fruitPriceUnit":@"盒", @"fruitId":@"000001"}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"苹果", @"fruitPrice":@"2.50",  @"fruitNum":@"1.50", @"fruitPriceUnit":@"公斤", @"fruitId":@"000001"}, @{@"imageUrl":@"app/image/mchnt/coupon/D00000000012166_logo_list_app.jpg?time=20150130163602", @"detailUrl":@"http://www.baidu.com", @"fruitName":@"苹果", @"fruitPrice":@"2.50", @"fruitNum":@"1", @"fruitPriceUnit":@"个", @"fruitId":@"000001"}]};
//        [self receivedWithParams:params];
    }];
    [self addMessage:message];
}

- (void)receivedWithParams:(NSDictionary *)params
{
    [self hideNetworkStatusView];
    _commonTableModel.pullToRefreshing = NO;
    
    UPWShoppingCartModel *latestModel = [[UPWShoppingCartModel alloc] initWithDictionary:params error:nil];
    //拉取数据后，购物车默认全选
    for (UPWShoppingCartCellModel *cellModel in latestModel.data) {
        cellModel.checked = [NSNumber numberWithBool:YES].stringValue;
    }
    
    _shoppingCartListModel = [[UPWShoppingCartModel alloc] initWithDictionary:latestModel.toDictionary error:nil];
    
    //从后台获取购物车数据成功，不能缓存下来，以本地数据为准
//    [UPWFileUtil writeContent:_shoppingCartListModel.toDictionary path:[UPWPathUtil shoppingCartPlistPath]];
    
    [self calculateTotalPrice];
    
    [_tableView reloadData];
    
    [UPWBussUtil refreshCartDot];
    
    [self didFinishedRefreshing:_tableView showPullToRefresh:YES];
    [self didFinishedInfiniteScrolling:_tableView showInfiniteScrolling:_shoppingCartListModel.hasMore.boolValue];
}

- (void)failedWithError:(NSError *)error
{
    [self didFinishedRefreshing:_tableView showPullToRefresh:YES];
    [self didFinishedInfiniteScrolling:_tableView showInfiniteScrolling:YES];
    [self showNetworkFailed];
    _commonTableModel.pullToRefreshing = NO;
    
    [self showFlashInfo:[self stringWithError:error]];
}

#pragma mark -
#pragma mark - tableView dataSource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _addFruitButton.hidden = YES;
    if (_shoppingCartListModel.data.count <= 0) {
        _addFruitButton.hidden = NO;
    }
    self.fruitNum = [NSNumber numberWithInteger:_shoppingCartListModel.data.count].stringValue;
    
    return _shoppingCartListModel.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tag = @"UPWFruitTableViewCell";
    UPWShoppingCartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tag];
    if (cell==nil) {
        cell = [[UPWShoppingCartTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tag];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.contentView.exclusiveTouch = YES;
    cell.contentView.multipleTouchEnabled = NO;
    
    UPWShoppingCartCellModel *cellModel = _shoppingCartListModel.data[indexPath.row];
    [cell setCellWithModel:cellModel cellCount:_shoppingCartListModel.data.count indexPath:indexPath];
    
    __weak UPWShoppingCartViewController *wself = self;
    cell.editNumberBlock = ^(EEditStyle editStyle){
        [wself editNumberWithEditStyle:editStyle indexPath:indexPath];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kShoppingCartCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UPWShoppingCartCellModel *cellModel = _shoppingCartListModel.data[indexPath.row];
    cellModel.checked = [NSNumber numberWithBool:!cellModel.checked.boolValue].stringValue;
    [_shoppingCartListModel.data replaceObjectAtIndex:indexPath.row withObject:cellModel];
    
    UPWShoppingCartTableViewCell *cell = (UPWShoppingCartTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setChecked:cellModel.checked.boolValue];
    
    [self calculateTotalPrice];
}

#pragma mark -
#pragma mark - 计算总价
- (void)calculateTotalPrice
{
    NSInteger totalPrice = 0;
    for (UPWShoppingCartCellModel *cellModel in _shoppingCartListModel.data) {
        if (cellModel.checked.boolValue) {
            totalPrice += cellModel.fruitPrice.doubleValue * cellModel.fruitNum.doubleValue;
        }
    }
    _totalPricePanel.totalPrice = [NSString stringWithFormat:@"%d", totalPrice];
    if (totalPrice >= _shoppingCartListModel.noFreightCondition.doubleValue) {
        _totalPricePanel.noFreightCondition = @"免运费";
    } else {
        _totalPricePanel.noFreightCondition = [NSString stringWithFormat:@"满%@免运费", _shoppingCartListModel.noFreightCondition];
    }
    
    [_totalPricePanel setNeedsLayout];
}

#pragma mark -
#pragma mark - 全选、反选操作
- (void)selectAllAction
{
    _totalPricePanel.selectAll = !_totalPricePanel.selectAll;
    if (_totalPricePanel.selectAll) {
        for (NSInteger i = 0; i < _shoppingCartListModel.data.count; i++) {
            UPWShoppingCartCellModel *cellModel = _shoppingCartListModel.data[i];
            cellModel.checked = [NSNumber numberWithBool:YES].stringValue;
            [_shoppingCartListModel.data replaceObjectAtIndex:i withObject:cellModel];
        }
    } else {
        for (NSInteger i = 0; i < _shoppingCartListModel.data.count; i++) {
            UPWShoppingCartCellModel *cellModel = _shoppingCartListModel.data[i];
            cellModel.checked = [NSNumber numberWithBool:NO].stringValue;
            [_shoppingCartListModel.data replaceObjectAtIndex:i withObject:cellModel];
        }
    }
    
    [self calculateTotalPrice];
    
    [_tableView reloadData];
}

#pragma mark -
#pragma mark - 修改水果数量
- (void)editNumberWithEditStyle:(EEditStyle)editStyle indexPath:(NSIndexPath *)indexPath
{
    UPWShoppingCartCellModel *cellModel = _shoppingCartListModel.data[indexPath.row];
    if (editStyle == increaseOneEditStyle) {
        //+1
        cellModel.fruitNum = [NSString stringWithFormat:@"%d", cellModel.fruitNum.integerValue + 1];
    } else if (editStyle == decreaseOneEditStyle) {
        //-1
        cellModel.fruitNum = [NSString stringWithFormat:@"%d", cellModel.fruitNum.integerValue - 1];
    } else if (editStyle == freeEditStyle) {
        //弹出pickerView或键盘
    }
    
    if (cellModel.fruitNum.doubleValue <= 0) {
        _passiveDelActionSheet = [[UPWActionSheet alloc]
                                     initWithTitle:@"确认删除宝贝"
                                     delegate:self
                                     cancelButtonTitle:UP_STR(@"kBtnCancel")
                                     destructiveButtonTitle:@"删除"
                                     otherButtonTitles:nil];
        _passiveDelActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [_passiveDelActionSheet showInView:_contentView];
    } else {
        [_shoppingCartListModel.data replaceObjectAtIndex:indexPath.row withObject:cellModel];
        
        //只有当真正删除后，才修改本地购物车数据
        [UPWFileUtil writeContent:_shoppingCartListModel.toDictionary path:[UPWPathUtil shoppingCartPlistPath]];
    }
    
    [_tableView reloadData];

    [self calculateTotalPrice];
    
    [UPWBussUtil refreshCartDot];
}

#pragma mark -
#pragma mark - 删除
- (void)deleteAction
{
    BOOL hasChecked = NO;
    for (NSInteger i = 0; i < _shoppingCartListModel.data.count; i++) {
        UPWShoppingCartCellModel *cellModel = _shoppingCartListModel.data[i];
        if (cellModel.checked.boolValue) {
            hasChecked = YES;
            break;
        }
    }
    if (!hasChecked) {
        [self showFlashInfo:@"请选择要删除的宝贝"];
        return;
    }
    
    _initiativeDelActionSheet = [[UPWActionSheet alloc]
                                   initWithTitle:@"确认删除宝贝"
                                   delegate:self
                                   cancelButtonTitle:UP_STR(@"kBtnCancel")
                                   destructiveButtonTitle:@"删除"
                                   otherButtonTitles:nil];
    _initiativeDelActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [_initiativeDelActionSheet showInView:_contentView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == _initiativeDelActionSheet) {
        if (buttonIndex == 0)
        {
            NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < _shoppingCartListModel.data.count; i++) {
                UPWShoppingCartCellModel *cellModel = _shoppingCartListModel.data[i];
                if (cellModel.checked.boolValue) {
                    [deleteArray addObject:cellModel];
                }
            }
            [_shoppingCartListModel.data removeObjectsInArray:deleteArray];
            [_tableView reloadData];
            [UPWFileUtil writeContent:_shoppingCartListModel.toDictionary path:[UPWPathUtil shoppingCartPlistPath]];
            [self calculateTotalPrice];
        }
    } else if (actionSheet == _passiveDelActionSheet) {
        if (0 == buttonIndex) {
            NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < _shoppingCartListModel.data.count; i++) {
                UPWShoppingCartCellModel *cellModel = _shoppingCartListModel.data[i];
                if (cellModel.fruitNum.doubleValue <= 0) {
                    [deleteArray addObject:cellModel];
                }
            }
            
            [_shoppingCartListModel.data removeObjectsInArray:deleteArray];
        } else {
            for (NSInteger i = 0; i < _shoppingCartListModel.data.count; i++) {
                UPWShoppingCartCellModel *cellModel = _shoppingCartListModel.data[i];
                if (cellModel.fruitNum.doubleValue <= 0) {
                    cellModel.fruitNum = [NSString stringWithFormat:@"%d", cellModel.fruitNum.integerValue + 1];
                    [_shoppingCartListModel.data replaceObjectAtIndex:i withObject:cellModel];
                }
            }
        }
        
        [_tableView reloadData];
        //修改本地购物车数据
        [UPWFileUtil writeContent:_shoppingCartListModel.toDictionary path:[UPWPathUtil shoppingCartPlistPath]];
        
        [self calculateTotalPrice];
    }
    
    [UPWBussUtil refreshCartDot];
}

#pragma mark -
#pragma mark - 结算操作
- (void)submitAction
{
    if (_shoppingCartListModel.data.count <= 0) {
        [self showFlashInfo:@"请添加商品至购物车"];
        return;
    }
    
    UPWShoppingCartModel *submitShoppingCartModel = [[UPWShoppingCartModel alloc] initWithDictionary:_shoppingCartListModel.toDictionary error:nil];
    [submitShoppingCartModel.data removeAllObjects];
    for (UPWShoppingCartCellModel *cellModel in _shoppingCartListModel.data) {
        if (cellModel.checked.boolValue) {
            [submitShoppingCartModel.data addObject:cellModel];
        }
    }
    
    if (submitShoppingCartModel.data.count <= 0) {
        [self showFlashInfo:@"请选择商品"];
        return;
    }
    
    UPWConfirmOrderViewController *confirmOrderVC = [[UPWConfirmOrderViewController alloc] initWithShoppingCartModel:submitShoppingCartModel source:EShoppingCartSource];
    [self.navigationController pushViewController:confirmOrderVC animated:YES];
    
    //把本地购物车偷偷同步到后台
    if ([UPWGlobalData sharedData].hasLogin) {
        [self uploadShoppingCartToServer];
    }
}

#pragma mark -
#pragma mark - 与后台同步购物车数据
- (void)uploadShoppingCartToServer
{
    [self didFinishedRefreshing:_tableView showPullToRefresh:YES];
    
    UPWShoppingCartModel *shoppingCartListModel = [[UPWShoppingCartModel alloc] initWithDictionary:[UPWFileUtil readContent:[UPWPathUtil shoppingCartPlistPath]] error:nil];
    
    if (!shoppingCartListModel) {
        
    } else {
        UPWMessage* message = [UPWMessage messageSyncShoppingCartListWithParams:shoppingCartListModel.toDictionary];
        [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
            
        } fail:^(NSError * error) {
            [self showFlashInfo:@"同步购物车失败"];
        }];
        [self addMessage:message];
    }
}

@end
