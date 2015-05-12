//
//  UPWNavRightTitleViewController.m
//  wallet
//
//  Created by leichen on 14-12-10.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWNavRightTitleViewController.h"

@interface UPWNavRightTitleViewController ()

@end

@implementation UPWNavRightTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - navbar 右上角保存按钮
- (void)setRightSaveButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    _rightNavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightNavBtn setTitle:title forState:UIControlStateNormal];
    _rightNavBtn.frame =CGRectMake(0, 0, 40, 40);
    [_rightNavBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    _rightNavBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_rightNavBtn setTitleColor:UP_COL_RGB(0x666666) forState:UIControlStateNormal];
    [_rightNavBtn setTitleColor:UP_COL_RGB(0xffffff) forState:UIControlStateSelected];
    [_rightNavBtn setUserInteractionEnabled:NO];
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightNavBtn];
    _rightNavBtn.exclusiveTouch = YES;
    
    if (UP_iOSgt7) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,barButtonItem, nil];
    }
    else {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:barButtonItem, nil];
    }
    
}
-(void)saveButtonType:(BOOL)type{
    if (type) {
        [_rightNavBtn setSelected:YES];
        [_rightNavBtn setUserInteractionEnabled:YES];
    }else{
        [_rightNavBtn setSelected:NO];
        [_rightNavBtn setUserInteractionEnabled:NO];
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
