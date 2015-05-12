//
//  UPUnionMenuButtonCHSP.h
//  ttttttestv
//
//  Created by TZ_JSKFZX_CAOQ on 13-11-11.
//  Copyright (c) 2013年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWUnionMenuBar.h"

@interface UPWUnionMenuButtonCHSP : UPWUnionMenuButton

- (void)setButtonSelected:(BOOL)selected;
- (void)setButtonTitle:(NSString*)title showWordsLength:(NSInteger)length;

- (void)setNormalImage:(UIImage*)image;
- (void)setHighlightedImage:(UIImage*)image;

@end
