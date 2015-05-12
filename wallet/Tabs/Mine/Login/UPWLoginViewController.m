//
//  UPWLoginViewController.m
//  wallet
//
//  Created by qcao on 14/10/27.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWLoginViewController.h"
#import "UPRegisterViewController.h"
#import "UPXCommonTextField.h"
#import "UPWAccountInfoModel.h"
#import "UPWNotificationName.h"
#import "UPWFileUtil.h"
#import "UPWPathUtil.h"

@interface UPWLoginViewController ()
{
    UPXCommonTextField *_phoneTextField;
    UPXCommonTextField *_secretTextField;
}
@end

@implementation UPWLoginViewController

//登录页面采集
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationRegisterSucceed object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!UP_iOSgt7) {
        CGRect frame = _contentView.frame;
        frame.size.height += kNavigationBarHeight;
        [_contentView setFrame:frame];
    }
    
    [self setNaviTitle:@"登录"];
    
    [self setLeftButtonWithImageName:nil title:@"取消" target:self action:@selector(cancelButtonAction:)];

    CGFloat x = 0;
    CGFloat width = CGRectGetWidth(_contentView.frame);
    CGFloat height = 44;
    
    _phoneTextField = [[UPXCommonTextField alloc] initWithFrame:CGRectMake(x, 10, width, height)];
    _phoneTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _phoneTextField.placeholder = @"请输入登录手机号";
    _phoneTextField.delegate = self;
    _phoneTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    [_scrollView addSubview:_phoneTextField];
    
    _secretTextField = [[UPXCommonTextField alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(_phoneTextField.frame)+10, width, height)];
    _secretTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _secretTextField.placeholder = @"请输入登录密码";
    _secretTextField.secureTextEntry = YES;
    _secretTextField.delegate = self;
    _secretTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    [_scrollView addSubview:_secretTextField];
    
    x = 16;
    width = (CGRectGetWidth(_contentView.frame) - 32 - 30)/2;
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
    loginButton.layer.borderWidth = 0.5;
    loginButton.frame = CGRectMake(x, CGRectGetMaxY(_secretTextField.frame) + 10, width, height);
    [loginButton setBackgroundColor:[UIColor whiteColor]];
    [loginButton setTitleColor:UP_COL_RGB(0x333333) forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:kConstantFont16];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:loginButton];
    
    x = CGRectGetMaxX(loginButton.frame) + 30;
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registerButton.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
    registerButton.layer.borderWidth = 0.5;
    registerButton.frame = CGRectMake(x, CGRectGetMinY(loginButton.frame), width, height);
    [registerButton setBackgroundColor:[UIColor clearColor]];
    [registerButton setTitleColor:UP_COL_RGB(0x333333) forState:UIControlStateNormal];
    registerButton.titleLabel.font = [UIFont systemFontOfSize:kConstantFont16];
    [registerButton setTitle:@"注册" forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerAction:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:registerButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerSucceed:) name:kNotificationRegisterSucceed object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark -
- (void)cancelButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        //code
    }];
}

#pragma mark -
#pragma mark - 登录
- (void)loginAction:(id)sender
{
    if (_phoneTextField.text.length > 0) {
        BOOL isMatch = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"1\\d{10}"] evaluateWithObject:_phoneTextField.text];
        if (!isMatch) {
            [self showFlashInfo:@"请输入正确的手机号"];
            return;
        }
    } else {
        [self showFlashInfo:@"请补全您的登录手机号"];
        return;
    }
    if (_secretTextField.text.length <= 0) {
        [self showFlashInfo:@"请补全您的登录密码"];
        return;
    }
    
    [self showWaitingView:@"正在登录"];
    
    NSDictionary *params = @{@"phoneNum":_phoneTextField.text, @"password": _secretTextField.text};
    UPWMessage* message = [UPWMessage messageLoginWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {        
        [wself loginSucceedWithParams:responseJSON[@"data"]];
    } fail:^(NSError * error) {
        [wself loginFailedWithError:error];
    }];
    [self addMessage:message];
}

- (void)loginSucceedWithParams:(NSDictionary *)params
{
    [self hideWaitingView];
    
    [UPWGlobalData sharedData].hasLogin = YES;
    
    UPWAccountInfoModel *accountInfoModel = [[UPWAccountInfoModel alloc] initWithDictionary:params error:nil];
    
    [UPWFileUtil writeContent:[accountInfoModel toDictionary] path:[UPWPathUtil accountInfoPlistPath]];

    [UPWGlobalData sharedData].accountInfo = accountInfoModel;
    [UPWGlobalData sharedData].Authorization = accountInfoModel.token;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSucceed object:nil userInfo:@{@"accountInfo":accountInfoModel}];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshShoppingCart object:nil];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //code
    }];
}

- (void)loginFailedWithError:(NSError *)error
{
    [self hideWaitingView];
    
    [self showFlashInfo:error.localizedDescription];
}

#pragma mark -
#pragma mark - 注册
- (void)registerAction:(id)sender
{
    UPRegisterViewController *registerVC = [[UPRegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

#pragma mark - 
#pragma mark - 注册成功通知
- (void)registerSucceed:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    _phoneTextField.text = userInfo[@"phoneNum"];
    _secretTextField.text = userInfo[@"password"];
    [self.navigationController popToViewController:self animated:YES];
}

@end
