//
//  UPCityModel.m
//  UPWallet
//
//  Created by wxzhao on 14-7-19.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWCityModel.h"

@implementation UPWCityModel

- (NSString*)threeCityName
{
    NSString* result = self.cityNm;
    if ([result length] > 3) {
        result = [[result substringToIndex:3] stringByAppendingString:@"..."];
    }
    return result;
}
@end
