//
//  UPWAppUtil.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPWAppUtil.h"
#import "UPWPlistUtil.h"
#import "UPWDeviceUtil.h"

@implementation UPWAppUtil
#pragma mark -
#pragma mark 系统版本号
+ (float)deviceOS
{
    static float deviceOSVersion = 0.0f;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceOSVersion = [[UPWDeviceUtil deviceOSVersion] floatValue];
    });
    return deviceOSVersion;
}

#pragma mark - app版本号

+ (NSString*)appVersion
{
    NSDictionary *infoPlistDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoPlistDict objectForKey:@"CFBundleShortVersionString"];
    if (!version) {
        version = [infoPlistDict objectForKey:@"CFBundleVersion"];
    }
    return version;
}

#pragma mark - 去掉小数点的app版本号

+ (NSString*)formatAppVersion
{
    NSString* version = [self appVersion];
    return [version stringByReplacingOccurrencesOfString:@"." withString:@""];
}

#pragma mark -
#pragma mark 判断字符串是否为空（nil和length为0都是空）

+ (BOOL)isEmpty:(NSString *)value
{
    return  (nil == value || [value isKindOfClass:[NSNull class]] || ([value length] == 0) || [[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]);
}

#pragma mark -
#pragma mark 从字符串生成UIColor


+ (UIColor*)colorWithHexString: (NSString *) str
{
    NSString *tmp = [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([tmp length] < 8){
        UPDERROR(@"colorWithHexString len < 8: %@",str);
        return nil;
    }
    
    if ([tmp hasPrefix:@"0X"]){
        tmp = [tmp substringFromIndex:2];
        
    }
    if ([tmp hasPrefix:@"#"]){
        tmp = [tmp substringFromIndex:1];
    }
    
    if ([tmp length] != 8){
        UPDERROR(@"colorWithHexString len < 8: %@",str);
        return nil;
    }
    
    unsigned long color = strtoul([tmp UTF8String],0,16);
    float a = ((float)((color & 0xFF000000) >> 24))/255.0;
    float r = ((float)((color & 0xFF0000) >> 16))/255.0;
    float g = ((float)((color & 0xFF00) >> 8))/255.0;
    float b = ((float)(color & 0xFF))/255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}


#pragma mark -
#pragma mark 获取UIImage， 如果图片找不到或者尺寸为0 返回nil
+ (UIImage*)getImage:(NSString*) imageName
{
    UIImage* image = [UIImage imageNamed:imageName];
    if (!image) {
        UPDERROR(@"getImage error! Miss image:%@",imageName);
        return nil;
    }
    if ( CGSizeEqualToSize(image.size, CGSizeZero)) {
        UPDERROR(@"getImage error! %@  size = zero!",imageName);
        return nil;
    }
    return image;
}

#pragma mark -
#pragma mark 本地化字符串
static UPWPlistUtil* localDict = nil;

+ (NSString*)localizedStringWithKey:(NSString*)key
{
    NSString* result = key;
    
    if (!localDict) {
        localDict = [UPWPlistUtil reloadPlistWithType:kPlistTypeLocalization];
    }
    if (localDict){
        result = [localDict objectForKey:key];
    }
    if (UP_IS_NIL(result)) {
        result = key;
    }
    return result;
}

+ (NSArray*)localizedArrayWithKey:(NSString*)key
{
    NSArray* result = nil;
    
    if (!localDict) {
        localDict = [UPWPlistUtil reloadPlistWithType:kPlistTypeLocalization];
    }
    if (localDict){
        result = [localDict objectForKey:key];
    }
    if (!result) {
        result = [NSMutableArray array];
    }
    return result;
}


#pragma mark - 从UI提示语配置文件中取得相应的String

+ (void)writeConfigFile:(NSData *)data
{
    NSString *errorDescription = nil;
    NSPropertyListFormat format;
    NSDictionary *dict = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&errorDescription];
    //merge 新旧config , 保留旧的字段, 只更新新的
    
    [dict enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        [localDict setObject:obj forKey:key];
    }];
    [localDict synchronize];
    
    //下次本地化时reload plist
    [UPWPlistUtil releasePlist:kPlistTypeLocalization];
    
    localDict = nil;
}
#pragma mark -
#pragma mark 是否retina

+ (BOOL)isRetina
{
    static BOOL isRetinaSkin = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isRetinaSkin = [UIScreen mainScreen].scale > 1.0;
    });
    return isRetinaSkin;
}

#pragma mark -
#pragma mark 从String创建URL
+ (NSURL*)urlWithString:(NSString *)value
{
    NSURL* url = nil;
    if (![self isEmpty:value]) {
        url = [NSURL URLWithString:value];
    }
    return url;
}

+ (BOOL)isAllowRemoteNotification
{
    UIApplication * app = [UIApplication sharedApplication];
    if([app respondsToSelector:@selector(currentUserNotificationSettings)]) {
         UIUserNotificationSettings * t = [app currentUserNotificationSettings];
        return (t.types != UIUserNotificationTypeNone);
    }
    else {
        UIRemoteNotificationType t = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        //return (t != UIRemoteNotificationTypeNone);
        return (t&UIRemoteNotificationTypeBadge)|(t&UIRemoteNotificationTypeSound)|(t&UIRemoteNotificationTypeAlert);
    }
}

+ (NSString *)formatBankNumberWithStar:(NSString *)bankNumber
{
    //其实外部在调用此函数时，已经对卡号长度做了验证，在此只是保证不crash
    if(bankNumber.length < 8) {
        return nil;
    }
    
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:[bankNumber substringToIndex:4]];
    for (NSInteger i = 0; i < bankNumber.length-8; i++) {
        [string appendString:@"*"];
    }
    [string appendString:[bankNumber substringFromIndex:(bankNumber.length-4)]];
    
    return [self formatBankNumber:string];
}

+ (NSString*)formatBankNumber:(NSString *)bankNumber
{
    NSMutableString* formatBankNumber = [[NSMutableString alloc] initWithCapacity:0];
    for (int i = 0; i < [bankNumber length];) {
        NSUInteger len = 4;
        if (i + len > [bankNumber length]) {
            len = [bankNumber length] - i;
        }
        
        NSRange range = NSMakeRange(i, len);
        [formatBankNumber appendString:[bankNumber substringWithRange:range]];
        
        if (len == 4) {
            [formatBankNumber appendString:@" "];
        }
        
        i += len;
    }
    
    return formatBankNumber;
}


+ (NSString*)trimBankNumber:(NSString *)bankNumber
{
    NSMutableString* trimBankNumber = [[NSMutableString alloc] initWithCapacity:0];
    for (int i = 0; i < [bankNumber length]; i++)
    {
        NSString* subString = [bankNumber substringWithRange:NSMakeRange(i, 1)];
        if ([subString isEqualToString:@" "] || [subString isEqualToString:@" "]) {
            continue;
        }
        
        [trimBankNumber appendString:subString];
    }
    
    return trimBankNumber;
}

+ (NSString *)appBundleDisplayName
{
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
}


+ (BOOL)waitForTarget:(FinishBlock)block withTimeout:(NSTimeInterval)timeoutInSeconds{
    NSDate* giveUpDate = [NSDate dateWithTimeIntervalSinceNow:timeoutInSeconds];
    
    while (!block() && ([giveUpDate timeIntervalSinceNow] > 0)) {
        NSDate *stopDate = [NSDate dateWithTimeIntervalSinceNow:0.2];
        [[NSRunLoop currentRunLoop] runUntilDate:stopDate];   // un-blocking.
    }
    
    return block();
}



// ~ http://stackoverflow.com/questions/18905686/itunes-review-url-and-ios-7-ask-user-to-rate-our-app-appstore-show-a-blank-pag
+ (NSString *)ratingAppStoreUrlById:(NSString *)appId
{
    NSString * ratingUrl = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appId];
    
    return ratingUrl;
}


+ (NSString *)appStoreUrlById:(NSString *)appId
{
    return [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@", appId];
}

+ (NSString *)gaodeMapAppKey
{
    /*
     高德地图KEY 对应Indentifer映射如下：
     com.huanwei.fruit   0a1a030c33c0eee0363aefac62318e3b
     com.huanwei.fruit.inhouse
     */
    
    NSDictionary * mapKeys = @{@"com.huanwei.fruit":@"0a1a030c33c0eee0363aefac62318e3b", @"com.huanwei.fruit.inhouse":@""};
    NSString * identifer = [[self class] appBundleIdentifier];
    NSString * key = mapKeys[identifer];

    NSAssert(!UP_IS_NIL(key), @"Gaode Map key not found error");
    
    return key;
}

+ (NSString *)appBundleIdentifier
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

@end
