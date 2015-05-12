//
//  UPWNavRightTitleViewController.h
//  wallet
//
//  Created by leichen on 14-12-10.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWBaseViewController.h"

@interface UPWNavRightTitleViewController : UPWBaseViewController
{
    UIButton *_rightNavBtn;

}
- (void)setRightSaveButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;
-(void)saveButtonType:(BOOL)type;


@end
