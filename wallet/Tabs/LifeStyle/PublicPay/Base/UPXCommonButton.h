//
//  UPCommonButton.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-5-26.
//
//

#import <UIKit/UIKit.h>

@interface UPXCommonButton : UIButton

+ (instancetype)blueButtonWithTitle:(NSString*)title;
+ (instancetype)grayButtonWithTitle:(NSString*)title;
+ (instancetype)yellowButtonWithTitle:(NSString*)title;
+ (instancetype)navigationButtonWithTitle:(NSString*)title;
+ (instancetype)deleteButtonWithTitle:(NSString*)title;

@end




@interface UPXBackButton : UIButton

+ (instancetype)backButton;

@end