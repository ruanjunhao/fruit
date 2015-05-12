//
//  UPSmsVerifyButton.m
//  CHSP
//
//  Created by gcwang on 13-12-19.
//
//

#import "UPButton.h"
#import "UPWUiUtil.h"

@interface UPButton ()
{
    UPButtonStyle _style;
    NSInteger _remainingSeconds;
    NSTimer *_timer;
    NSString *_title;
    NSString *_normalPicNm;
    NSString *_hilightedPicNm;
    NSString *_disablePicNm;
}

@end

@implementation UPButton

- (void)dealloc
{
    [self cancelTimer];
}

- (void)cancelTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initializeWithTitle:(NSString *)title normalPictureName:(NSString *)normalPicNm highlitedPicturName:(NSString *)highlitedPicNm disablePictureName:(NSString *)disablePicNm
{
    self.layer.cornerRadius = 5;
    self.exclusiveTouch = YES;
    self.multipleTouchEnabled = NO;
    
    if (title != nil && ![_title isEqualToString:title]) {
        _title = [title copy];
    }
    
    if (normalPicNm != nil && ![_normalPicNm isEqualToString:normalPicNm]) {
        _normalPicNm = [normalPicNm copy];
    }
    
    if (highlitedPicNm != nil && ![_hilightedPicNm isEqualToString:highlitedPicNm]) {
        _hilightedPicNm = [highlitedPicNm copy];
    }
    
    if (disablePicNm != nil && ![_disablePicNm isEqualToString:disablePicNm]) {
        _disablePicNm = [disablePicNm copy];
    }
    
    [self normalStyle];
}

- (void)setButtonStyle:(UPButtonStyle)style
{
    if (style != _style) {
        _style = style;
        
        switch (style) {
            case UPButtonNormalStyle:
                [self normalStyle];
                break;
                
            case UPButtonDisableStyle:
                [self disableStyle];
                break;
                
            case UPButtonCountingStyle:
                [self countingStyle];
                break;
                
            case UPButtonForNewClientDeleteNormalStyle:
                [self ForNewClientDeleteNormalStyle];
                break;
                
            case UPButtonForNewClientDeleteDisableStyle:
                [self ForNewClientDeleteDisableStyle];
                break;
                
            default:
                break;
        }
    }
}

- (void)normalStyle
{
    [self cancelTimer];
    
    self.userInteractionEnabled = YES;
    [self setTitle:_title forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:16.f];
    
    UIImage *bgImage = [UIImage imageNamed:_normalPicNm];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:(bgImage.size.width/2-1) topCapHeight:(bgImage.size.height/2-1)]; // added
    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
    
    bgImage = [UIImage imageNamed:_hilightedPicNm];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:(bgImage.size.width/2-1) topCapHeight:(bgImage.size.height/2-1)];
    [self setBackgroundImage:bgImage forState:UIControlStateHighlighted];
}

- (void)disableStyle
{
    [self cancelTimer];
    
    self.userInteractionEnabled = NO;
    [self setTitle:_title forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:16.f];
    UIImage *bgImage = [UPWUiUtil backgroundImageForSender:self imageName:_disablePicNm];
    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
    bgImage = [UPWUiUtil backgroundImageForSender:self imageName:_disablePicNm];
    [self setBackgroundImage:bgImage forState:UIControlStateHighlighted];
}

- (void)countingStyle
{
    [self cancelTimer];
    
    self.userInteractionEnabled = NO;
    [self setTitle:[NSString stringWithFormat:UP_STR(@"kStrReSMS"), [NSNumber numberWithInteger:60].stringValue] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:14.f];
    UIImage *bgImage = [UPWUiUtil backgroundImageForSender:self imageName:_disablePicNm];
    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
    bgImage = [UPWUiUtil backgroundImageForSender:self imageName:_disablePicNm];
    [self setBackgroundImage:bgImage forState:UIControlStateHighlighted];
    
    _remainingSeconds = 60;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(counting) userInfo:nil repeats:YES];
}

- (void)counting
{
    if (_remainingSeconds == 0) {
        [self setButtonStyle:UPButtonNormalStyle];
        [self cancelTimer];
    } else {
        _remainingSeconds = _remainingSeconds - 1;
        [self setTitle:[NSString stringWithFormat:UP_STR(@"kStrReSMS"), [NSNumber numberWithInteger:_remainingSeconds].stringValue] forState:UIControlStateNormal];
    }
}

- (void)ForNewClientDeleteNormalStyle
{
    [self cancelTimer];
    
    self.userInteractionEnabled = YES;
    self.layer.borderWidth = 1;
    self.layer.borderColor = UP_COL_RGB(0x333333).CGColor;
    
    [self setTitle:_title forState:UIControlStateNormal];
    [self setTitle:_title forState:UIControlStateHighlighted];
    [self setTitleColor:UP_COL_RGB(0x333333) forState:UIControlStateNormal];
    [self setTitleColor:UP_COL_RGB(0x666666) forState:UIControlStateHighlighted];
    [self setTitleColor:UP_COL_RGB(0x666666) forState:UIControlStateSelected];
    self.titleLabel.font = [UIFont systemFontOfSize:18.f];
}

- (void)ForNewClientDeleteDisableStyle
{
    [self cancelTimer];
    
    self.userInteractionEnabled = NO;
    self.layer.borderWidth = 1;
    self.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
    
    [self setTitle:_title forState:UIControlStateNormal];
    [self setTitle:_title forState:UIControlStateHighlighted];
    [self setTitleColor:UP_COL_RGB(0xd4d4d4) forState:UIControlStateNormal];
    [self setTitleColor:UP_COL_RGB(0xd4d4d4) forState:UIControlStateHighlighted];
    self.titleLabel.font = [UIFont systemFontOfSize:18.f];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        switch (_style) {
            case UPButtonForNewClientDeleteNormalStyle:
                self.layer.borderColor = UP_COL_RGB(0x666666).CGColor;
                break;
                
            default:
                break;
        }
    } else {
        switch (_style) {
            case UPButtonForNewClientDeleteNormalStyle:
                self.layer.borderColor = UP_COL_RGB(0x333333).CGColor;
                break;
                
            default:
                break;
        }
    }
}

- (UPButtonStyle)buttonStyle
{
    return _style;
}

@end
