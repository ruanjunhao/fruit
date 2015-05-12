//
//  UPWAppInfoModel.m
//  wallet
//
//  Created by qcao on 14/11/4.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWAppInfoModel.h"
#import "UPXConstKey.h"

@implementation UPWAppInfoModel


+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id": @"appId",@"v":@"version"}];
}


- (BOOL)isThirdPartyApp {
    NSString *classification = self.classification;
    if ([classification isEqualToString:kUPXPayKeyClassificationIsThirdPartyApp]) {
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)perm:(NSString*)perm atIndex:(NSInteger)idx
{
    if (perm.length < (idx+1)) {
        return NO;
    }
    
    int support = [[perm substringWithRange:NSMakeRange(idx, 1)] intValue];
    if (support == 0) {
        return NO;
    }else {
        return YES;
    }
}

#pragma mark - 应用是否默认应用

- (BOOL)isDefaultApp
{
    return [self perm:self.perm atIndex:0]; // perm 第一位1表示默认应用
}

#pragma mark - 应用是否支持添加提醒日

- (BOOL)isSupportRemind
{
    return [self perm:self.perm atIndex:1]; // perm 第二位1表示支持提醒日
}

#pragma mark - 应用是否热门

- (BOOL)isHotApp
{
    return [self perm:self.perm atIndex:2];  //  perm 第三位1表示热门app
}

#pragma mark - 应用是否可删除

- (BOOL)isAppUnable4Delete
{
    return [self perm:self.perm atIndex:3];  // perm 第四位1表示不能删除
}


#pragma mark - 应用能否显示

- (BOOL)shouldAppDisplay
{
    BOOL result = NO;
    if (!UP_IS_NIL(self.display) && [self.display isEqualToString:@"1"]) {
        result = YES;
    }
    return result;
}


@end
