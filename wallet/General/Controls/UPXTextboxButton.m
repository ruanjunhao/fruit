//
//  UPPublicPayTextButton.m
//  UPClientV3
//
//  Created by Yang Shichang on 13-5-31.
//
//

#import "UPXTextboxButton.h"
#import "UPXConstRGB.h"
#import "UPWMarco.h"
#import "UPWAppUtil.h"
#import "UPXFontUtils.h"


@implementation UPXTextboxButton



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code bt_selete_downclick
        self.backgroundColor = [UIColor clearColor];
        UIImage *bg = [UP_GETIMG(@"bt_selete_down") stretchableImageWithLeftCapWidth:35 topCapHeight:0];
        UIImage *bgDown = [UP_GETIMG(@"bt_selete_downclick") stretchableImageWithLeftCapWidth:35 topCapHeight:0];
        UIImage* disableBg = [UP_GETIMG(@"bt_formSingle_disable") stretchableImageWithLeftCapWidth:4 topCapHeight:22];
        [self setBackgroundImage:bg forState:UIControlStateNormal];
        [self setBackgroundImage:bgDown forState:UIControlStateHighlighted];
        [self setBackgroundImage:disableBg forState:UIControlStateDisabled];
    
        
        self.titleLabel.font = [UPXFontUtils textboxButtonFont];
        [self setTitleColor:UP_COL_RGB(kColorPublicPayText) forState:UIControlStateNormal];
        self.backgroundColor = UP_COL_RGB(0xffffff);
        
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        //确定single等主要组建文字的布局
        self.titleEdgeInsets = UIEdgeInsetsMake(14.0, 16.0, 12.0, 32.0);
        self.titleLabel.backgroundColor = [UIColor clearColor];
        
        self.exclusiveTouch = YES;
    }
    
    return self;
}


- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    
    [super setTitle:title forState:state];
    if (UP_IOS_VERSION >= 7.0) {
        //在ios7中，setTitle方法传入mutableString时，title不能及时更新，所以这里通过setNeedsLayout及时更新数据
        [self setNeedsLayout];
    }
}

@end
