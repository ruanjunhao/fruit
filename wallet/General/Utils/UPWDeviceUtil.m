//
//  UPWDeviceUtil.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-24.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWDeviceUtil.h"
#import <UIKit/UIKit.h>
#include <sys/sysctl.h>
#import "KeychainItemWrapper.h"

#define kKeyKeychainVendorIDIdentifier @"UPWVendorID"

@implementation UPWDeviceUtil

/* Return a string description of the UUID, such as "E621E1F8-C36C-495A-93FC-0C247A3E6E5F" */
+ (NSString*)vendorIdentifier
{
     return [self readVendorID];
}

// 读取 VendorID，并存储钥匙串
+ (NSString *)readVendorID {
    NSString *group = [NSString stringWithFormat:@"%@.%@",[self bundleSeedID],[[NSBundle mainBundle] bundleIdentifier]];
    // 存储account
    KeychainItemWrapper *accountWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kKeyKeychainVendorIDIdentifier accessGroup:group];
    NSString *account = [accountWrapper objectForKey:(__bridge id)kSecAttrAccount];
    if (!account || [account isEqualToString:@""]) {
        [accountWrapper setObject:kKeyKeychainVendorIDIdentifier forKey:(__bridge id)kSecAttrAccount];
    }
    NSString *uuid = [accountWrapper objectForKey:(__bridge id)kSecValueData];
    if (!uuid || [uuid isEqualToString:@""]) {
        uuid = UIDevice.currentDevice.identifierForVendor.UUIDString;
        
        // save to keychain
        [accountWrapper setObject:uuid forKey:(__bridge id)kSecValueData];
    }
    else {
        
    }
    return uuid;
}

/* 读取 AppIdentifierPrefix
 You can programmatically retrieve the Bundle Seed ID by looking at the access group attribute (i.e. kSecAttrAccessGroup) of an existing KeyChain item. In the code below, I look up for an existing KeyChain entry and create one if it doesn't not exist. Once I have a KeyChain entry, I extract the access group information from it and return the access group's first component separated by "." (period) as the Bundle Seed ID.
 */
+ (NSString *)bundleSeedID {
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge id)(kSecClassGenericPassword), kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status != errSecSuccess)
        return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge id)(kSecAttrAccessGroup)];
    NSArray *components = [accessGroup componentsSeparatedByString:@"."];
    NSString *bundleSeedID = [[components objectEnumerator] nextObject];
    CFRelease(result);
    return bundleSeedID;
}


//4.3.3
+ (NSString*)deviceOSVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString*)machineType
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *answer = (char*)malloc(size);
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];//iPhone3,1
    free(answer);
    return results;
}


+ (NSString*)deviceWidth
{
    CGRect mainRect =  [UIScreen mainScreen].bounds;
    CGFloat scale = [UIScreen mainScreen].scale;
    int width =(int) mainRect.size.width*scale;
    NSString* strWidth = [NSString stringWithFormat:@"%d",width];
    return strWidth;
}

+ (NSString*)deviceHeight
{
    CGRect mainRect =  [UIScreen mainScreen].bounds;
    CGFloat scale = [UIScreen mainScreen].scale;
    int height =(int) mainRect.size.height*scale;
    NSString* strHeight = [NSString stringWithFormat:@"%d",height];
    return strHeight;
}

/* iPhone iPad */
+ (NSString*)model
{
    return [UIDevice currentDevice].model;
}

/* iOS */
+ (NSString*)systemName
{
    return @"ios";
}

/* 01 is chinese, 02 is others like en*/
+ (NSString*)localLanguage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if([currentLanguage hasPrefix:@"zh"]) {
        return @"01";
    }
    
    return @"02";
}

/* 640* 1136 , 640*960 */
+ (NSString*)screenSize
{
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize Size = [MainScreen bounds].size;
    CGFloat scale = [MainScreen scale];
    CGFloat screenWidth = Size.width * scale;
    CGFloat screenHeight = Size.height * scale;
    
    return [NSString stringWithFormat:@"%d*%d",(int)screenWidth,(int)screenHeight];
}

+ (BOOL)isJailbroken
{
    
    //If the app is running on the simulator
#if TARGET_IPHONE_SIMULATOR
    return NO;
    
    //If its running on an actual device
#else
    BOOL isJailbroken = NO;
    
    //This line checks for the existence of Cydia
    BOOL cydiaInstalled = [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"];
    
    FILE *f = fopen("/bin/bash", "r");
    
    if (!(errno == ENOENT) || cydiaInstalled) {
        
        //Device is jailbroken
        isJailbroken = YES;
    }
    fclose(f);
    return isJailbroken;
#endif
}
@end
