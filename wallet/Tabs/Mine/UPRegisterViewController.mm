//
//  UPRegisterViewController.m
//  UPWallet
//
//  Created by wxzhao on 14-7-11.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPRegisterViewController.h"
#import "UPXCommonTextField.h"
#import "UPWCardSMSButton.h"
#import "UPWNotificationName.h"

@interface UPRegisterViewController ()
{
    UPXCommonTextField *_phoneTextField;
    UPXCommonTextField *_secretTextField;
    UPXCommonTextField *_smsTextField;
    UPWCardSMSButton * _smsButton;
}

@end

@implementation UPRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNaviTitle:@"注册"];
    
    [self setRightSaveButtonWithTitle:@"提交" target:self action:@selector(submitAction:)];
    [self saveButtonType:YES];
    
    CGFloat x = 0;
    CGFloat width = CGRectGetWidth(_contentView.frame);
    CGFloat height = 44;
    
    _phoneTextField = [[UPXCommonTextField alloc] initWithFrame:CGRectMake(x, 10, width, height)];
    _phoneTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _phoneTextField.placeholder = @"请输入您的手机号";
    _phoneTextField.delegate = self;
    _phoneTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    [_scrollView addSubview:_phoneTextField];
    
    _secretTextField = [[UPXCommonTextField alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(_phoneTextField.frame)+10, width, height)];
    _secretTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _secretTextField.placeholder = @"请设置您的登录密码";
    _secretTextField.secureTextEntry = YES;
    _secretTextField.delegate = self;
    _secretTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    [_scrollView addSubview:_secretTextField];
    
    _smsTextField = [[UPXCommonTextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_secretTextField.frame)+10, width - 110, height)];
    _smsTextField.clearButtonMode = UITextFieldViewModeNever;
    _smsTextField.placeholder = @"手机验证码";
    _smsTextField.delegate = self;
    _smsTextField.keyboardType = UIKeyboardTypeNumberPad;
    _smsTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _smsTextField.maxlength = 6;
    [_scrollView addSubview:_smsTextField];
    
    _smsButton = [UPWCardSMSButton smsButton];
    _smsButton.frame = CGRectMake(width - 110, CGRectGetMinY(_smsTextField.frame), 110, height);
    _smsButton.layer.borderWidth = 0.5;
    _smsButton.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
    [_smsButton setBackgroundColor:[UIColor whiteColor]];
    [_smsButton addTarget: self action: @selector(smsButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
    [_scrollView addSubview:_smsButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)smsButtonClicked:(id)sender
{
    if (_phoneTextField.text.length > 0) {
        BOOL isMatch = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"1\\d{10}"] evaluateWithObject:_phoneTextField.text];
        if (!isMatch) {
            [self showFlashInfo:@"请输入正确的手机号"];
            return;
        }
    } else {
        [self showFlashInfo:@"请补全您的手机号"];
        return;
    }
    
    [self showWaitingView:UP_STR(@"kStrWaiting")];
    
    [_smsButton startCounting];
    
    __weak typeof(self) wself = self;
    NSDictionary *params = @{@"phoneNum":_phoneTextField.text};
    UPWMessage* message = [UPWMessage messageSmsWithParams:params];
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *response) {
        [wself hideWaitingView];
        
    } fail:^(NSError *error) {
        [_smsButton stopCounting];
        [wself hideWaitingView];
        [wself showFlashInfo:[self stringWithError:error]];
        
        
    }];
}

- (void)submitAction:(id)sender
{
    if (_phoneTextField.text.length <= 0) {
        [self showFlashInfo:@"请补全您的手机号"];
        return;
    }
    if (_secretTextField.text.length < 6) {
        [self showFlashInfo:@"请填写至少6位密码"];
        return;
    }
    if (_smsTextField.text.length <= 0) {
        [self showFlashInfo:@"请填写手机验证码"];
        return;
    }
    
    [self registerAction];
}

#pragma mark -
#pragma mark - 上送新地址
- (void)registerAction
{
    [self showWaitingView:UP_STR(@"kStrWaiting")];
    
    NSDictionary *params = @{@"phoneNum":_phoneTextField.text, @"password": _secretTextField.text, @"smsCode": _smsTextField.text};
    UPWMessage* message = [UPWMessage messageRegisterWithParams:params];
    __weak typeof(self) wself = self;
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        NSDictionary* params =  responseJSON;
        [wself receivedMessageWithParams:params];
    } fail:^(NSError * error) {
        [wself receivedMessageWithError:error];
    }];
    [self addMessage:message];
}

- (void)receivedMessageWithParams:(NSDictionary *)params
{
    [self hideWaitingView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRegisterSucceed object:nil userInfo:@{@"phoneNum":_phoneTextField.text, @"password": _secretTextField.text}];
}

- (void)receivedMessageWithError:(NSError *)error
{
    [self hideWaitingView];
    [self showFlashInfo:[self stringWithError:error]];
}

@end
