//
//  UPSearchBar.m
//  CHSP
//
//  Created by TZ_JSKFZX_CAOQ on 13-11-18.
//
//

#import "UPWSearchBar.h"

#define kUPSearchBarCancelButtonWidth 50
#define kUPSearchBarCancelButtonHeight 25

#define kUPSearchBarMargin 7
#define kUPSearchBarTextFieldPlaceHolderFontHeight 12

@interface UPWSearchBarTextField : UITextField
@end

@implementation UPWSearchBarTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.borderStyle = UITextBorderStyleNone;
        self.font = [UIFont systemFontOfSize:kUPSearchBarTextFieldPlaceHolderFontHeight];
        self.textColor = UP_COL_RGB(0x333333);
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.adjustsFontSizeToFitWidth = NO;
    }
    return self;
}


@end

@interface UPWSearchBar()<UITextFieldDelegate>
{
    UIImageView* _backGroundImageView;
    UIImageView* _searchBarIcon;
    UIImageView* _searchFieldBackgroundImageView;
    UPWSearchBarTextField* _searchField;
    CGRect  _searchFieldBackgroundRect;
    BOOL    _showCancelButton;
    BOOL    _cancelButtonAnimation;
    BOOL    _searchFieldAnimation;
    UIButton*   _cancelButton;
    CGSize _searchFieldSize;
}

@end

@implementation UPWSearchBar

@dynamic backgroundImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        _backGroundImageView = [[UIImageView alloc] initWithFrame:bounds];
        [self addSubview:_backGroundImageView];

        _searchFieldBackgroundImageView = [[UIImageView alloc] initWithFrame:bounds];
        [self addSubview:_searchFieldBackgroundImageView];
        
        _searchField = [[UPWSearchBarTextField alloc] initWithFrame:bounds];
        _searchFieldSize = _searchField.frame.size;
        _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _searchField.returnKeyType = UIReturnKeySearch;
        _searchField.delegate = self;
        if ([_searchField respondsToSelector:@selector(setTintColor:)]) {
            _searchField.tintColor = [UIColor blueColor];
        }
        [self addSubview:_searchField];
        
        _searchBarIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_searchBarIcon];
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectZero;
        _cancelButton.hidden = YES;
        [_cancelButton setTitle:UP_STR(@"String_Cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancelButton addTarget:self action:@selector(onCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidChangeNotification:)
                                                     name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat posX = 0;
    CGFloat posY = (CGRectGetHeight(self.frame)-_searchFieldSize.height)/2;
    _searchFieldBackgroundRect = CGRectMake(posX, posY,
                                  _searchFieldSize.width,_searchFieldSize.height);
    
    CGRect buttonRt = CGRectZero;
    if (_showCancelButton) {
        _searchFieldBackgroundRect = CGRectMake(posX, posY, _searchFieldSize.width-kUPSearchBarCancelButtonWidth, _searchFieldSize.height);
        CGFloat x = CGRectGetMaxX(_searchFieldBackgroundRect) + 4;
        CGFloat y = (CGRectGetHeight(self.bounds) - kUPSearchBarCancelButtonHeight)/2;
        buttonRt = CGRectMake(x, y, kUPSearchBarCancelButtonWidth, kUPSearchBarCancelButtonHeight);
        _cancelButton.hidden = NO;
    }
    
    CGRect searchIconRt = CGRectZero;
    CGSize iconSz = _searchBarIcon.image.size;
    
    posX += kUPSearchBarMargin;
    posY = (CGRectGetHeight(self.frame)-iconSz.height)/2;
    searchIconRt = CGRectMake(posX, posY, iconSz.width,iconSz.height);
    
    
    posX += kUPSearchBarMargin+iconSz.width;
    posY = (CGRectGetHeight(self.frame)-_searchFieldSize.height)/2;
    CGFloat textFieldWidth = _searchFieldSize.width - kUPSearchBarMargin*2  - iconSz.width;
    CGRect textFieldRt = CGRectMake(posX, posY,
                                    textFieldWidth,_searchFieldSize.height);
    
    CGFloat moveOffset =  _searchFieldBackgroundRect.size.width;

    if (_searchFieldAnimation) {
        _searchFieldBackgroundImageView.frame = CGRectOffset(_searchFieldBackgroundRect,moveOffset, 0);
        _searchBarIcon.frame = CGRectOffset(searchIconRt, moveOffset, 0);
        _searchField.frame =  CGRectOffset(textFieldRt,moveOffset, 0);
        
        [UIView animateWithDuration:.25f animations:^{
            _searchFieldBackgroundImageView.frame = _searchFieldBackgroundRect;
            _searchBarIcon.frame = searchIconRt;
            _searchField.frame = textFieldRt;
            
        }];
    }
    else{
        _searchFieldBackgroundImageView.frame = _searchFieldBackgroundRect;
        _searchBarIcon.frame = searchIconRt;
        _searchField.frame = textFieldRt;
    }
    
    if (_cancelButtonAnimation) {
        _cancelButton.frame = CGRectOffset(buttonRt,moveOffset, 0);
        [UIView animateWithDuration:.3f animations:^{
            _cancelButton.frame = buttonRt;
        }];
    }
    else{
        _cancelButton.frame = buttonRt;
    }
}

- (void)setPlaceholder:(NSString *)placeholder
{
    if (![_placeholder isEqualToString:placeholder]) {
        _placeholder = [placeholder copy];
        _searchField.placeholder = placeholder;
    }
}

- (void)setSearchString:(NSString *)searchString
{
    _searchField.text = searchString;
}

- (NSString *)searchString
{
    return _searchField.text;
}

- (void)setSearchFieldSize:(CGSize)searchFieldSize animated:(BOOL)animated
{
    _searchFieldSize = searchFieldSize;
    _searchFieldAnimation = animated;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backGroundImageView.image = backgroundImage;
}

- (void)setImageforSearchBarIcon:(UIImage *)iconImage
{
    _searchBarIcon.image = iconImage;
}

- (void)setSearchFieldBackgroundImage:(UIImage *)backgroundImage
{
    _searchFieldBackgroundImageView.image = backgroundImage;
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated
{
    _showCancelButton = showsCancelButton;
    _cancelButtonAnimation = animated;
    _cancelButton.hidden = !showsCancelButton;
    [self setNeedsLayout];
}

- (BOOL)becomeFirstResponder
{
    BOOL result = [super becomeFirstResponder];
    [_searchField becomeFirstResponder];
    return result;
}



- (BOOL)resignFirstResponder
{
//    CGRect buttonRt = _cancelButton.frame;
//    CGRect searchFieldBackgroundRect = _searchFieldBackgroundRect;
//    CGRect searchIconRt = _searchBarIcon.frame;
//    CGRect textFieldRt = _searchField.frame;
//    CGRect bgRt = _backGroundImageView.frame;
//    
//    [UIView animateWithDuration:.2f animations:^{
//        _backGroundImageView.frame = CGRectOffset(bgRt, 320, 0);
//        _cancelButton.frame = CGRectOffset(buttonRt, 320, 0);
//        _searchFieldBackgroundImageView.frame = CGRectOffset(searchFieldBackgroundRect, 320, 0);
//        _searchBarIcon.frame = CGRectOffset(searchIconRt, 320, 0);
//        _searchField.frame = CGRectOffset(textFieldRt, 320, 0);
//        
//    }];
    
    
    BOOL result = [super resignFirstResponder];
    [_searchField resignFirstResponder];
    return result;
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        return [self.delegate searchBarShouldBeginEditing:self];
    }
    else{
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [self.delegate searchBarTextDidBeginEditing:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        return [self.delegate searchBarShouldEndEditing:self];
    }
    else{
        return YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)]) {
        [self.delegate searchBarTextDidEndEditing:self];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([self.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate searchBar:self shouldChangeTextInRange:range replacementText:string];
    }
    else{
        return YES;
    }
}


- (void)textFieldDidChangeNotification:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        UITextField *textField = [notification object];
        [self.delegate searchBar:self textDidChange:textField.text];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarShouldClear:)]) {
        [self.delegate searchBarShouldClear:self];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [self.delegate searchBarSearchButtonClicked:self];
    }
    return YES;
}


#pragma mark - onCancelButton

- (void)onCancelButton:(id)sendor
{
    if ([self.delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [self.delegate searchBarCancelButtonClicked:self];
    }
}

@end
