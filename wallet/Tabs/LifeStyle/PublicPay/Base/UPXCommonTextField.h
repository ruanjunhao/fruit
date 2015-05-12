//
//  UPCommonTextField.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-5-26.
//
//

#import <UIKit/UIKit.h>

@interface UPXCommonTextField : UITextField
{
    NSString * _textName;
}

@property (nonatomic,retain) UIColor *placeHolderColor;

// 是否可以开始编辑，默认YES，可以编辑。
@property (nonatomic,assign) BOOL canBeginEditting;

@property (nonatomic, copy) NSString * textName;


@property (nonatomic,copy) NSString *leftText;

@property (nonatomic, assign) NSInteger maxlength;

@end

@interface UPXPhoneNumberTextField : UPXCommonTextField

@end
