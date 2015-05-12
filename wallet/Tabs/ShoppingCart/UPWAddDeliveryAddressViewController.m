//
//  UPWAddDeliveryAddressViewController.m
//  wallet
//
//  Created by gcwang on 15/3/16.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWAddDeliveryAddressViewController.h"
#import "UPXCommonTextField.h"
#import "UPXTextboxButton.h"
#import "UPXPickerView.h"
#import "UPWDeliveryAddressModel.h"
#import "UPWNotificationName.h"
#import "UPWFileUtil.h"
#import "UPWPathUtil.h"

@interface UPWAddDeliveryAddressViewController () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    UPXCommonTextField *_nameTextField;
    UPXCommonTextField *_phoneTextField;
    UPXTextboxButton *_addrPickerButton;
    UPXCommonTextField *_addrTextField;
    
    UPXPickerView *_addrPickerView;
    
    NSMutableDictionary *_addrInfo;
    UPWDeliveryAddressCellModel *_addrModel;
    
    NSArray *_provinceArray;
    NSArray *_cityArray;
    NSArray *_regionArray;
    
    NSInteger _selectedAddr[3];
}

@end

@implementation UPWAddDeliveryAddressViewController

- (id)initWithDeliveryAddrModel:(UPWDeliveryAddressCellModel *)model
{
    self = [super init];
    if (self) {
        _addrModel = [[UPWDeliveryAddressCellModel alloc] initWithDictionary:model.toDictionary error:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNaviTitle:@"添加收货地址"];
    
    [self setRightSaveButtonWithTitle:@"保存" target:self action:@selector(saveDeliveryAddr:)];
    [self saveButtonType:YES];
    
    CGFloat x = 0;
    CGFloat width = CGRectGetWidth(_contentView.frame);
    CGFloat height = 44;
    
    _nameTextField = [[UPXCommonTextField alloc] initWithFrame:CGRectMake(x, 10, width, height)];
    _nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _nameTextField.placeholder = @"姓名";
    _nameTextField.delegate = self;
    _nameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    [_scrollView addSubview:_nameTextField];
    
    _phoneTextField = [[UPXCommonTextField alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(_nameTextField.frame)+10, width, height)];
    _phoneTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _phoneTextField.placeholder = @"电话";
    _phoneTextField.delegate = self;
    _phoneTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    [_scrollView addSubview:_phoneTextField];
    
    _addrPickerButton = [[UPXTextboxButton alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(_phoneTextField.frame)+10, width, height)];
    [_addrPickerButton addTarget:self action: @selector(addrPickerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_addrPickerButton setTitle:@"选择省/市/区" forState: UIControlStateNormal];
    [_scrollView addSubview:_addrPickerButton];
    
    _addrTextField = [[UPXCommonTextField alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(_addrPickerButton.frame)+10, width, height)];
    _addrTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _addrTextField.placeholder = @"配送地址";
    _addrTextField.delegate = self;
    _addrTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    [_scrollView addSubview:_addrTextField];
    
    if (_addrModel) {
        _nameTextField.text = _addrModel.userName;
        _phoneTextField.text = _addrModel.phoneNum;
        [_addrPickerButton setTitle:[NSString stringWithFormat:@"%@%@%@", _addrModel.addrInfo.province, _addrModel.addrInfo.city, _addrModel.addrInfo.region] forState:UIControlStateNormal];
        _addrTextField.text = _addrModel.addrInfo.detailAddr;
    }
    
    [self initPickerInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initPickerInfo
{
    _provinceArray = @[@"上海"];
    _cityArray = @[@"上海市"];
    _regionArray = @[@"黄浦区", @"卢湾区", @"徐汇区", @"长宁区", @"静安区", @"普陀区", @"闸北区", @"虹口区", @"杨浦区", @"闵行区", @"宝山区", @"嘉定区", @"浦东新区", @"金山区", @"松江区", @"青浦区", @"南汇区", @"奉贤区", @"崇明县"];
    _selectedAddr[0] = 0;
    _selectedAddr[1] = 0;
    _selectedAddr[2] = 0;
}

- (void)addrPickerButtonClicked:(id)sender
{
    if (!_addrPickerView) {
        _addrPickerView = [[UPXPickerView alloc] init];
        _addrPickerView.dataSource = self;
        _addrPickerView.delegate = self;
        [_addrPickerView addDoneAction:@selector(handleAddrPickerButtonEvent:) target:self];
    }
    [_addrPickerView showInView:nil];
    //set default date
    [_addrPickerView selectRow:_selectedAddr[0] inComponent:0 animated:NO];
    [_addrPickerView selectRow:_selectedAddr[1] inComponent:1 animated:NO];
}

- (void)handleAddrPickerButtonEvent:(UPXPickerView *)sender
{
    NSInteger row0 = [sender selectedRowInComponent:0];
    NSInteger row1 = [sender selectedRowInComponent:1];
    NSInteger row2 = [sender selectedRowInComponent:2];
    _selectedAddr[0] = row0;
    _selectedAddr[1] = row1;
    _selectedAddr[2] = row2;
    
    NSString * addrHeader =
    [NSString stringWithFormat:@"%@%@%@", _provinceArray[row0], _cityArray[row1], _regionArray[row2]];
    [_addrPickerButton setTitle:addrHeader forState:UIControlStateNormal];
    //传给服务器的数据
    _addrInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"province":_provinceArray[row0], @"city":_cityArray[row1], @"region":_regionArray[row2]}];
}

#pragma mark - UIPickerView dataSource and delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return _provinceArray.count;
    } else if (1 == component) {
        return _cityArray.count;
    } else if (2 == component) {
        return _regionArray.count;
    } else {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return _provinceArray[row];
    } else if (1 == component) {
        return _cityArray[row];
    } else if (2 == component) {
        return _regionArray[row];
    } else {
        return @"";
    }
}

#pragma mark -
#pragma mark - 保存地址
- (void)saveDeliveryAddr:(id)sender
{
    if (_nameTextField.text.length <= 0) {
        [self showFlashInfo:@"请补全您的姓名"];
        return;
    }
    if (_phoneTextField.text.length <= 0) {
        [self showFlashInfo:@"请补全您的电话"];
        return;
    }
    if (!_addrInfo || _addrTextField.text.length <= 0) {
        [self showFlashInfo:@"请补全您的地址"];
        return;
    }
    
    if ([UPWGlobalData sharedData].hasLogin) {
        [self uploadNewDeliveryAddr];
    } else {
        [self postNotificationForAddingSucceed];
    }
}

#pragma mark -
#pragma mark - 添加地址成功，发送通知
- (void)postNotificationForAddingSucceed
{
    _addrInfo[@"detailAddr"] = _addrTextField.text;
    NSDictionary *dict = @{@"userName":_nameTextField.text, @"phoneNum": _phoneTextField.text, @"addrInfo":_addrInfo};
    UPWDeliveryAddressCellModel *cellModel = [[UPWDeliveryAddressCellModel alloc] initWithDictionary:dict error:nil];
    [UPWFileUtil writeContent:cellModel.toDictionary path:[UPWPathUtil deliveryAddrPlistPath]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAddNewDeliveryAddressSucceed object:nil userInfo:@{@"deliveryAddr":cellModel}];
}

#pragma mark -
#pragma mark - 上送新地址
- (void)uploadNewDeliveryAddr
{
    [self showNetworkLoading];
    
    NSString *userId = ([UPWGlobalData sharedData].accountInfo.userId==nil)?@"":[UPWGlobalData sharedData].accountInfo.userId;
    _addrInfo[@"detailAddr"] = _addrTextField.text;
    NSDictionary *params = @{@"communityId":@"communityId", @"userId":userId, @"userName":_nameTextField.text, @"phoneNum": _phoneTextField.text, @"addrInfo": _addrInfo};
    UPWMessage* message = [UPWMessage messageUploadNewDeliveryAddrWithParams:params];
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

- (void)receivedWithParams:(NSDictionary *)params
{
    [self hideNetworkStatusView];
    
    [self postNotificationForAddingSucceed];
}

- (void)failedWithError:(NSError *)error
{
    [self hideNetworkStatusView];
    
    [self showFlashInfo:[self stringWithError:error]];
}

@end
