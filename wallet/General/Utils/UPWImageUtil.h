//
//  UPWImageUtil.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-30.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPWImageUtil : NSObject

+ (UIImage*)image568H:(NSString*)imageName;

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

+ (UIImage*)resizeImageNamed:(NSString*)imageName size:(CGSize)size;

//把方形button或view变成圆形
void setRoundedView(id obj,float newSize);

+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;

@end
