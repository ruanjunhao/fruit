//
//  UPCommonButton.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-5-26.
//
//

#import "UPXCommonButton.h"
#import "UPWMarco.h"
#import "UPXFontUtils.h"
#import "UPXExKit.h"


#define kBack @"String_Back"

@implementation UPXCommonButton

+ (instancetype)blueButtonWithTitle:(NSString*)title
{
    UPXCommonButton* bt = [self buttonWithType:UIButtonTypeCustom];
    [bt setTitle:title forState:UIControlStateNormal];
    [bt setTitleColor:UP_COL_RGB(0xffffff) forState:UIControlStateNormal];
    [bt setTitleColor:UP_COL_RGB(0xffffff) forState:UIControlStateHighlighted];
    [bt setTitleColor:UP_COL_RGB(0x666666) forState:UIControlStateDisabled];
    bt.titleLabel.font  = [UPXFontUtils commonButtonTitleFont];
    UIImage* bg = [UP_GETIMG(@"bt_blue") stretchableImageWithLeftCapWidth:4 topCapHeight:22];
    UIImage* hlBg = [UP_GETIMG(@"bt_blue_tap") stretchableImageWithLeftCapWidth:5 topCapHeight:22];
    UIImage* disableBg = [UP_GETIMG(@"bt_disable") stretchableImageWithLeftCapWidth:4 topCapHeight:22];
    
    [bt setBackgroundImage:bg forState:UIControlStateNormal];
    [bt setBackgroundImage:hlBg forState:UIControlStateHighlighted];
    [bt setBackgroundImage:disableBg forState:UIControlStateDisabled];
    
    bt.exclusiveTouch = YES;
    return bt;
}

+ (instancetype)grayButtonWithTitle:(NSString*)title
{
    UPXCommonButton* bt = [self buttonWithType:UIButtonTypeCustom];
    
    [bt setTitle:title forState:UIControlStateNormal];
    [bt setTitleColor:UP_COL_RGB(0x3c3c3c) forState:UIControlStateNormal];
    [bt setTitleColor:UP_COL_RGB(0x3b3b3b) forState:UIControlStateHighlighted];
    [bt setTitleColor:UP_COL_RGB(0x666666) forState:UIControlStateDisabled];
    bt.titleLabel.font  = [UPXFontUtils commonButtonTitleFont];
    UIImage* bg = [UP_GETIMG(@"bt_gray") stretchableImageWithLeftCapWidth:4 topCapHeight:22];
    UIImage* hlBg = [UP_GETIMG(@"bt_gray_tap") stretchableImageWithLeftCapWidth:5 topCapHeight:22];
    UIImage* disableBg = [UP_GETIMG(@"bt_disable") stretchableImageWithLeftCapWidth:4 topCapHeight:22];
    
    [bt setBackgroundImage:bg forState:UIControlStateNormal];
    [bt setBackgroundImage:hlBg forState:UIControlStateHighlighted];
    [bt setBackgroundImage:disableBg forState:UIControlStateDisabled];
    
    bt.exclusiveTouch = YES;
    return bt;
}


+ (instancetype)yellowButtonWithTitle:(NSString*)title
{
    UPXCommonButton* bt = [self buttonWithType:UIButtonTypeCustom];
    
    [bt setTitle:title forState:UIControlStateNormal];
    [bt setTitleColor:UP_COL_RGB(0xffffff) forState:UIControlStateNormal];
    [bt setTitleColor:UP_COL_RGB(0xf4d9aa) forState:UIControlStateHighlighted];
    [bt setTitleColor:UP_COL_RGB(0xffe5a7) forState:UIControlStateDisabled];
    bt.titleLabel.font  = [UPXFontUtils commonButtonTitleFont];
    UIImage* bg = [UP_GETIMG(@"yellow_btn") resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage* hlBg = [UP_GETIMG(@"yellow_btn_tap") resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage* disableBg = [UP_GETIMG(@"yellow_btn_disable") resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

    [bt setBackgroundImage:bg forState:UIControlStateNormal];
    [bt setBackgroundImage:hlBg forState:UIControlStateHighlighted];
    [bt setBackgroundImage:disableBg forState:UIControlStateDisabled];
    
    bt.exclusiveTouch = YES;
    return bt;
}

+ (instancetype)navigationButtonWithTitle:(NSString*)title
{
    UPXCommonButton* button = [self buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UP_COL_RGB(0xffffff) forState:UIControlStateNormal];
    [button setTitleColor:UP_COL_RGB(0xffffff) forState:UIControlStateHighlighted];
    [button setTitleColor:UP_COL_RGB(0x777e81) forState:UIControlStateDisabled];

    UIImage* bg = [UP_GETIMG(@"ic_titleBar_button_bg") stretchableImageWithLeftCapWidth:31 topCapHeight:22];
    UIImage* hlBg = [UP_GETIMG(@"ic_titleBar_button_bg_tap") stretchableImageWithLeftCapWidth:31 topCapHeight:22];
    UIImage* disableBg = [UP_GETIMG(@"ic_titleBar_button_bg_disable") stretchableImageWithLeftCapWidth:31 topCapHeight:22];
    
    [button setBackgroundImage:bg forState:UIControlStateNormal];
    [button setBackgroundImage:hlBg forState:UIControlStateHighlighted];
    [button setBackgroundImage:disableBg forState:UIControlStateDisabled];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font  = [UPXFontUtils navigationButtonFont];
    button.titleLabel.shadowColor = UP_COL_RGB(0x171c1e);
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
    button.titleEdgeInsets = UIEdgeInsetsMake(1, 0, 0, 0);

    button.size = bg.size;

    
    button.exclusiveTouch = YES;
    return button;
}
+ (instancetype)deleteButtonWithTitle:(NSString*)title
{
    UPXCommonButton* bt = [self buttonWithType:UIButtonTypeCustom];
    [bt setTitle:title forState:UIControlStateNormal];
    [bt setTitleColor:UP_COL_RGB(0xc5c5cb) forState:UIControlStateNormal];
    [bt setTitleColor:UP_COL_RGB(0x333333) forState:UIControlStateSelected];
    [bt setTitleColor:UP_COL_RGB(0x666666) forState:UIControlStateHighlighted];
    bt.titleLabel.font  = [UPXFontUtils commonButtonTitleFont];
    UIImage* bg = [UP_GETIMG(@"delBtn_bukedianji") resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage* selectedBg = [UP_GETIMG(@"delBtn_kedianji") resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage* disableBg = [UP_GETIMG(@"delBtn_dianji") resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    [bt setBackgroundImage:bg forState:UIControlStateNormal];
    [bt setBackgroundImage:selectedBg forState:UIControlStateSelected];
    [bt setBackgroundImage:disableBg forState:UIControlStateHighlighted];
    
    bt.exclusiveTouch = YES;
    return bt;

}

@end


@interface UPXBackButton()
@property(nonatomic) UIEdgeInsets normalEdgeInsets;
@property(nonatomic) UIEdgeInsets highlightedEdgeInsets;
@end

@implementation UPXBackButton

+ (instancetype)backButton
{
    UPXBackButton* button = [UPXBackButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        [button setTitle:UP_STR(kBack) forState:UIControlStateNormal];
        [button setTitleColor:UP_COL_RGB(0xffffff) forState:UIControlStateNormal];
        [button setTitleColor:UP_COL_RGB(0xffffff) forState:UIControlStateHighlighted];
        [button setTitleColor:UP_COL_RGB(0x777e81) forState:UIControlStateDisabled];
        UIImage* bg = UP_GETIMG(@"ic_titleBar_return_bg");
        UIImage* hlBg = UP_GETIMG(@"ic_titleBar_return_bg_tap");
        UIImage* disableBg = UP_GETIMG(@"ic_titleBar_return_bg_tap");
        
        [button setBackgroundImage:bg forState:UIControlStateNormal];
        [button setBackgroundImage:hlBg forState:UIControlStateHighlighted];
        [button setBackgroundImage:disableBg forState:UIControlStateDisabled];
        button.size = bg.size;
        
        button.titleLabel.font  = [UPXFontUtils navigationButtonFont];
        button.titleLabel.shadowColor = UP_COL_RGB(0x171c1e);
        button.titleLabel.shadowOffset = CGSizeMake(0, -1);
        
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
        button.normalEdgeInsets = button.titleEdgeInsets;
        button.highlightedEdgeInsets =  button.titleEdgeInsets;
        
        
        button.exclusiveTouch = YES;
    }
    return button;
}

- (void) setHighlighted:(BOOL)highlighted {
    self.titleEdgeInsets = highlighted ? self.highlightedEdgeInsets : self.normalEdgeInsets;
    [super setHighlighted:highlighted];
}

@end
