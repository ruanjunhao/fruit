//
//  UPFormBaseViewController.h
//  UPWallet
//
//  Created by wxzhao on 14-7-9.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWBaseViewController.h"
#import "UPWDataPresentBaseViewController.h"
@class UPXCommonTextField;

@interface UPFormBaseViewController : UPWDataPresentBaseViewController<UITextFieldDelegate,UITextViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    UIScrollView* _scrollView;
    CGFloat _keyboardHeight;
    CGFloat _subViewHeight;
    CGFloat _margin;
    CGFloat _duration;
    
    UPXCommonTextField* _mobilePhoneInputTextField;
}

- (void)tapHideKeyboard:(UIGestureRecognizer*)gestureRecognizer;

- (void)moveScrollViewOffset:(CGFloat)offset;

- (void)textFieldDidChange;

- (void)hideKeyboard;

- (void)moveEditableTextInputToVisible:(UIControl*) responder;

@end
