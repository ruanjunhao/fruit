//
//  UPXExNSObject.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-10-17.
//
//

#import <objc/runtime.h>
#import <objc/message.h>

@interface NSObject (UPXExtensions)

+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel;
+ (BOOL)swizzleClassMethod:(SEL)origSel withClassMethod:(SEL)altSel;

@end
