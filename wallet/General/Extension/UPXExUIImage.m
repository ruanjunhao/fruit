//
//  UPExUIImage.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-5-27.
//
//

#import "UPXExUIImage.h"
#import "UPWMarco.h"
#import "UPWAppUtil.h"

@implementation UIImage (UPXExtensions)

+ (UIImage*)imageWithColor_upex:(UIColor*)color size:(CGSize) size 
{
    NSInteger scale = UP_ISRETINA ? 2 : 1;
    if (scale > 1)
    {
        size = UP_CGSizeScale(size, scale);
    }
    
    color = color==nil?[UIColor clearColor]:color;
    CGColorRef colorRef = [color CGColor];
    const CGFloat *components = CGColorGetComponents(colorRef);
    
    NSInteger width  = size.width;
	NSInteger height = size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, (4 * width), colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGContextSetRGBFillColor(context, components[0],components[1],components[2], components[3]);
    CGRect rect = CGRectMake(0,0,size.width,size.height);
    CGContextAddRect(context,rect);
    CGContextFillPath(context);
  
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage   *imageRet = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
	CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return  imageRet;
}



@end
