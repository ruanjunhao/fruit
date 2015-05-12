//
//  UPPickerView.m
//  UPClientV3
//
//  Created by Yang Shichang on 13-6-1.
//
//

#import "UPXPickerView.h"
#import "UPXConstRGB.h"
#import "UPXConstLayout.h"
#import "UPXConstStrings.h"

@implementation UPXPickerView

- (id)init
{
    
    self = [super init];
    if (self) {
        // Initialization code
        self.backgroundColor = UP_COL_RGB(kColorViewBg);
        self.showsSelectionIndicator = YES;
        _window =[[[UIApplication sharedApplication] windows]  firstObject];
        
        _pickerHeight = 216;
        _hiddenPickerFrame = CGRectMake(0, _window.bounds.size.height+kTabBarHeight, kScreenWidth, _pickerHeight);
        _showPickerFrame = CGRectMake(0, _window.bounds.size.height - _pickerHeight, kScreenWidth, _pickerHeight);
        self.frame = _hiddenPickerFrame;

       [self initToolBar];
        
        self.isDonePressed = NO;
        
        _selectedRows = [[NSMutableArray alloc] init];
        //按home键 dismiss  pickView
        [UP_NC addObserver:self selector:@selector(applicationWillResignActive:) name:@"kNCEnterBackground" object:nil];
        }
    return self;
}

- (void)initToolBar
{
    

    _toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, _hiddenPickerFrame.origin.y - kTabBarHeight, kScreenWidth, kTabBarHeight)];
    _toolbar.backgroundColor = [UIColor clearColor];
    _toolbar.barStyle = UIBarStyleBlack;
    _toolbar.translucent = YES;
    NSMutableArray *buttons = [[NSMutableArray alloc]init];
    
    
    
    
    if (UP_IOS_VERSION >= 7.0) {
        UIBarButtonItem *leftMargin = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        leftMargin.width = kFormItemMarginX;
        [buttons addObject:leftMargin];
    }
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:UP_STR(kCancel)
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(pickerCancel:)];
       [buttons addObject:cancelButton];

    
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:self
                                                                                 action:nil] ;
    [buttons addObject:spaceButton];
    

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:UP_STR(kDone)
                                                   style:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(pickerDone:)];
    
    
    
    [buttons addObject:doneButton];
    
    if (UP_IOS_VERSION >= 7.0) {
        UIBarButtonItem *rightMargin = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        rightMargin.width = kFormItemMarginX;
        [buttons addObject:rightMargin];
    }

    [_toolbar setItems:buttons];

}



- (void)addDoneAction:(SEL)doneAction target:(id)target
{
    _doneAction = doneAction;
    _target = target;
}

#pragma mark pickerDone
- (void)pickerDone:(UIBarButtonItem *)btnItem
{
    self.isDonePressed = YES;
    
    if ([_target respondsToSelector:_doneAction]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_doneAction withObject:self];
#pragma clang diagnostic pop
        
    }
    // 存储 选择的哪些行
    [_selectedRows removeAllObjects];
    for (int i = 0; i < self.numberOfComponents; i++) {
        NSInteger row = [self selectedRowInComponent:i];
        [_selectedRows addObject:[NSNumber numberWithInteger:row]];
    }
    [self dismiss];
}

- (void)pickerCancel:(UIBarButtonItem *)btnItem
{
    self.isDonePressed = NO;
    [self dismiss];
}

- (void)showInView:(UIView *)view
{
    if (_toolbar == nil) {
        [self initToolBar];
    }
    if (_mBackgroundView == nil) {
        _mBackgroundView = [[UIView alloc] initWithFrame:_window.bounds];
        _mBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        _mBackgroundView.hidden = YES;
        
    }
    
    [_window addSubview:_mBackgroundView];
    // 修改 windowLevel，使picker能显示在最前面，不被键盘或其他的东西挡住
    // UIWindowLevelStatusBar-1 是位了不让状态栏消失
    [_mBackgroundView addSubview:_toolbar];
    [_mBackgroundView addSubview:self];
    [_window bringSubviewToFront:_mBackgroundView];
    _currentWindowLevel = _window.windowLevel; // 保存 当前window 的level
    _window.windowLevel = UIWindowLevelStatusBar-1;
    
    [UIView animateWithDuration:0.3 animations:^{
        _mBackgroundView.hidden = NO;
        self.frame = _showPickerFrame;
        _toolbar.frame =CGRectMake(0, _showPickerFrame.origin.y - kTabBarHeight, kScreenWidth, kTabBarHeight);
    } completion:^(BOOL finished) {
        
    }];
    self.isDonePressed = NO;
    
    if (_selectedRows.count > 0) {
        for (int i = 0; i < self.numberOfComponents; i++) {
            NSInteger row = [[_selectedRows objectAtIndex:i] integerValue];
            [self selectRow:row inComponent:i animated:NO];
        }
    }
}

- (void)dismiss
{
    // 消失时，如果有键盘，就把键盘给去掉。
    [_window endEditing:YES];
    _window.windowLevel = _currentWindowLevel;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = _hiddenPickerFrame;
        _toolbar.frame =CGRectMake(0, _hiddenPickerFrame.origin.y - kTabBarHeight, kScreenWidth, kTabBarHeight);
    } completion:^(BOOL finished) {
        _mBackgroundView.hidden = YES;
        [_toolbar removeFromSuperview];
        [self removeFromSuperview];
        [_mBackgroundView removeFromSuperview];
    }];
}
//隐藏pickview
- (void)applicationWillResignActive:(NSNotification *)notification
{
    self.isDonePressed = NO;
    [self dismiss];
}

@end
