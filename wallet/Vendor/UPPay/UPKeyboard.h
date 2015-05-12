//
//  UPKeyboard.h
//  UPPay_test
//
//  Created by UnionPay on 11-10-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, UPKeyboardMode) {
    UPKeyboardModeDevelopment = 1, // 开发环境 对应控件mode 99
    UPKeyboardModePM,              // PM环境 对应控件mode 01
    UPKeyboardModeProduction,      // 生产环境 对应控件mode 00
    
    // 全渠道
    UPKeyboardModeF_Development,     // 开发环境 对应控件mode 99
    UPKeyboardModeF_PM,              // PM环境 对应控件mode 01
    UPKeyboardModeF_Production,      // 生产环境 对应控件mode 00
};

@protocol UPKeyboardDelegate

- (void)doneClick;
- (void)textChanged:(NSString*)text;
- (void)deleteClick;

@end


@interface UPKeyboard : UIView {
    
}
@property(nonatomic, assign)id<UPKeyboardDelegate> mDelegate;


- (void)refreshKeyBoard;

- (void)cleanSecurityPin;

- (void)deleteEncryptedPin;

// normal or secuity keyboard setter. parameter = YES set to security. || (for plugin)
- (void)setSecurity:(BOOL)security;

// set publicKey.
// YES: test Mode , NO:product Mode
// for client3.0
- (void)pinBlockRSAMode:(UPKeyboardMode)mode;

// real pin
- (NSString *)currentPin;

// encrypted pinblock
- (NSString *)pinBlockWithPan:(NSString *)pan;

// orientation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@end
