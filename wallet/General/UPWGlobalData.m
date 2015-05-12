//
//  UPWGlobalData.m
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-28.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWGlobalData.h"

#define kUDKeyVirtualID       @"virtualID_400"
#define kDefaultVirtualID   @"0000"

@interface UPWGlobalData()
{
    NSString* _virtualID;//virtual ID

}

@end

@implementation UPWGlobalData



+ (UPWGlobalData*)sharedData
{
    static UPWGlobalData* sharedData = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedData = [[self alloc] init];
    });
    
    return sharedData;
}


- (id)init
{
    self = [super init];
    if (self) {
        
        _allAppInfo = [[NSMutableDictionary alloc] init];
 
    }
    return self;
}

- (void)dealloc
{

}

- (void)setVirtualID:(NSString *)virtualID
{
    if (![virtualID isEqual:_virtualID]) {
        _virtualID = [virtualID copy];
        if (virtualID) {
            //如果为空不保存
            [[NSUserDefaults standardUserDefaults] setValue:virtualID forKey:kUDKeyVirtualID];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (NSString*)virtualID
{
    if (!_virtualID) {
        //如果为空从文件中取
        _virtualID = [[NSUserDefaults standardUserDefaults] valueForKey:kUDKeyVirtualID];
        //如果为空,填默认值
        if (!_virtualID) {
            _virtualID = kDefaultVirtualID;
        }
    }
    return _virtualID;
}



@end
