//
//  UPXAlertView.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-5-28.
//
//


#import <UIKit/UIKit.h>

@class UPXAlertView;

typedef void(^UPXAlertViewBlock)(UPXAlertView *alertView, NSInteger buttonIndex);


@interface UPXAlertView : UIView
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, copy) UPXAlertViewBlock block;
@property (nonatomic, assign) UIWindowLevel alertWindowLevel;

- (id)initWithWindow:(UIWindow *)hostWindow;

/** @name Configuration */

- (void)resetLayout;
- (void)removeAllControls;
- (void)removeAllButtons;
- (void)addOtherButtons:(NSArray*)buttonTitles specialIndex:(NSInteger)index;
- (void)addButtonCancel:(NSString *)title;

/** @name Showing, Updating and Hiding */

- (void)showOrUpdateAnimated:(BOOL)flag;
- (void)hideAnimated:(BOOL)flag;
- (void)hideAnimated:(BOOL)flag afterDelay:(NSTimeInterval)delay;

/** @name Methods to Override */

- (void)drawRect:(CGRect)rect;
- (void)drawBackgroundInRect:(CGRect)rect;
- (void)drawTitleInRect:(CGRect)rect isSubtitle:(BOOL)isSubtitle;
- (void)drawDimmedBackgroundInRect:(CGRect)rect;


//点击取消按钮
+ (NSInteger)cancelButtonIndex;

//对话框点击不会消失
+ (NSInteger)neverDismissTag;


@end
