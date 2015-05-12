//
//  UPWImageUtil.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-30.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWImageUtil.h"
#import "UIImage+Resize.h"
#import <Accelerate/Accelerate.h>

@implementation UPWImageUtil

#pragma mark -
#pragma mark image处理
/*
 * imageName不带.png,不带@2x,示例：test-568h@2x.png,test@2x.png,一律传入test,函数
 * 将会判断是否iPhone5，返回test-568h.png,test.png,系统将会根据是否 retina屏幕，自动
 * 追加@2x变成test-568h@2x.png,test@2x.png
 */
+ (UIImage*)image568H:(NSString*)imageName
{
    NSString* newImageName = nil;
    if (UP_IPHONE5) {
        newImageName = [imageName stringByAppendingString:@"-568h@2x"];
    }
    else if(UP_IPHONE6){
        newImageName = [imageName stringByAppendingString:@"-800-667h@2x"];
    }
    else if (UP_IPHONE6_PLUS){
        newImageName = [imageName stringByAppendingString:@"-800-Portrait-736h@3x"];
    }
    else{
        newImageName = imageName;
    }
    NSString* imagePath = [[NSBundle mainBundle] pathForResource:newImageName ofType:@"png"];
    return [[UIImage alloc] initWithContentsOfFile:imagePath];
}

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage*)resizeImageNamed:(NSString*)imageName size:(CGSize)size
{
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image resizedImageToFitInSize:size scaleIfSmaller:NO];
    UIImage *bgImage =  [image resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    
    return bgImage;
}

//把方形button或view变成圆形
void setRoundedView(id obj,float newSize)
{
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(newSize/2, newSize/2) radius:newSize/2 startAngle:0 endAngle:2*M_PI clockwise:YES];
    CAShapeLayer * shape = [CAShapeLayer layer];
    shape.path = path.CGPath;
    shape.lineWidth = 0.2;
    
    if ([obj isKindOfClass:[UIButton class]])
    {
        UIButton * targetobj = (UIButton *)obj;
        targetobj.layer.mask = shape;
    }
    else if([obj isKindOfClass:[UIView class]])
    {
        UIView * targetobj = (UIView *)obj;
        targetobj.layer.mask = shape;
    }
}

//加模糊效果，image是图片，blur是模糊度
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur
{
    //模糊度,
    if ((blur < 0.1f) || (blur > 2.0f)) {
        blur = 0.5f;
    }
    
    //boxSize必须大于0
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    //图像处理
    CGImageRef img = image.CGImage;
    //需要引入#import <Accelerate/Accelerate.h>
    /*
     This document describes the Accelerate Framework, which contains C APIs for vector and matrix math, digital signal processing, large number handling, and image processing.
     本文档介绍了Accelerate Framework，其中包含C语言应用程序接口（API）的向量和矩阵数学，数字信号处理，大量处理和图像处理。
     */
    
    //图像缓存,输入缓存，输出缓存
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    //像素缓存
    void *pixelBuffer;
    
    //数据源提供者，Defines an opaque type that supplies Quartz with data.
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    // provider’s data.
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    //宽，高，字节/行，data
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //像数缓存，字节行*图片高
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    
    // 第三个中间的缓存区,抗锯齿的效果
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //Convolves a region of interest within an ARGB8888 source image by an implicit M x N kernel that has the effect of a box filter.
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    
    if (error) {
        UPDINFO(@"error from convolution %ld", error);
    }
    
    //    UPDINFO(@"字节组成部分：%zu",CGImageGetBitsPerComponent(img));
    //颜色空间DeviceRGB
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    //根据上下文，处理过的图片，重新组件
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end
