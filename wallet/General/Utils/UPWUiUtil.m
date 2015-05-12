//
//  UPWUiUtil.m
//  wallet
//
//  Created by jhyu on 14-10-8.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWUiUtil.h"
#import "UPWMarco.h"
#import "UPWExUIView.h"
#import "UIImage+Resize.h"
#import "UIImageView+WebCache.h"
#import "UPWBussUtil.h"
#import "UPWActionSheet.h"

#define kAniDuringTime              0.3
#define kDismissAniDuringTime       0.2

@interface UPWUiUtil () <UIActionSheetDelegate>

@end

@implementation UPWUiUtil


+ (UPXAlertView*)showAlertViewWithTitle:(NSString*)title
                                message:(NSString*)message
                             customView:(UIView*)view
                      cancelButtonTitle:(NSString*)cancelTitle
                      otherButtonTitles:(NSArray*)otherButtonTitles
                                special:(NSInteger)specialIndex
                                    tag:(NSInteger)tag
                          completeBlock:(UPXAlertViewBlock)block

{
    UPDINFO(@"showAlertViewWithTitle:%@\nmessage:%@\ncustomView:%@\nbuttons:%@\nspecialIndex:%ld\ntag:%ld",title,message,view,otherButtonTitles,(long)specialIndex,(long)tag);
    
    if (UP_IS_NIL(title) && UP_IS_NIL(message) && !view) {
        UPDERROR(@"showAlertView arg error!");
        return nil;
    }
    
    if (UP_IS_NIL(cancelTitle) && [otherButtonTitles count] < 1) {
        UPDERROR(@"showAlertView error! No buttons!");
        return nil;
    }
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    UPXAlertView* alertView = [[UPXAlertView alloc] initWithWindow:window];
    [alertView resetLayout];
    alertView.title = title;
    alertView.subtitle = message;
    alertView.customView = view;
    alertView.block = block;
    if (!UP_IS_NIL(cancelTitle)) {
        [alertView addButtonCancel:cancelTitle];
    }
    if ([otherButtonTitles count] > 0) {
        [alertView addOtherButtons:otherButtonTitles specialIndex:specialIndex];
    }
    [alertView showOrUpdateAnimated:YES];
    alertView.tag = tag;
    return alertView;
}

/*
 * UILabel.backgroundColor 在iOS7之前默认都是白色，iOS7之后都是透明色。 但我们的UI设计都需要
 * 色，用这个函数统一处理。
 */
+ (void)setAllLabelsClearColorByContainerView:(UIView *)containerView
{
    if(!UP_iOSgt7) {
        for(UIView * aView in containerView.subviews) {
            if([aView isKindOfClass:[UILabel class]]) {
                UILabel * label = (UILabel *)aView;
                if(label.backgroundColor == [UIColor whiteColor]) {
                    label.backgroundColor = [UIColor clearColor];
                }
            }
        }
    }
}

// 灰色细划线
+ (UIView *)createGreyLineViewWithRect:(CGRect)rcLine
{
    rcLine.size.height = 0.5;
    UIView * lineView = [[UIView alloc] initWithFrame:rcLine];
    lineView.backgroundColor = UP_COL_RGB(0xC1C1C1);
    lineView.alpha = 0.5;
    
    return lineView;
}

+ (UIImage *)backgroundImageForSender:(UIView *)sender imageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image resizedImageToFitInSize:CGSizeMake(sender.bounds.size.width, sender.bounds.size.height) scaleIfSmaller:NO];
    UIImage *bgImage =  [image resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    
    return bgImage;
}

#pragma mark - 创建多行文本 UILabel

+ (UILabel *)createMultiLineLabelWithRect:(CGRect)rect text:(NSString *)text font:(UIFont *)font
{
    if(text.length == 0) {
        return nil;
    }
    
    // 先将高度设大
    rect.size.height = [UIScreen mainScreen].bounds.size.height;
    
    CGSize size = [text sizeWithFont:font constrainedToSize:rect.size lineBreakMode:NSLineBreakByWordWrapping];
    rect.size.height = size.height;
    
    UILabel * label = [[UILabel alloc] initWithFrame:rect];
    label.text = text;
    label.numberOfLines = 0;
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    
    return label;
}

#pragma mark - 创建蒙板，把蒙板overlayView加到contentView容器中

+ (void)showOverlayView:(UIView *)overlayView animatedByContentView:(UIView *)contentView
{
    if(overlayView) {
        if(!contentView) {
            contentView = [[UIApplication sharedApplication] keyWindow];
        }
        
        overlayView.alpha = 0.0f;
        [UIView animateWithDuration:kDismissAniDuringTime animations:^{
            overlayView.alpha = 1.0f;
        }];
        [contentView addSubview:overlayView];
    }
}

#pragma mark - 消掉蒙板

+ (void)dismissOverlayViewAnimated:(UIView *)overlayView
{
    if(overlayView) {
        [UIView animateWithDuration:kDismissAniDuringTime animations:^{
            overlayView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [overlayView removeFromSuperview];
        }];
    }
}

#pragma mark - 有边角的白色图片拉伸

+ (UIImage *)whiteBackgroundImage
{
    return [UP_GETIMG(@"white_bg.png") resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3) resizingMode:UIImageResizingModeStretch];
}

#pragma mark - 贴在已有图片上的蒙板图片拉伸

+ (UIImage *)iconMaskImage
{
    return [UP_GETIMG(@"icon_mask.png") resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
}

#pragma mark - 创建包含多行文字格式化UITextView

+ (UITextView *)createTextViewWithText:(NSString *)text lineSeperator:(NSString *)lineSeperator textFont:(UIFont *)font inRect:(CGRect)rect
{
    if(UP_IS_NIL(text)) {
        return nil;
    }
    
    NSInteger lines = [text componentsSeparatedByString:lineSeperator].count + 1;
    text = [text stringByReplacingOccurrencesOfString:lineSeperator withString:@"\n"];
    
    UITextView * textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.backgroundColor = [UIColor clearColor];
    
    textView.text = text;
    textView.font = font;
    textView.textColor = [UIColor blackColor];
    textView.userInteractionEnabled = NO;
    textView.scrollEnabled = NO;
    textView.bounces = NO;
    CGSize textSize = [textView.text sizeWithFont:textView.font];
    
    // 文字高度计算在iOS5, 6上面有误差，需补齐。
    rect.size.height = lines * textSize.height;
    if(!UP_iOSgt7) {
        rect.size.height += 5.0f;
    }
    textView.frame = rect;
    
    return textView;
}

#pragma mark - 创建UPWActionSheet来处理打电话的逻辑。

+ (void)showPhoneCallingInHostView:(UIView *)hostView withPhoneNumber:(NSString *)phoneNum
{
    // eg: iPod就不能打电话
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]])
    {
        if(phoneNum.length > 0) {
            NSString *otherTitle = [NSString stringWithFormat:UP_STR(@"kStrPhoneCalling"), phoneNum];
            UIActionSheet * actionSheet = [[UPWActionSheet alloc] initWithTitle:nil delegate:[self self] cancelButtonTitle:UP_STR(@"String_Cancel") destructiveButtonTitle:nil otherButtonTitles:otherTitle, nil];
            [actionSheet showInView:hostView];
        }
    }
}

#pragma mark - 创建有圆边角的UIImageView

+ (UIImageView *)roundCornerImageViewWithIconPath:(NSString *)iconPath placeholder:(UIImage *)placeholder inRect:(CGRect)rect
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.layer.backgroundColor = [UIColor clearColor].CGColor;
    imageView.layer.cornerRadius = 4.0f;
    imageView.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.1].CGColor;
    imageView.layer.borderWidth = 0.5;
    imageView.clipsToBounds = YES;

    if([UPWBussUtil isWebFullUrl:iconPath]) {
        [imageView setImageWithURL:[NSURL URLWithString:iconPath] placeholderImage:placeholder];
    }
    else {
        imageView.image = [UIImage imageNamed:iconPath];
    }
    
    return imageView;
}

#pragma mark - UIActionSheetDelegate

+ (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        NSString *phoneNum = [[title componentsSeparatedByString:@":"] objectAtIndex:1];
        NSURL *telUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",phoneNum]];
        [[UIApplication sharedApplication] openURL:telUrl];
    }
}

@end
