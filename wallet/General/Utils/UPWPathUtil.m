//
//  UPXPathUtils.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-5-22.
//
//

#import "UPWPathUtil.h"
#import "NSString+MKNetworkKitAdditions.h"

@implementation UPWPathUtil


+ (NSString*)documentDirectory
{
    static NSString *documentPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    });
    return documentPath;
}

+ (void)createDirectoryIfNotExist:(NSString *)fullPath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}


+ (NSString*)defaultLocalizedPlistPath
{
    static NSString *defaultLocalizedPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        defaultLocalizedPlistPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"UPWDefaultLocalize.plist"];
        
    });
    return defaultLocalizedPlistPath;
}



+ (void)createDefaultLocalizedPlistIfNotExist:(NSString*) fullPath
{
    UPDSTART();
    NSError* error = nil;
    BOOL suc = NO;
#ifndef UP_BUILD_FOR_DEVELOP
    if (!UP_FILEEXIST(fullPath))
    {
        suc =  [[NSFileManager defaultManager] copyItemAtPath:[self defaultLocalizedPlistPath] toPath:fullPath error:&error];
    }
    else
    {
        NSDictionary* newFile = [NSDictionary dictionaryWithContentsOfFile:[self defaultLocalizedPlistPath]];
        NSString* newVer = [newFile objectForKey:@"LocalPlist_Version"];
        
        NSDictionary* existFile = [NSDictionary dictionaryWithContentsOfFile:fullPath];
        NSString* existVer = [existFile objectForKey:@"LocalPlist_Version"];
        
        if ( [newVer integerValue] > [existVer integerValue] )
        {
            [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
            suc = [[NSFileManager defaultManager] copyItemAtPath:[self defaultLocalizedPlistPath]
                                                          toPath:fullPath error:&error];
        }
    }
    
#else
#warning 先用本地测试, 保证plist每次删掉可以更新有效
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
    }
    
    suc = [[NSFileManager defaultManager] copyItemAtPath:[self defaultLocalizedPlistPath]
                                                  toPath:fullPath error:&error];
#endif
    
    if (!suc || error != nil) {
        UPDERROR(@"createDefaultLocalizedPlistIfNotExist failed: %s", [[error localizedDescription] UTF8String]);
    }
    UPDEND();
}

+ (NSString*)localizedPlistPath
{
    static NSString *localizedPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        localizedPlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWLocalstrings.plist"];
        [self createDefaultLocalizedPlistIfNotExist:localizedPlistPath];
        
    });
    return localizedPlistPath;
}


+ (NSString*)publicPayPlistPath {
    
    static NSString *publicPayPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        publicPayPlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWPublicPayCache.plist"];
        [self createDefaultLocalizedPlistIfNotExist:publicPayPlistPath];
        
    });
    return publicPayPlistPath;
    
}

+ (NSString*)syncRemindDaysPlistPath
{
    static NSString *syncRemindDaysPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        syncRemindDaysPlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWSyncRemindDays.plist"];
    });
    return syncRemindDaysPlistPath;
}


+ (NSString*)syncBillHistoryPlistPath
{
    static NSString *syncBillHistoryPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        syncBillHistoryPlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWSyncBillHistory.plist"];
    });
    return syncBillHistoryPlistPath;
}




+ (NSString*)uploadInfoPlistPath
{
    static NSString * uploadInfoPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uploadInfoPlistPath =
        [[self documentDirectory]
         stringByAppendingPathComponent:@"UPWUploadInfo.plist"];
    });
    return uploadInfoPlistPath;
}



//全App info文件
+ (NSString*)allAppInfoPlistPath{
    static NSString * allAppInfoPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allAppInfoPlistPath =
        [[self documentDirectory]
         stringByAppendingPathComponent:@"UPWAllAppInfoPlistPath.plist"];
    });
    return allAppInfoPlistPath;
}


//系统初始化
+ (NSString*)sysInitCachePath
{
    static NSString * sysInitPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sysInitPlistPath =
        [[self documentDirectory]
         stringByAppendingPathComponent:@"UPWSysInit.plist"];
    });
    return sysInitPlistPath;
}



//城市列表
+ (NSString*)cityListCachePath
{
    static NSString * cityListPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cityListPlistPath =
        [[self documentDirectory]
         stringByAppendingPathComponent:@"UPWSupportCityList.plist"];
    });
    return cityListPlistPath;
}

//KV 图, 热门 app, 秒杀图
+ (NSString*)imgHotSecKillCachePath
{
    static NSString * featuredPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        featuredPlistPath =
        [[self documentDirectory]
         stringByAppendingPathComponent:@"UPWImgHotSecKill.plist"];
    });
    return featuredPlistPath;
}


//精选推荐
+ (NSString*)hotBillListCachePath
{
    static NSString * hotBillListPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hotBillListPlistPath =
        [[self documentDirectory]
         stringByAppendingPathComponent:@"UPWHotBillList.plist"];
    });
    return hotBillListPlistPath;
}

//生活 KV 图
+ (NSString*)lifeImageListCachePath
{
    static NSString * lifeImageListPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lifeImageListPlistPath =
        [[self documentDirectory]
         stringByAppendingPathComponent:@"UPWLifeImageList.plist"];
    });
    return lifeImageListPlistPath;
}


//卡包演示卡数据
+ (NSString*)demoCardListPath
{
    static NSString * demoCardListPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        demoCardListPlistPath =
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"UPWDemoCards.plist"];
    });
    return demoCardListPlistPath;
}


//卡片详情格式
+ (NSString*)cardDetailFormatPath
{
    static NSString * cardDetailFormatPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cardDetailFormatPlistPath =
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"UPWCardDetailFormat.plist"];
    });
    return cardDetailFormatPlistPath;
}





//添加银行卡证件类型
+ (NSString*)certTypePlistPath
{
    static NSString * certTypePlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        certTypePlistPath =
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"UPWCertTypes.plist"];
    });
    return certTypePlistPath;
}

//默认城市
+ (NSString*)defaultCityPlistPath
{
    static NSString * defaultCityPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCityPlistPath =
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"UPWDefaultCity.plist"];
    });
    return defaultCityPlistPath;
}


//默认appInfo
+ (NSString*)defaultAppInfoPlistPath
{
    static NSString * defaultAppInfoPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultAppInfoPlistPath =
        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"UPWDefaultAppInfo.plist"];
    });
    return defaultAppInfoPlistPath;
}



//显示在生活的 app
+ (NSString*)appInfoPlistPath
{
    static NSString * appInfoPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appInfoPlistPath =
        [[self documentDirectory]
         stringByAppendingPathComponent:@"UPWAppInfo.plist"];
    });
    return appInfoPlistPath;
}


#pragma mark - 用户相关的文件


+ (NSString*)allUserDirectoryPath
{
    NSString * allUserDirectoryPath = nil;
    allUserDirectoryPath = [[self documentDirectory] stringByAppendingPathComponent:@"User"];
    [self createDirectoryIfNotExist:allUserDirectoryPath];
    return allUserDirectoryPath;
}

+ (NSString*)userDirectoryPath:(NSString*)userID
{
    NSString * userDirectoryPath = nil;
    userDirectoryPath = [[self allUserDirectoryPath] stringByAppendingPathComponent:[userID md5]];
    [self createDirectoryIfNotExist:userDirectoryPath];
    return userDirectoryPath;
}


//已绑定卡数据, 用在信用卡还款中
+ (NSString*)cardListCachePath:(NSString*)userID
{
    NSString * cardListPlistPath = nil;
    cardListPlistPath = [[self userDirectoryPath:userID] stringByAppendingPathComponent:@"UPWCardList.plist"];
    return cardListPlistPath;
}


//设置过手势密码用户的随机字符串
+ (NSString*)userPatternRandomStringPlistPath{
    static NSString * userPatternRandomStringPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userPatternRandomStringPlistPath =
        [[self documentDirectory]
         stringByAppendingPathComponent:@"UPWUserPatternRandomStringPlistPath.plist"];
    });
    return userPatternRandomStringPlistPath;
}


+ (NSString*)userMessagePlistPath
{
    static NSString *userMessagePlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userMessagePlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWUserMessage.plist"];
    });
    return userMessagePlistPath;
}

+ (NSString*)userInfoPlistPath
{
    static NSString *userInfoPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userInfoPlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWUserInfo.plist"] ;
    });
    return userInfoPlistPath;
}

#pragma mark - 根据folder拼网络图片URL

+ (NSURL*)urlWithFolder:(NSString*)folder withURL:(NSString*)org
{
    if (UP_IS_NIL(org) || UP_IS_NIL(folder)) {
        return nil;
    }
    NSString* last = [org lastPathComponent];
    NSMutableString* tmp = [NSMutableString stringWithString:org];
    [tmp deleteCharactersInRange:NSMakeRange([org length] - [last length], [last length])];
    NSString* urlString = [NSString stringWithFormat:@"%@%@/%@",tmp,folder,last];
    return [NSURL URLWithString:urlString];
}

#pragma mark -
#pragma mark - 彩虹果
+ (NSString *)wheelImageListPlistPath
{
    static NSString *wheelImageListPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wheelImageListPlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWWheelImageList.plist"] ;
    });
    return wheelImageListPlistPath;
}

+ (NSString *)catagoryListPlistPath
{
    static NSString *catagoryListPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        catagoryListPlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWCatagoryList.plist"] ;
    });
    return catagoryListPlistPath;
}

+ (NSString *)freshFruitListPlistPath
{
    static NSString *freshFruitListPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        freshFruitListPlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWFreshFruitList.plist"] ;
    });
    return freshFruitListPlistPath;
}

+ (NSString *)fruitCutListPlistPath
{
    static NSString *fruitCutListPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fruitCutListPlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWFruitCutList.plist"] ;
    });
    return fruitCutListPlistPath;
}

+ (NSString *)fruitJuiceListPlistPath
{
    static NSString *fruitJuiceListPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fruitJuiceListPlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWFruitJuiceList.plist"] ;
    });
    return fruitJuiceListPlistPath;
}

+ (NSString*)accountInfoPlistPath
{
    static NSString *accountInfoPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        accountInfoPlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWAccountInfo.plist"] ;
    });
    return accountInfoPlistPath;
}

+ (NSString*)shoppingCartPlistPath
{
    static NSString *shoppingCartPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shoppingCartPlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWShoppingCart.plist"] ;
    });
    return shoppingCartPlistPath;
}

+ (NSString*)deliveryAddrPlistPath
{
    static NSString *deliveryAddrPlistPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deliveryAddrPlistPath =  [[self documentDirectory] stringByAppendingPathComponent:@"UPWDeliveryAddr.plist"] ;
    });
    return deliveryAddrPlistPath;
}

@end
