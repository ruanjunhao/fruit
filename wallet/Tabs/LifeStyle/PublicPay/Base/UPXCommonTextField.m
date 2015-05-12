//
//  UPCommonTextField.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-5-26.
//
//

#import "UPXCommonTextField.h"
#import "UPXConstRGB.h"
#import "UPXConstLayout.h"
#import "UPXFontUtils.h"

@implementation UPXCommonTextField

@synthesize textName = _textName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.borderStyle = UITextBorderStyleNone;
        
        self.font = [UPXFontUtils commonTextFieldFont];
        
        // 改变 边界颜色
        //        self.layer.cornerRadius = 4.0;
        //        self.layer.borderWidth = 1.0;
        //        self.layer.borderColor = [[UIColor colorWithRed:195.0/255 green:208.0/255 blue:221.0/255 alpha:1.0] CGColor];
        
        self.placeHolderColor = UP_COL_RGB(kColorTextFieldPlaceHolder);
        self.textColor = UP_COL_RGB(kColorPublicPayText);
        self.canBeginEditting = YES;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.adjustsFontSizeToFitWidth = NO;
        self.background = [UP_GETIMG(@"textbox") resizableImageWithCapInsets:UIEdgeInsetsMake(0.5, 0, 0.5, 0)];
    }
    return self;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

// 先执行  becomeFirstResponder,再执行 canBecomeFirstResponder
//- (BOOL)canBecomeFirstResponder {
//    [super canBecomeFirstResponder];
//    return self.canBeginEditting;
//}

//改变绘文字属性.重写时调用super可以按默认图形属性绘制,若自己完全重写绘制函数，就不用调用super了.
- (BOOL)becomeFirstResponder{
    if (self.canBeginEditting) {
        //        self.layer.borderColor = [UP_COL_RGB(0x00AEFF) CGColor];
        BOOL is = [super becomeFirstResponder];
        return is;
    }
    else {
        return NO;
    }
    
}


- (BOOL)resignFirstResponder{
    //    self.layer.borderColor  = [kTextColor_TextFieldBorderColor CGColor];
    return [super resignFirstResponder];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    
    bounds.origin.x = bounds.origin.x + kCommonTextFieldTextRectLeftMargin;
    bounds.size.width = bounds.size.width - kCommonTextFieldTextRectLeftMargin -kCommonTextFieldTextRectRightMargin;
    return [super textRectForBounds:bounds];
    //    return CGRectMake(bounds.origin.x + 10.0f, bounds.origin.y, bounds.size.width, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds.origin.x = bounds.origin.x + kCommonTextFieldEditingRectLeftMargin;
    bounds.size.width = bounds.size.width - kCommonTextFieldEditingRectLeftMargin -kCommonTextFieldEditingRectRightMargin;
    return [super textRectForBounds:bounds];
    //    return CGRectMake(bounds.origin.x + 10.0f, bounds.origin.y, bounds.size.width, bounds.size.height);
}


//控制placeHolder的颜色、字体
- (void)drawPlaceholderInRect:(CGRect)rect
{
    //CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
    [self.placeHolderColor setFill];
    CGRect placeholderRect = CGRectMake(rect.origin.x , (rect.size.height- self.font.lineHeight)/2, rect.size.width, self.font.lineHeight);
    [[self placeholder] drawInRect:placeholderRect withFont:self.font];
}

//控制右视图位置
- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    float insetY = (bounds.size.height - self.rightView.bounds.size.height)/2.0;
    float insetX = bounds.size.width - self.rightView.bounds.size.width - insetY;
    
    CGRect inset = CGRectMake(insetX, insetY, self.rightView.bounds.size.width, self.rightView.bounds.size.height);
    
    return inset;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect rect = CGRectZero;
    if (self.leftText == nil || [self.leftText isEqualToString:@""]) {
        return CGRectZero;
    }
    
    CGSize size = [self.leftText sizeWithFont:self.font];
    
    rect.size = size;
    
    float y = (bounds.size.height - self.font.lineHeight)/2.0;
    rect.origin.y = y;
    
    rect.origin.x = 15.0;
    
    return rect;
}


#pragma mark -
#pragma mark set leftText
-(void)setLeftText:(NSString *)leftText
{
    if (_leftText != leftText) {
        _leftText = [leftText copy];
        // create leftView
        [self createLeftView];
    }
}

- (void)createLeftView
{
    CGRect rect = [self leftViewRectForBounds:self.bounds];
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.backgroundColor = [UIColor clearColor];
    label.font = self.font;
    label.textColor = self.textColor;
    label.text = self.leftText;
    
    self.leftView = label;

    
    self.leftViewMode = UITextFieldViewModeAlways;
}


@end



#pragma mark -
#pragma mark UPXPhoneNumberTextField

@implementation UPXPhoneNumberTextField

- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    CGSize  clearBtnSize    = CGSizeMake(20, 20);
    float   insetY  = (bounds.size.height - clearBtnSize.height)/2.0;
    float   insetX  = bounds.size.width - 20 - 50;
    CGRect  inset   = CGRectMake(insetX,
                                 insetY,
                                 clearBtnSize.width,
                                 clearBtnSize.height);
    return inset;
}

@end

