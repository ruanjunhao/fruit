//
//  NSObject+Swizzle.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzle)

+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel;
+ (BOOL)swizzleClassMethod:(SEL)origSel withClassMethod:(SEL)altSel;

@end
