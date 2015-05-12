//
//  NSString+UPEx.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-26.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UPEx)

- (CGSize)frameForFont:(UIFont*)font;
- (CGSize)frameForFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (NSString *)formatDate;
- (NSString *)formatDateWithDot;
- (NSString *)formatPreciousDate;
- (NSString *)currentTime;

@end
