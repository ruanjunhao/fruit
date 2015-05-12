//
//  UPWConfirmOrderViewController.m
//  wallet
//
//  Created by gcwang on 15/3/15.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWConfirmOrderViewController.h"
#import "UPWDeliveryAddressTableViewCell.h"
#import "UPWConfirmOrderTableViewCell.h"
#import "UPWSelectDeliveryAddressViewController.h"
#import "UPWAddDeliveryAddressViewController.h"
#import "UPWDeliveryRangeViewController.h"
#import "UPWTotalPricePanel.h"
#import "UPWActionSheet.h"
#import "UPWDeliveryAddressModel.h"
#import "UPWNotificationName.h"
#import "UPWBussUtil.h"
#import "UPWFileUtil.h"
#import "UPWPathUtil.h"

#define kHeightNormalHeader 20
#define kHeightShoppingCartHeader 40
#define kHeightNormalCell 44

typedef enum{
    ECashOnDeliveryPayType,
    EWeChatPayType,
    EALiPayType
}EPayType;

@interface UPWConfirmOrderViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    UITableView *_tableView;
    UPWTotalPricePanel *_totalPricePanel;
    
    UPWShoppingCartModel *_shoppingCartListModel;
    UPWDeliveryAddressModel *_deliveryAddrModel;
    
    EPayType _payType;
    EPageSource _pageSource;
    
    NSString *_naviTitle;
}

@end

@implementation UPWConfirmOrderViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationSelectedDeliveryAddress object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationAddNewDeliveryAddressSucceed object:nil];
}

- (id)initWithShoppingCartModel:(UPWShoppingCartModel *)model source:(EPageSource)pageSource
{
    self = [super init];
    if (self) {
        _shoppingCartListModel = [[UPWShoppingCartModel alloc] initWithDictionary:model.toDictionary error:nil];
        _pageSource = pageSource;
        switch (_pageSource) {
            case EShoppingCartSource:
                _naviTitle = @"确认订单";
                break;
            case EWaitPayingSource:
                _naviTitle = @"订单详情";
                break;
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNaviTitle:_naviTitle];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDeliveryAddr:) name:kNotificationSelectedDeliveryAddress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDeliveryAddr:) name:kNotificationAddNewDeliveryAddressSucceed object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSubview
{
    __weak UPWConfirmOrderViewController *wself = self;
    _totalPricePanel = [[UPWTotalPricePanel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_contentView.frame)-kHeightTotalPricePanel, CGRectGetWidth(_contentView.frame), kHeightTotalPricePanel)];
    _totalPricePanel.backgroundColor = [UIColor whiteColor];
    _totalPricePanel.panelStyle = (_pageSource==EShoppingCartSource?EConfirmOrderPanelStyle:EOrderDetailPanelStyle);
    _totalPricePanel.totalPrice = @"0";
    _totalPricePanel.noFreightCondition = @"";
    _totalPricePanel.submitButtonActionBlock = ^(){
        [wself submitAction];
    };
    [self calculateTotalPrice];
    [_contentView addSubview:_totalPricePanel];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topOffset, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame)-_topOffset-CGRectGetHeight(_totalPricePanel.frame)) style:UITableViewStylePlain];
    _tableView.backgroundColor = UP_COL_RGB(0xefeff4);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_contentView addSubview:_tableView];
}

#pragma mark -
#pragma mark - 计算总价
- (void)calculateTotalPrice
{
    NSInteger totalPrice = 0;
    for (UPWShoppingCartCellModel *cellModel in _shoppingCartListModel.data) {
        if (cellModel.checked) {
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
#pragma mark - 点击屏幕刷新
- (void)reloadData
{
    if ([UPWGlobalData sharedData].hasLogin) {
        //用户登录，获取地址列表
        [self showNetworkLoading:_contentView.center withRetryRect:_contentView.frame];
        [self getDeliveryAddrList];
    } else {
        //用户未登录，启动快速购买流程让用户添加地址
        UPWDeliveryAddressCellModel *cellModel = [[UPWDeliveryAddressCellModel alloc] initWithDictionary:[UPWFileUtil readContent:[UPWPathUtil deliveryAddrPlistPath]] error:nil];
        if (cellModel) {
            _deliveryAddrModel = [[UPWDeliveryAddressModel alloc] initWithDictionary:@{@"data":@[cellModel.toDictionary]} error:nil];
        }

        [self setupSubview];
    }
}

#pragma mark -
#pragma mark - 获取默认收货地址
- (void)getDeliveryAddrList
{
    //只请求一条地址
    NSDictionary *params = @{@"communityId":@"communityId", @"userId":@"userId", @"requestPage":@"1", @"pageSize": @"1"};
    UPWMessage* message = [UPWMessage messageDeliveryAddressWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        NSDictionary* params =  responseJSON;
        [wself updateDeliveryAddressWithParams:params];
    } fail:^(NSError * error) {
        [wself updateDeliveryAddressWithError:error];
        
#warning 测试数据
        NSDictionary* params =  @{@"hasMore":@"0", @"data":@[@{@"userName":@"鲜先生1", @"phoneNum":@"15893857483", @"userAddress":@"上海市浦东新区元泰路388号上海市浦东新区元泰路388号"}, @{@"userName":@"鲜先生2", @"phoneNum":@"15893857483", @"userAddress":@"上海市浦东新区元泰路388号"}, @{@"userName":@"鲜先生3", @"phoneNum":@"15893857483", @"userAddress":@"上海市浦东新区元泰路388号"}, @{@"userName":@"鲜先生4", @"phoneNum":@"15893857483", @"userAddress":@"上海市浦东新区元泰路388号"}]};
        [self updateDeliveryAddressWithParams:params];
    }];
    [self addMessage:message];
}

- (void)updateDeliveryAddressWithParams:(NSDictionary *)params
{
    [self hideNetworkStatusView];
    
    UPWDeliveryAddressModel *latestModel = [[UPWDeliveryAddressModel alloc] initWithDictionary:params error:nil];
    
    _deliveryAddrModel = [[UPWDeliveryAddressModel alloc] initWithDictionary:latestModel.toDictionary error:nil];
    
    [self setupSubview];
    
    [_tableView reloadData];
}

- (void)updateDeliveryAddressWithError:(NSError *)error
{
    [self showNetworkFailed];
    
    [self showFlashInfo:[self stringWithError:error]];
}

#pragma mark -
#pragma mark - tableView dataSource delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section || 1 == section) {
        return 1;
    } else {
        return _shoppingCartListModel.data.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.contentView.exclusiveTouch = YES;
        cell.contentView.multipleTouchEnabled = NO;
        
        cell.textLabel.textColor = UP_COL_RGB(0x333333);
        cell.textLabel.font = [UIFont systemFontOfSize:kConstantFont16];
        cell.textLabel.text = @"支持的配送范围";
        
        return cell;
    } else if (1 == indexPath.section) {
        if (_deliveryAddrModel.data.count <= 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.contentView.exclusiveTouch = YES;
            cell.contentView.multipleTouchEnabled = NO;
            
            UIButton *addAddrButton = [UIButton buttonWithType:UIButtonTypeCustom];
            addAddrButton.frame = CGRectMake(0, 0, kScreenWidth, kHeightDeliveryAddrCell);
            [addAddrButton setBackgroundColor:[UIColor clearColor]];
            [addAddrButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            addAddrButton.titleLabel.font = [UIFont systemFontOfSize:kConstantFont20];
            [addAddrButton setTitle:@"+ 添加收货地址" forState:UIControlStateNormal];
            addAddrButton.userInteractionEnabled = NO;
            [cell.contentView addSubview:addAddrButton];
            
            return cell;
        } else {
            UPWDeliveryAddressTableViewCell *cell = [[UPWDeliveryAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.contentView.exclusiveTouch = YES;
            cell.contentView.multipleTouchEnabled = NO;
            [cell setCellWithModel:_deliveryAddrModel.data[indexPath.row] cellCount:1 indexPath:indexPath];
            
            return cell;
        }
    } else {
        static NSString *tag = @"UPWFruitTableViewCell";
        UPWConfirmOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tag];
        if (cell==nil) {
            cell = [[UPWConfirmOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tag];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.contentView.exclusiveTouch = YES;
        cell.contentView.multipleTouchEnabled = NO;
        
        UPWShoppingCartCellModel *cellModel = _shoppingCartListModel.data[indexPath.row];
        [cell setCellWithModel:cellModel cellCount:_shoppingCartListModel.data.count indexPath:indexPath];
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section || 1 == section) {
        return kHeightNormalHeader;
    } else {
        return kHeightShoppingCartHeader + kHeightNormalHeader;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        return kHeightNormalCell;
    } else if (1 == indexPath.section) {
        return kHeightDeliveryAddrCell;
    } else {
        return kHeightConfirmOrderCell;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (0 == section || 1 == section) {
        return nil;
    } else {
        UIView *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kHeightShoppingCartHeader+kHeightNormalHeader)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UIView *placeHolderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kHeightNormalHeader)];
        placeHolderView.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(placeHolderView.frame), CGRectGetWidth(headerView.frame), CGRectGetHeight(headerView.frame)-CGRectGetHeight(placeHolderView.frame))];
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = UP_COL_RGB(0x333333);
        label.font = [UIFont systemFontOfSize:kConstantFont14];
        label.text = @"  水果清单：";
        [headerView addSubview:label];
        
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame)-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        [headerView addSubview:downImageView];
        
        return headerView;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (0 == indexPath.section) {
#warning 跳转到配送范围列表
        UPWDeliveryRangeViewController *deliveryRangeVC = [[UPWDeliveryRangeViewController alloc] init];
        [self.navigationController pushViewController:deliveryRangeVC animated:YES];
    } else if (1 == indexPath.section) {
        if (_deliveryAddrModel.data.count <= 0) {
            UPWAddDeliveryAddressViewController *addDeliveryAddrVC = [[UPWAddDeliveryAddressViewController alloc] init];
            [self.navigationController pushViewController:addDeliveryAddrVC animated:YES];
        } else {
            if ([UPWGlobalData sharedData].hasLogin) {
                UPWSelectDeliveryAddressViewController *selectDeliveryAddrVC = [[UPWSelectDeliveryAddressViewController alloc] initWithPageSource:EConfirmOrderPage];
                [self.navigationController pushViewController:selectDeliveryAddrVC animated:YES];
            } else {
                UPWAddDeliveryAddressViewController *addDeliveryAddrVC = [[UPWAddDeliveryAddressViewController alloc] initWithDeliveryAddrModel:_deliveryAddrModel.data[indexPath.row]];
                [self.navigationController pushViewController:addDeliveryAddrVC animated:YES];
            }
        }
    } else {
        return;
    }
}

#pragma mark -
#pragma mark - 添加新收获成功，重新选择一个新地址
- (void)refreshDeliveryAddr:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    [_deliveryAddrModel.data removeAllObjects];
    UPWDeliveryAddressCellModel *cellModel = userInfo[@"deliveryAddr"];
    _deliveryAddrModel = [[UPWDeliveryAddressModel alloc] initWithDictionary:@{@"data":@[cellModel.toDictionary]} error:nil];
    
    [_tableView reloadData];
    
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark -
#pragma mark - 提交订单确认 操作
- (void)submitAction
{
#warning 调起pickerView，让用户选择货到付款、微信支付、支付宝支付方式
    UPWActionSheet *actionSheet = [[UPWActionSheet alloc]
                                   initWithTitle:@"请选择支付方式"
                                   delegate:self
                                   cancelButtonTitle:UP_STR(@"kBtnCancel")
                                   destructiveButtonTitle:nil
                                   otherButtonTitles:@"货到付款", @"微信支付", @"支付宝支付" ,nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:_contentView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //货到付款
        _payType = ECashOnDeliveryPayType;
        switch (_pageSource) {
            case EShoppingCartSource:
            {
                [self uploadOrderWithPayType];
            }
                break;
            case EWaitPayingSource:
            {
                
            }
                break;
                
            default:
                break;
        }
    } else if (buttonIndex == 1)
    {
        //微信支付
        _payType = EWeChatPayType;
        switch (_pageSource) {
            case EShoppingCartSource:
            {
                [self uploadOrderWithPayType];
            }
                break;
            case EWaitPayingSource:
            {
                [self weChatPay];
            }
                break;
                
            default:
                break;
        }
    } else if(buttonIndex == 2) {
        //支付宝支付
        _payType = EALiPayType;
        switch (_pageSource) {
            case EShoppingCartSource:
            {
                [self uploadOrderWithPayType];
            }
                break;
            case EWaitPayingSource:
            {
                [self aLiPay];
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)uploadOrderWithPayType
{
#warning 暂不限制用户只有登录后才能购买
//    if (![UPWGlobalData sharedData].hasLogin) {
//        //弹出登录页面
//        [UPWBussUtil showLoginWithSuccessBlock:nil cancelBlock:nil completion:nil];
//        return;
//    }
    
    //只请求一条地址
    if (_deliveryAddrModel.data.count <= 0) {
        [self showFlashInfo:@"请添加收货地址"];
        return;
    }
    
    [self showWaitingView:@"正在提交，请稍等"];
    
    UPWDeliveryAddressCellModel *deliveryAddrCellModel = _deliveryAddrModel.data[0];
#warning 未登录时，userId上送空字符串@""
    NSString *userId = ([UPWGlobalData sharedData].accountInfo.userId==nil)?@"":[UPWGlobalData sharedData].accountInfo.userId;
    NSDictionary *addrInfo = @{@"province":deliveryAddrCellModel.addrInfo.province, @"city":deliveryAddrCellModel.addrInfo.city, @"region":deliveryAddrCellModel.addrInfo.region, @"detailAddr":deliveryAddrCellModel.addrInfo.detailAddr};
    NSDictionary *userInfo = @{@"userName":deliveryAddrCellModel.userName, @"phoneNum":deliveryAddrCellModel.phoneNum, @"addrInfo":addrInfo};
    NSDictionary *params = @{@"communityId":@"communityId", @"userId":userId, @"userInfo":userInfo, @"fruitInfo":_shoppingCartListModel.toDictionary[@"data"], @"totalPrice":_totalPricePanel.totalPrice};
    UPWMessage* message = [UPWMessage messageCommitOrderWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        [wself receivedUploadOrderWithParams:responseJSON[@"data"]];
    } fail:^(NSError * error) {
        [wself failedUploadOrderWithError:error];
        
//#warning 测试
//        [self receivedUploadOrderWithParams:params];
    }];
    [self addMessage:message];
}

- (void)receivedUploadOrderWithParams:(NSDictionary *)params
{
    [self hideWaitingView];
    
    [UPWFileUtil removeFile:[UPWPathUtil shoppingCartPlistPath]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshShoppingCart object:nil];
    
    switch (_payType) {
        case ECashOnDeliveryPayType:
        {
            
        }
            break;
        case EWeChatPayType:
        {
            [self weChatPay];
        }
            break;
        case EALiPayType:
        {
            [self aLiPay];
        }
            break;
            
        default:
            break;
    }
}

- (void)failedUploadOrderWithError:(NSError *)error
{
    [self hideWaitingView];
    
    [self showFlashInfo:[self stringWithError:error]];
}

#pragma mark -
#pragma mark - 微信支付
- (void)weChatPay
{
    #warning 跳转到支付页面
}

#pragma mark -
#pragma mark - 支付宝支付
- (void)aLiPay
{
    #warning 跳转到支付页面
}

@end
