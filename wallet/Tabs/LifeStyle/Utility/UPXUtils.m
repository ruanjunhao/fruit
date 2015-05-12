//
//  UPXUtils.m
//  UPClientV3
//
//  Created by wxzhao on 13-4-10.
//  Copyright (c) 2013年 wxzhao. All rights reserved.
//

#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "UPXUtils.h"
#import "UPXConstReg.h"
#import "UPXConstKey.h"
#import "UPWDeviceUtil.h"
#import "UPWPathUtil.h"
#import "UPWAppInfoModel.h"

// 清楚 信用卡格式
static inline NSString* cleanNumber(NSString *string)
{
	return [string stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@implementation UPXUtils


#pragma mark - 清除本地登录状态

+ (void)clearLoginStatus
{
    [[NSFileManager defaultManager] removeItemAtPath:[UPWPathUtil accountInfoPlistPath] error:nil];
    UP_SHDAT.hasLogin = NO;
    UP_SHDAT.accountInfo = nil;
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNCLoginStatusChanged object:nil];
    //清除 last_login_name
    //Add by llw.
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kUDKeyLastUserName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - 银行卡号 4 位 分割
+ (NSString*)getFormatCardID:(NSString*)cardID{   // 将卡号转换为4个一空格的卡号
    //    return formatCreditCardNumber(cardID);
    
    NSString *string = [UPXUtils seperateString:cardID seperator:kSeperatorCreditCardNumber];
    return string;
}

+ (NSString*)getNormalString:(NSString*)string{   // 将4个一空格的卡号转为正常的卡号
    return cleanNumber(string);
    //   return [cardID stringByReplacingOccurrencesOfString:@" " withString:@""];
}

#pragma mark 新的分割字符串的方法
+ (NSString*)seperateString:(NSString *)string seperator:(NSString *)seperator {
    // 清楚 string 前后空格
    NSCharacterSet* set = [NSCharacterSet whitespaceCharacterSet];
    NSString *newStr = [string stringByTrimmingCharactersInSet:set];
    
    // 字符串为nil或空。则直接返回。
    if (newStr.length == 0) {
        return newStr;
    }
    // seperator 为nil或空。则直接返回。
    if (seperator.length == 0) {
        return string;
    }
    // 把 分割的 要求字符串 分成数组
    NSArray *seperatorArr = [seperator componentsSeparatedByString:@","];
    NSString *normalStr = cleanNumber(newStr);
    NSMutableArray* array = [NSMutableArray array];
    
    // 放子 字符串
    NSMutableString* subStr = [[NSMutableString alloc] initWithCapacity:1] ;
    // 默认起始位置
    int seperatorIndex = 0;
    int location = 0;
    // 遍历 字符串
    @autoreleasepool {
        for (NSInteger i = 0; i < normalStr.length; i++)
        {
            // 获取 需要的 长度
            int length = [[seperatorArr objectAtIndex:seperatorIndex] intValue];
            NSRange r = NSMakeRange(location, 1);
            
            // 获取每一位 字符，并加到 字符串中
            NSString *str = [normalStr substringWithRange:r];
            [subStr appendString:str];
            
            // 子字符串达到长度，就加到数组中
            if (subStr.length == length) {
                [array addObject:subStr];
                // 取下一个长度
                if (seperatorIndex != seperatorArr.count-1) {
                    seperatorIndex++;
                }
                // 重新 初始化 子字符串
                subStr = [[NSMutableString alloc] initWithCapacity:1] ;
            }
            else if (i == normalStr.length -1) {
                // 把剩下的字符串 也放到数组中
                [array addObject:subStr];
            }
            
            location++;
        }
    }
    
    
    // 把 分割后的数组，中间加上空格，拼成字符串
    NSString *formatStr =[array componentsJoinedByString:@" "];
    return  [formatStr stringByTrimmingCharactersInSet:set];
}



#pragma mark 移动光标位置
+ (NSInteger)spaceCountOfString:(NSString *)string {
    NSArray *arr = [string componentsSeparatedByString:@" "];
    NSInteger count = arr.count - 1;
    if (count < 0) {
        count = 0;
    }
    return count;
}


//移动光标
+ (void)moveCaretOfTextfield:(UITextField *)textField range:(NSRange)range replacementString:(NSString *)string source:(NSString *)source seperator:(NSString *)seperator
{
    if([textField conformsToProtocol:@protocol(UITextInput)])
    {
        id<UITextInput>textInput = (id<UITextInput>)textField;
        
        // 复制一份 source,改成可变字符串 ，source 是没有格式化的，可以得到当前光标位置
        NSMutableString *cardNo = [[NSMutableString alloc]initWithString:source] ;
        NSInteger currentIndex = range.location+string.length; // 修改后的位置
        NSString *sub = [cardNo substringToIndex:currentIndex]; // 修改后的 光标之前的字符串，没有格式化
        NSInteger oldSpaceCount = [UPXUtils spaceCountOfString:sub];  //  格式化之前的 空格 的个数
        NSString *normalSub = [UPXUtils getNormalString:sub];   // 修改的字符串 去掉所有的空格
        NSString *formatSub = [UPXUtils seperateString:normalSub seperator:seperator]; //  重新格式化 光标之前的字符串
        NSInteger newSpaceCount = [UPXUtils spaceCountOfString:formatSub];    // 计算 新空格的个数
        
        NSInteger count = newSpaceCount - oldSpaceCount; // 计算空格差
        
        // 从左边计算 偏移量，移动光标
        UITextPosition *startPos = [textInput positionFromPosition:textInput.beginningOfDocument offset:currentIndex+count];
        [textInput setSelectedTextRange:[textInput textRangeFromPosition:startPos toPosition:startPos]];
    }
}


#pragma mark -
#pragma mark  runtime

+ (NSArray*)propertyFromClass:(Class) cls
{
    NSMutableArray* result = [NSMutableArray array];
    unsigned int count;
    objc_property_t *props = class_copyPropertyList(cls, &count);
    for (int i = 0; i < count; ++i){
        const char *propName = property_getName(props[i]);
        [result addObject:[NSString stringWithUTF8String:propName]];
    }
    free(props);
    return result;
}

+ (NSArray*)propertyArray:(Class) cls
{
    NSMutableArray* result = [NSMutableArray array];
    
    Class classOfObject = cls;
    while(![classOfObject isEqual:[NSObject class]])
    {
        [result addObjectsFromArray:[self propertyFromClass:classOfObject]];
        classOfObject = [classOfObject superclass];
    }
    return result;
}

+ (NSDictionary*)dictionaryFromObject:(id)object
{
    NSMutableDictionary* d = [NSMutableDictionary dictionary];
    NSArray* p = [self propertyArray:[object class]];
    for (NSString* k in p) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        //transform the value
                id v = [object performSelector:NSSelectorFromString(k)];
#pragma clang diagnostic pop

        if (v) {
            [d setObject:v forKey:k];
        }
    }
    return d;
}

+ (id)objectFromDictionary:(NSDictionary*) dict ofClass:(Class) cls
{
    id r = [[cls alloc] init];
    NSArray* p = [self propertyArray:cls];
    for (NSString* k in p) {
        id v = [dict valueForKey:k];
        
        if (v) {
            [r setValue:v forKey:k];
        }
    }
    return r;
}

+ (NSString *)getAppDestWithAppId:(NSString *)appId
{
    UPWAppInfoModel* appInfo = UP_SHDAT.allAppInfo[appId];
    return appInfo.dest;
}


#pragma mark 手机号码 3，4，4 分割
+ (NSString*)getFormatMobileNumber:(NSString *)mobileNum
{
    if (mobileNum) {
        NSString *string = [UPXUtils seperateString:mobileNum seperator:kSeperatorMobileNumber];
        return string;
    }else {
        return nil;
    }
    
}

+ (void)saveHistoryWithBill:(UPXModelBill *)bill withAppID:(NSString*)appId compare:(NSArray *)parameters maxCount:(int)maxCount
{
//    UPXModelAppBill *his = [[UPXModelAppBill alloc] initWithAppID:appId];
//    if (maxCount>0) {
//        [his setAppMaxHistoryCount:maxCount];
//    }
//    // 创建 缴费日期
//    NSDate *date = [NSDate date];
//    NSDateFormatter *formattor = [[NSDateFormatter alloc] init];
//    [formattor setDateFormat:kUPClientTimeFormat];
//    NSString *dateStr = [formattor stringFromDate:date];
//    bill.bill_date = dateStr;
//
//    
//    // block 中， 实现 去重 功能。return YES 表示有重复，NO表示没有重复
//    [his addBillHistory:bill withCompare:^BOOL(id obj1, id obj2) {
//        BOOL isEqual = YES;
//        for (NSString *key in parameters) {
//            
//            NSString *value1 = [obj1 objectForKey:key];
//            NSString *value2 = [obj2 objectForKey:key];
//            
//            if ([value1 isEqualToString:value2]) {
//                // 如果相等，就遍历继续
//                isEqual = YES;
//            } else {
//                // 有一个不行等，就返回NO
//                isEqual = NO;
//                break;
//            }
//        }
//        
//        return isEqual;
//        
//    }];
    
}


#pragma mark - 由appId获取classification
+ (NSString *)getAppClassificationWithAppId:(NSString *)appId {
    NSString *appClassification = @"";
    NSDictionary *appInfo = [UP_SHDAT.allAppInfo valueForKey:appId];
    if (appInfo) {
        appClassification = [appInfo valueForKey:@"classification"];
    }
    return appClassification;
}



#pragma mark - Luhn算法验证信用卡卡号是否有效
/* luhn 算法 http://www.pbc.gov.cn/rhwg/20001801f102.htm
 LUHN算法，主要用来计算信用卡等证件号码的合法性。
 1、从卡号最后一位数字开始,偶数位乘以2,如果乘以2的结果是两位数，将两个位上数字相加保存。
 2、把所有数字相加,得到总和。
 3、如果信用卡号码是合法的，总和可以被10整除。
 */
+ (NSMutableArray*)charArrayFromString:(NSString *)string
{
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[string length]];
    for (int i=0; i < [string length]; i++) {
        NSString *ichar  = [NSString stringWithFormat:@"%c", [string characterAtIndex:i]];
        [characters addObject:ichar];
    }
    return characters;
}
+ (BOOL)luhnCheck:(NSString *)stringToTest
{
    NSMutableArray *stringAsChars = [UPXUtils charArrayFromString:stringToTest];
    BOOL isOdd = YES;
    int oddSum = 0;
    int evenSum = 0;
    for (NSInteger i = [stringToTest length] - 1; i >= 0; i--) {
        int digit = [(NSString *)stringAsChars[i] intValue];
        if (isOdd) {
            oddSum += digit;
        }
        else {
            //            evenSum += digit/5 + (2*digit) % 10;
            // 上面一句话分为下面三句话
            digit = digit*2;
            int even = digit / 10 + digit % 10;
            evenSum = evenSum + even;
        }
        isOdd = !isOdd;
    }
    return ((oddSum + evenSum) % 10 == 0);
}


#pragma mark 从cordova中返回的参数生成NSDictionary

+ (NSDictionary*)dictionaryFromCordovaArgument:(id)object
{
    NSDictionary* result = nil;
    if ([object isKindOfClass:[NSNull class]]) {
        result = nil;
    }
    if ([object isKindOfClass:[NSString class]]) {
        NSString * str = (NSString *)object;
        if (!UP_IS_NIL(str)) {
            result = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

        }
    }
    if ([object isKindOfClass:[NSDictionary class]]) {
        result = object;
    }
    return result;
    
}


#pragma mark 判断是否为合法银行卡

+ (BOOL)isCreditCardLegal:(NSString *)cardNum
{
    BOOL isLegal = NO;
    BOOL isMatch  = UP_REGEXP(cardNum, kCreditCardPredicate);
    if (isMatch) {
        // luhn 算法 ，校验 卡号 最后一位 是否合法
        BOOL isLuhnOk = [UPXUtils luhnCheck:cardNum];
        if (isLuhnOk) {
            isLegal = YES;
        }
    }
    return isLegal;
}



#pragma mark 判断身份证是否合法


//判断是否在地区码内

+(BOOL)areaCode:(NSString *)code
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"北京" forKey:@"11"];
    [dic setObject:@"天津" forKey:@"12"];
    [dic setObject:@"河北" forKey:@"13"];
    [dic setObject:@"山西" forKey:@"14"];
    [dic setObject:@"内蒙古" forKey:@"15"];
    [dic setObject:@"辽宁" forKey:@"21"];
    [dic setObject:@"吉林" forKey:@"22"];
    [dic setObject:@"黑龙江" forKey:@"23"];
    [dic setObject:@"上海" forKey:@"31"];
    [dic setObject:@"江苏" forKey:@"32"];
    [dic setObject:@"浙江" forKey:@"33"];
    [dic setObject:@"安徽" forKey:@"34"];
    [dic setObject:@"福建" forKey:@"35"];
    [dic setObject:@"江西" forKey:@"36"];
    [dic setObject:@"山东" forKey:@"37"];
    [dic setObject:@"河南" forKey:@"41"];
    [dic setObject:@"湖北" forKey:@"42"];
    [dic setObject:@"湖南" forKey:@"43"];
    [dic setObject:@"广东" forKey:@"44"];
    [dic setObject:@"广西" forKey:@"45"];
    [dic setObject:@"海南" forKey:@"46"];
    [dic setObject:@"重庆" forKey:@"50"];
    [dic setObject:@"四川" forKey:@"51"];
    [dic setObject:@"贵州" forKey:@"52"];
    [dic setObject:@"云南" forKey:@"53"];
    [dic setObject:@"西藏" forKey:@"54"];
    [dic setObject:@"陕西" forKey:@"61"];
    [dic setObject:@"甘肃" forKey:@"62"];
    [dic setObject:@"青海" forKey:@"63"];
    [dic setObject:@"宁夏" forKey:@"64"];
    [dic setObject:@"新疆" forKey:@"65"];
    [dic setObject:@"台湾" forKey:@"71"];
    [dic setObject:@"香港" forKey:@"81"];
    [dic setObject:@"澳门" forKey:@"82"];
    [dic setObject:@"国外" forKey:@"91"];
    
    if ([dic objectForKey:code] == nil) {
        return NO;
    }
    return YES;
}

//验证身份证是否合法

+ (BOOL)isIdCardNumberLegal:(NSString*)certId
{
    //判断位数
    if ([certId length] < 15 ||[certId length] > 18) {
        
        return NO;
    }
    
    NSString *carid = certId;
    long lSumQT =0;
    //加权因子
    int R[] ={7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 };
    //校验码
    unsigned char sChecker[11]={'1','0','X', '9', '8', '7', '6', '5', '4', '3', '2'};
    
    //将15位身份证号转换成18位
    
    NSMutableString *mString = [certId mutableCopy];
    if ([mString length] == 15) {
        
        [mString insertString:@"19" atIndex:6];
        
        long p = 0;
        const char *pid = [mString UTF8String];
        for (int i=0; i<=16; i++)
        {
            p += (pid[i]-48) * R[i];
        }
        
        int o = p%11;
        NSString *string_content = [NSString stringWithFormat:@"%c",sChecker[o]];
        [mString insertString:string_content atIndex:[mString length]];
        carid = mString;
        
    }
    
    //判断地区码
    NSString * province = [carid substringToIndex:2];
    
    if (![self areaCode:province]) {
        
        return NO;
    }
    
    //判断年月日是否有效
    int strYear = [[carid substringWithRange:NSMakeRange(6, 4)] intValue];
    int strMonth = [[carid substringWithRange:NSMakeRange(10, 2)] intValue];
    int strDay = [[carid substringWithRange:NSMakeRange(12, 2)] intValue];
    
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeZone:localZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[dateFormatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d 12:01:01",strYear,strMonth,strDay]];
    if (date == nil) {
        return NO;
    }
    
    const char *paperId  = [carid UTF8String];
    
    //检验长度
    if( 18 != strlen(paperId)) return NO;
    //校验数字
    for (int i=0; i<18; i++)
    {
        if ( !isdigit(paperId[i]) && !(('X' == paperId[i] || 'x' == paperId[i]) && 17 == i) )
        {
            return NO;
        }
    }
    //验证最末的校验码
    for (int i=0; i<=16; i++)
    {
        lSumQT += (paperId[i]-48) * R[i];
    }
    if (sChecker[lSumQT%11] != paperId[17] )
    {
        return NO;
    }
    
    return YES;
}

@end


