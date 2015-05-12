//
//  UPSmsVerifyButton.h
//  CHSP
//
//  Created by gcwang on 13-12-19.
//
//

typedef enum
{
    UPButtonNormalStyle,
    UPButtonDisableStyle,
    UPButtonCountingStyle,
    UPButtonForNewClientDeleteNormalStyle,
    UPButtonForNewClientDeleteDisableStyle
}UPButtonStyle;

#import <UIKit/UIKit.h>

@interface UPButton : UIButton

- (void)initializeWithTitle:(NSString *)title normalPictureName:(NSString *)normalPicNm highlitedPicturName:(NSString *)highlitedPicNm disablePictureName:(NSString *)disablePicNm;
- (void)setButtonStyle:(UPButtonStyle)style;
- (void)cancelTimer;
- (UPButtonStyle)buttonStyle;

@end
