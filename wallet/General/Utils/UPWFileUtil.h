//
//  UPWFileUtil.h
//  wallet
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-30.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPWFileUtil : NSObject

+ (NSString*)UTF8Encode:(id)obj;

+ (id)UTF8Decode:(NSString*)utf8String;

+ (void)writeContent:(id)content path:(NSString*)path;

+ (id)readContent:(NSString*)path;

+ (void)removeFile:(NSString *)path;


@end
