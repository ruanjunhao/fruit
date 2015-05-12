//
//  NSDictionary+UPEx.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-26.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (UPEx)

- (BOOL)boolForKey_upex:(NSString *)keyName;
- (float)floatForKey_upex_st:(NSString *)keyName;      //跟分辨率无关
- (NSInteger)integerForKey_upex:(NSString *)keyName;
- (NSString *)stringForKey_upex:(NSString *)keyName;
- (NSDictionary *)dictionaryForKey_upex:(NSString *)keyName;
-(void)setBool_upex:(BOOL)value forKey:(NSString*)keyName;
-(void)setInteger_upex:(NSInteger)value forKey:(NSString*)keyName;
- (BOOL)writeToFile_upex:(NSString *)path atomically:(BOOL)useAuxiliaryFile;

@end
