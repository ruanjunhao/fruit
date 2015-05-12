//
//  UPPickerView.h
//  UPClientV3
//
//  Created by Yang Shichang on 13-6-1.
//
//

#import <UIKit/UIKit.h>

@interface UPXPickerView : UIPickerView
{
    UIView *_mBackgroundView;
    UIWindow *_window;
    UIToolbar *_toolbar;
    
    id _target;
    SEL _doneAction;
    
    UIWindowLevel _currentWindowLevel;
    
    CGRect _hiddenPickerFrame; // 隐藏时 picker的frame
    CGRect _showPickerFrame;  // 显示时 picker的frame
    NSInteger _pickerHeight; // picker的高度
    
    NSMutableArray *_selectedRows;
}

@property (nonatomic,assign) BOOL isDonePressed;

- (void)addDoneAction:(SEL)doneAction target:(id)target;
- (void)showInView:(UIView *)view;
- (void)dismiss;

@end
