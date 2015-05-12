//
//  NSString+UPEx.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-26.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "NSString+UPEx.h"

@implementation NSString (UPEx)


#pragma mark -
#pragma mark 帮助方法, 处理 sizeWithFont

- (CGSize)frameForFont:(UIFont*)font
{
    return [self frameForFont:font constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
}

- (CGSize)frameForFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    if (UP_iOSgt7) {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = lineBreakMode;
        
        NSDictionary * attributes = @{NSFontAttributeName:font,
                                      NSParagraphStyleAttributeName:paragraphStyle
                                      };
        
        
        CGRect textRect = [self boundingRectWithSize:size
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes
                                             context:nil];
        return textRect.size;

    }
    else{
        return [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
    }
    
}

- (NSString *)formatDate
{
    if([self length] < 8) {
        return @"";
    }
    
    NSString * date = self;
    NSRange range = {4,2};
    NSString* year = [date substringToIndex:4];
    NSString* month = [date substringWithRange:range];
    NSString* day = [date substringWithRange:NSMakeRange(6, 2)];
    
    return [NSString stringWithFormat:@"%@-%@-%@", year, month, day];
}

- (NSString *)formatDateWithDot
{
    if([self length] < 8) {
        return @"";
    }
    
    NSString * date = self;
    NSRange range = {4,2};
    NSString* year = [date substringToIndex:4];
    NSString* month = [date substringWithRange:range];
    NSString* day = [date substringWithRange:NSMakeRange(6, 2)];
    
    return [NSString stringWithFormat:@"%@.%@.%@", year, month, day];
}

- (NSString *)formatPreciousDate
{
    if([self length] < 14) {
        return [self formatDate];
    }
    
    NSString * date = self;
    NSRange range = {4,2};
    NSString* year = [date substringToIndex:4];
    NSString* month = [date substringWithRange:range];
    range.location = 6;
    NSString* day = [date substringWithRange:range];
    range.location = 8;
    NSString *hour = [date substringWithRange:range];
    range.location = 10;
    NSString *minute = [date substringWithRange:range];
    range.location = 12;
    NSString *second = [date substringWithRange:range];
    
    return [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", year,month,day, hour, minute, second] ;
}

- (NSString *)currentTime
{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    NSDate *curDate = [NSDate date];
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    NSString* curTime = [formater stringFromDate:curDate];
    return curTime;
}

@end
