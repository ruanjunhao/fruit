//
//  UPXUtils.h
//  UPClientV3
//
//  Created by wxzhao on 13-4-10.
//  Copyright (c) 2013年 wxzhao. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SinaWeibo.h"
#import "UPPayPluginDelegate.h"


@class UPXModelBill;

@interface UPXUtils : NSObject

+ (void)clearLoginStatus;

+ (NSString*)getFormatCardID:(NSString*)cardID;

+ (NSString*)getNormalString:(NSString*)string;

#pragma mark 手机号码 3，4，4 分割
+ (NSString*)getFormatMobileNumber:(NSString *)mobileNum;
/**
 *	@brief	移动光标的位置，前三个参数 对应 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string 中的三个参数
 *
 *	@param 	textField 	对应的输入框
 *	@param 	range 	<#range description#>
 *	@param 	string 	<#string description#>
 *	@param 	source 	修改后 没有格式化 的字符串。
 */
+ (void)moveCaretOfTextfield:(UITextField *)textField range:(NSRange)range replacementString:(NSString *)string source:(NSString *)source  seperator:(NSString *)seperator
;

/**
 *	@brief	分割字符串
 *
 *	@param 	string 	需要分割的原始字符串
 *	@param 	seperator 	分割的长度。例如 手机号可以是 3,4,4  或 3,4 ; 信用卡还款是 4
 *
 *	@return	返回分割后的字符串
 */
+ (NSString*)seperateString:(NSString *)string seperator:(NSString *)seperator;


#pragma mark -
#pragma mark  runtime

+ (NSArray*)propertyFromClass:(Class)cls;

+ (NSArray*)propertyArray:(Class)cls;

+ (NSDictionary*)dictionaryFromObject:(id)object;

+ (id)objectFromDictionary:(NSDictionary*)dict ofClass:(Class)cls;

+ (NSString *)getAppDestWithAppId:(NSString *)appId;

+ (void)saveHistoryWithBill:(UPXModelBill *)bill withAppID:(NSString*)appId compare:(NSArray *)parameters maxCount:(int)maxCount;

+ (NSString *)getAppClassificationWithAppId:(NSString *)appId;

+ (BOOL)luhnCheck:(NSString *)stringToTest;

+ (NSDictionary*)dictionaryFromCordovaArgument:(id)object;

+ (BOOL)isCreditCardLegal:(NSString *)cardNum;

//验证身份证是否合法

+ (BOOL)isIdCardNumberLegal:(NSString*)certId;

@end
