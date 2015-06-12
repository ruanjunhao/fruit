//
//  UPWSettingViewController.m
//  wallet
//
//  Created by gcwang on 15/3/25.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWSettingViewController.h"
#import "UPWWebViewController.h"
#import "UPWActionSheet.h"
#import "UPWNotificationName.h"
#import "UPWPathUtil.h"

#define kHeightCell 44
#define kHeightCellHeader 20

@interface UPWSettingViewController () <UITableViewDataSource, UITableViewDelegate ,UIActionSheetDelegate>
{
    UITableView *_tableView;
    
    NSArray* _titleArray;
}

@end

@implementation UPWSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _contentView.backgroundColor = [UIColor whiteColor];
    
    [self setNaviTitle:@"设置"];
    
    //, @"欢迎页", @"功能介绍"
    _titleArray = @[@[@"去评分"], @[@"退出登录"]];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topOffset, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame)) style:UITableViewStylePlain];
    _tableView.backgroundColor = UP_COL_RGB(0xefeff4);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentView addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (_titleArray.count-1 == indexPath.section) {
        static NSString *logoutIdentifier = @"LogoutIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:logoutIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:logoutIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.contentView.exclusiveTouch = YES;
        cell.contentView.multipleTouchEnabled = NO;
        
        cell.textLabel.textColor = UP_COL_RGB(0x333333);
        cell.textLabel.text = _titleArray[indexPath.section][indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:kConstantFont16];
        
        UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeightCell-0.5, kScreenWidth, 0.5)];
        downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
        [cell.contentView addSubview:downImageView];
        
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
        cell.textLabel.text = _titleArray[indexPath.section][indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:kConstantFont16];
        
        NSInteger count = [_titleArray[indexPath.section] count];
        
        if (1 == count) {
            UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeightCell-0.5, kScreenWidth, 0.5)];
            downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
            downImageView.tag = 999;
            [cell.contentView addSubview:downImageView];
        } else if (count > 1 && (0 == indexPath.row)) {
            UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kHeightCell-0.5, kScreenWidth, 0.5)];
            downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
            downImageView.tag = 999;
            [cell.contentView addSubview:downImageView];
        } else if (count > 1 && (count-1 == indexPath.row)) {
            UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kHeightCell-0.5, kScreenWidth, 0.5)];
            downImageView.backgroundColor = UP_COL_RGB(0xd4d4d4);
            downImageView.tag = 999;
            [cell.contentView addSubview:downImageView];
        } else {
            UIImageView *downImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, kHeightCell-0.5, kScreenWidth, 0.5)];
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
    return kHeightCell;
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
    
    if (0 == indexPath.section) {
        if (0 == indexPath.row) {
#warning 跳转到去评分页面
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[UPWAppUtil ratingAppStoreUrlById:kAppStoreId]]];
        } else if (1 == indexPath.row) {
#warning 跳转到欢迎页
            UPWWebViewController *webVC = [[UPWWebViewController alloc] init];
            webVC.startPage = @"http://www.baidu.com";
            webVC.title = @"欢迎页";
            [self.navigationController pushViewController:webVC animated:YES];
        } else if (2 == indexPath.row) {
#warning 跳转到功能介绍页面
            UPWWebViewController *webVC = [[UPWWebViewController alloc] init];
            webVC.startPage = @"http://www.baidu.com";
            webVC.title = @"功能介绍";
            [self.navigationController pushViewController:webVC animated:YES];
        }
    } else if (1 == indexPath.section) {
        [self logoutAction:nil];
    }
}

#pragma mark -
#pragma mark - 退出登录
- (void)logoutAction:(id)sender
{
    UPWActionSheet *actionSheet = [[UPWActionSheet alloc]
                                 initWithTitle:@"确认退出"
                                 delegate:self
                                 cancelButtonTitle:UP_STR(@"kBtnCancel")
                                 destructiveButtonTitle:@"安全退出"
                                 otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:_contentView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self showWaitingView:@"正在退出登录"];
        
        NSDictionary *params = @{@"userId":@""};
        UPWMessage* message = [UPWMessage messageLogoutWithParams:params];
        __weak typeof(self) wself = self;
        [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
            
            NSDictionary* params =  responseJSON;
            [wself receivedWithParams:params];
        } fail:^(NSError * error) {
            [wself failedWithError:error];
            
#warning 测试数据
            [self receivedWithParams:params];
        }];
        [self addMessage:message];
    }
}

- (void)receivedWithParams:(NSDictionary *)params
{
    [self hideWaitingView];
    
    //清除本地用户信息，登录状态设为NO
    [[NSFileManager defaultManager] removeItemAtPath:[UPWPathUtil accountInfoPlistPath] error:nil];
    [UPWGlobalData sharedData].hasLogin = NO;
    [UPWGlobalData sharedData].accountInfo = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationlogoutSucceed object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshShoppingCart object:nil];
}

- (void)failedWithError:(NSError *)error
{
    [self hideWaitingView];
    
    [self showFlashInfo:error.localizedDescription];
}

@end
