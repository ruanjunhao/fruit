//
//  UPWUiUtil.h
//  wallet
//
//  Created by jhyu on 14-10-8.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPXAlertView.h"

@interface UPWUiUtil : NSObject

+ (UPXAlertView*)showAlertViewWithTitle:(NSString*)title
                                message:(NSString*)message
                             customView:(UIView*)view
                      cancelButtonTitle:(NSString*)cancelTitle
                      otherButtonTitles:(NSArray*)otherButtonTitles
                                special:(NSInteger)specialIndex
                                    tag:(NSInteger)tag
                          completeBlock:(UPXAlertViewBlock)block;

/*
 * UILabel.backgroundColor 在iOS7之前默认都是白色，iOS7之后都是透明色。 但我们的UI设计都需要色，用这个函数统一处理。
 *
 */
+ (void)setAllLabelsClearColorByContainerView:(UIView *)containerView;

// 灰色细划线
+ (UIView *)createGreyLineViewWithRect:(CGRect)rcLine;

+ (UIImage *)backgroundImageForSender:(UIView *)sender imageName:(NSString *)imageName;

+ (UILabel *)createMultiLineLabelWithRect:(CGRect)rect text:(NSString *)text font:(UIFont *)font;

// contentView为nil的话，将会加到MainWindow上。
+ (void)showOverlayView:(UIView *)overlayView animatedByContentView:(UIView *)contentView;

+ (void)dismissOverlayViewAnimated:(UIView *)overlayView;


// 白颜色背景图片
+ (UIImage *)whiteBackgroundImage;

+ (UIImage *)iconMaskImage;

// 弹出UIActionSheet，选择是否拨打电话电话
+ (void)showPhoneCallingInHostView:(UIView *)hostView withPhoneNumber:(NSString *)phoneNum;

+ (UITextView *)createTextViewWithText:(NSString *)text lineSeperator:(NSString *)lineSeperator textFont:(UIFont *)font inRect:(CGRect)rect;

+ (UIImageView *)roundCornerImageViewWithIconPath:(NSString *)iconPath placeholder:(UIImage *)placeholder inRect:(CGRect)rect;

@end
