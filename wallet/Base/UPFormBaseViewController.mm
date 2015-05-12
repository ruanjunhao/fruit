//
//  UPFormBaseViewController.m
//  UPWallet
//
//  Created by wxzhao on 14-7-9.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPFormBaseViewController.h"
#import "UPWConst.h"
#import "UPXViewUtils.h"
#import "UPXConstLayout.h"
#import "UPXUtils.h"
#import "UPXConstReg.h"
#import "UPXCommonTextField.h"

@interface UPFormBaseViewController ()

@end

@implementation UPFormBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //默认键盘未打开
        _keyboardHeight = 0;
        _subViewHeight = 44;
        _margin = 15;
        _duration = 0.35f;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    // 监控键盘打开、关闭
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
    
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    _scrollView.contentInset  = UIEdgeInsetsMake(_topOffset, 0, 0, 0);
    
    //[UI设置相关断点]背景颜色
    _scrollView.backgroundColor = UP_COL_RGB(0xefeff4);
    _scrollView.bounces = YES;
    _scrollView.alwaysBounceVertical = YES;
    [_contentView addSubview:_scrollView];
 
    //点击其他区域关闭键盘
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyboard:)];
    tapGR.cancelsTouchesInView = NO;
    tapGR.delegate = self;
    [_scrollView addGestureRecognizer:tapGR];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - UITapGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //子类可继承
    if (touch.view != _scrollView) {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark 点击空白区域关闭键盘
- (void)tapHideKeyboard:(UIGestureRecognizer*)gestureRecognizer
{
    NSArray* subViewArray = [_scrollView subviews];
    for (UIView* view in subViewArray){
        [view resignFirstResponder];
    }
    
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:_duration];
    _scrollView.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
    [UIView commitAnimations];
    
    _keyboardHeight = 0;
    [self.view endEditing:YES];
}

#pragma mark -
- (void)keyboardWillShow:(NSNotification*)notification
{
    //由于键盘显示出来及其键盘在输入法之间的切换都会调用keyboardWillShow，所以这里最好放置于调用次数无关代码
    NSValue *value = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [value CGRectValue];
    
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:_duration];
    _scrollView.frame = CGRectMake(0, 0, _screenWidth, _screenHeight - frame.size.height);
    [UIView commitAnimations];
    _keyboardHeight = frame.size.height;
    
    UIView* firstResponder =  [UPXViewUtils findFirstResponder:self.view];
    if (firstResponder) {
        CGRect rect = [firstResponder convertRect:firstResponder.bounds toView:_scrollView];
        [self subViewDidFocused:rect];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self tapHideKeyboard:nil];
}

#pragma mark -

- (void)subViewDidFocused:(CGRect)convertRect {
    
    _scrollView.frame = CGRectMake(0, 0, _screenWidth, _screenHeight - _keyboardHeight );
    convertRect.size.height = convertRect.size.height +_subViewHeight + 2*_margin;
    convertRect.origin.y = convertRect.origin.y - _margin  ;
    [_scrollView scrollRectToVisible:(convertRect) animated:YES];
}


- (void)moveScrollViewOffset:(CGFloat)offset{
    
    CGFloat currentY = _scrollView.contentOffset.y;
    currentY += offset;
    [_scrollView setContentOffset:CGPointMake(0, currentY) animated:YES];
}


- (void)textFieldDidChange {
    
    [self textFieldDidChangeNotification:nil];
}

- (void)textFieldDidChangeNotification:(NSNotification *)notification {
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    // 手机号码输入后显示格式化在好几个页面都会用到，故放到基类中去处理。
    NSString *source  = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == _mobilePhoneInputTextField) {
        // 手机号 分割 3，4，4
        NSString *normal = [UPXUtils getNormalString:source];
        // 判断 手机号 不能输入超过11位
        if (UP_REGEXP(normal, kMobleNumInputPredicate)) {
            textField.text = [UPXUtils getFormatMobileNumber:normal];
            // 移动光标的位置
            [UPXUtils moveCaretOfTextfield:textField range:range replacementString:string source:source  seperator:kSeperatorMobileNumber];
            // 后面 return NO，收不到 UITextFieldTextDidChangeNotification 的通知，所以这里 自己发一个
            [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:textField userInfo:nil];
            
            SEL handler;
            if(UP_REGEXP(normal, kRegisterPhoneNumberPredicate)) {
                // 手机号码输入完成，是否触发某些事件？让子类去实现吧...
                handler = @selector(mobilePhoneNumInputAsComplete:);
            }
            else {
                handler = @selector(mobilePhoneNumInputAsNotComplete:);
            }
            
            [self performSelector:handler withObject:_mobilePhoneInputTextField afterDelay:0.1f];
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if(textField == _mobilePhoneInputTextField) {
        [self performSelector:@selector(mobilePhoneNumInputAsNotComplete:) withObject:_mobilePhoneInputTextField afterDelay:0.1f];
    }
    
    return YES;
}

// 手机号码输入完毕
- (void)mobilePhoneNumInputAsComplete:(UITextField *)textField
{
    // 等待子类去继承实现。
}

// 手机号码仅部分输入
- (void)mobilePhoneNumInputAsNotComplete:(UITextField *)textField
{
    // 等待子类去继承实现。
}

#pragma mark
#pragma mark 键盘动作相关

//避免焦点遮挡键盘
- (void)moveEditableTextInputToVisible:(UIControl*) responder
{
    UPDSTART();
    if (responder) {
        CGRect rect = [responder convertRect:responder.bounds toView:_scrollView];
        
        if(_keyboardHeight >0) {
            [self subViewDidFocused:rect];
        }
    }
    UPDEND();
}


- (void)hideKeyboard
{
//    [self.view endEditing:YES];
    [self tapHideKeyboard:nil];
}



@end

