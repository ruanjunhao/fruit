//
//  UPWMineViewController.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

#import "UPWMineViewController.h"
#import "UPWAccountInfoTableViewCell.h"
#import "UPWMineInfoViewController.h"
#import "UPWMyOrderViewController.h"
#import "UPWSettingViewController.h"
#import "UPWAccountInfoModel.h"
#import "UPWNotificationName.h"
#import "UPWBussUtil.h"
#import "UPWPathUtil.h"
#import "UPWFileUtil.h"

#define kHeightOtherCell 44
#define kHeightCellHeader 20

@interface UPWMineViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    
    NSArray* _titleArray;
    NSArray* _imageArray;
    UPWAccountInfoModel *_accountInfoModel;
}

@end


@implementation UPWMineViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLoginSucceed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationRefreshAccountInfo object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationlogoutSucceed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationTapMineTab object:nil];
    
    [self cancelPendingMessages];
}

//我的页面采集
- (void)trackPageBegin
{
    [UPWDataCollectMgr upTrackPageBegin:@"MineView"];
}

- (void)trackPageEnd
{
    [UPWDataCollectMgr upTrackPageEnd:@"MineView"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _contentView.backgroundColor = [UIColor whiteColor];
    
    [self setNaviTitle:@"我"];
    
    //, @"我的红包"
    _titleArray = @[@[@"个人信息"], @[@"我的订单"], @[@"设置"]];//@[@[@"个人信息"], @[@"待支付订单", @"完成订单"], @[@"设置"]]
    _accountInfoModel = [[UPWAccountInfoModel alloc] initWithDictionary:@{@"nickname":@"昵称", @"phoneNum":@"手机号", @"headImageUrl":@"", @"localImageName":@""} error:nil];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topOffset, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame)) style:UITableViewStylePlain];
    _tableView.backgroundColor = UP_COL_RGB(0xefeff4);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentView addSubview:_tableView];
    
    [self reloadData];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginSucceed:) name:kNotificationLoginSucceed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAccountInfo) name:kNotificationRefreshAccountInfo object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogout:) name:kNotificationlogoutSucceed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapMineTab:) name:kNotificationTapMineTab object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark -
#pragma mark - 获取账户信息
- (void)reloadData
{
    [self refreshAccountInfo];
}

#pragma mark -
#pragma mark - 点击我的Tab，当accountInfo为空，则刷新accountInfo
- (void)tapMineTab:(NSNotification *)notification
{
    if (!_accountInfoModel) {
        [self refreshAccountInfo];
    }
}

#pragma mark -
#pragma mark 刷新AccountInfo
- (void)refreshAccountInfo
{
    if (![UPWGlobalData sharedData].hasLogin) {
        [_tableView reloadData];
        return;
    }
    
    __weak UPWMineViewController* weakSelf = self;
    
    NSDictionary *params = @{@"userId":[UPWGlobalData sharedData].accountInfo.userId};
    UPWMessage* message = [UPWMessage messageAccountInfoWithParams:params];
    [self addMessage:message];
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        [weakSelf succeedAccountInfoWithResponseJSON:responseJSON[@"data"]];
    } fail:^(NSError *error) {
        [weakSelf failedAccountInfoWithError:error];
    }];
}

- (void)succeedAccountInfoWithResponseJSON:(NSDictionary*)responseJSON
{
    _accountInfoModel = [[UPWAccountInfoModel alloc] initWithDictionary:responseJSON error:nil];
    
    [UPWFileUtil writeContent:[_accountInfoModel toDictionary] path:[UPWPathUtil accountInfoPlistPath]];
    
    [UPWGlobalData sharedData].accountInfo = _accountInfoModel;
    
    [_tableView reloadData];
}

- (void)failedAccountInfoWithError:(NSError*)error
{
    _accountInfoModel = [[UPWAccountInfoModel alloc] initWithDictionary:[UPWFileUtil readContent:[UPWPathUtil accountInfoPlistPath]] error:nil];
    if (!_accountInfoModel) {
        [self showFlashInfo:[self stringWithError:error]];
    } else {
        [UPWFileUtil writeContent:[_accountInfoModel toDictionary] path:[UPWPathUtil accountInfoPlistPath]];
        
        [UPWGlobalData sharedData].accountInfo = _accountInfoModel;
    }
    
    //主要用于刷新头像
    [_tableView reloadData];
}

#pragma mark -
#pragma mark - tableView dataSource delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_titleArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        static NSString *accountInfoIdentifier = @"UPWAccountInfoTableViewCell";
        UPWAccountInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:accountInfoIdentifier];
        if (cell == nil) {
            cell = [[UPWAccountInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:accountInfoIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.contentView.exclusiveTouch = YES;
        cell.contentView.multipleTouchEnabled = NO;
        
        _accountInfoModel.localImageName = [self faceImageName];
        [cell setCellWithModel:_accountInfoModel cellCount:1 indexPath:indexPath];
        
        return cell;
    } else {
        static NSString *otherIdentifier = @"OtherIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:otherIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:otherIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.contentView.exclusiveTouch = YES;
        cell.contentView.multipleTouchEnabled = NO;
        
        cell.textLabel.textColor = UP_COL_RGB(0x333333);
        cell.textLabel.font = [UIFont systemFontOfSize:kConstantFont16];
        cell.textLabel.text = _titleArray[indexPath.section][indexPath.row];
        
        NSInteger count = [_titleArray[indexPath.section] count];
        
        if (1 == count) {
            UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeightOtherCell-0.5, kScreenWidth, 0.5)];
            downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
            downImageView.tag = 999;
            [cell.contentView addSubview:downImageView];
        } else if (count > 1 && (0 == indexPath.row)) {
            UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kHeightOtherCell-0.5, kScreenWidth, 0.5)];
            downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
            downImageView.tag = 999;
            [cell.contentView addSubview:downImageView];
        } else if (count > 1 && (count-1 == indexPath.row)) {
            UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeightOtherCell-0.5, kScreenWidth, 0.5)];
            downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
            downImageView.tag = 999;
            [cell.contentView addSubview:downImageView];
        } else {
            UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kHeightOtherCell-0.5, kScreenWidth, 0.5)];
            downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
            downImageView.tag = 999;
            [cell.contentView addSubview:downImageView];
        }
        
        return cell;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeightCellHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        return kHeightAccountInfoCell;
    } else {
        return kHeightOtherCell;
    }
    return 0;
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
    
    if (![UPWGlobalData sharedData].hasLogin) {
        //弹出登录页面
        [UPWBussUtil showLoginWithSuccessBlock:nil cancelBlock:nil completion:nil];
        return;
    }
    
    if (0 == indexPath.section) {
        //跳转到个人信息页面
        UPWMineInfoViewController *mineInfoVC = [[UPWMineInfoViewController alloc] init];
        [self.navigationController pushViewController:mineInfoVC animated:YES];
    } else if (1 == indexPath.section) {
        if (0 == indexPath.row) {
            //跳转到我的订单
            UPWMyOrderViewController *waitPayingOrderVC = [[UPWMyOrderViewController alloc] init];
            [self.navigationController pushViewController:waitPayingOrderVC animated:YES];
        } else if (1 == indexPath.row) {
           #warning //跳转到我的红包
        }
    } else if (2 == indexPath.section) {
        //跳转到设置页面
        UPWSettingViewController *settingVC = [[UPWSettingViewController alloc] init];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
}

#pragma mark -
#pragma mark - 获取头像
- (NSString*)faceImageName
{
    NSString *path =  [UPWPathUtil userDirectoryPath:[UPWGlobalData sharedData].accountInfo.userId];
    NSString * imagePath = [path stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.jpg",[UPWGlobalData sharedData].accountInfo.userId]];
    
    return imagePath;
}

#pragma mark -
#pragma mark - 接收登录成功的通知
- (void)userLoginSucceed:(NSNotification*)notification
{
    [UPWGlobalData sharedData].hasLogin = YES;
    
    _accountInfoModel = notification.userInfo[@"accountInfo"];
    
    [_tableView reloadData];
}

#pragma mark -
#pragma mark 退出登录
- (void)handleLogout:(NSNotification *)notification
{
    [UPWGlobalData sharedData].hasLogin = NO;
    
    _accountInfoModel.localImageName = nil;
    _accountInfoModel.nickname = @"昵称";
    _accountInfoModel.phoneNum = @"手机号";
    _accountInfoModel.headImageUrl = nil;
    
    [_tableView reloadData];
    
    [self.navigationController popToViewController:self animated:YES];
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
