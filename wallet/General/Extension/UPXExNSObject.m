//
//  UPExNSObject.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-10-17.
//
//

#import "UPXExNSObject.h"

@implementation NSObject (UPXExtensions)

+ (BOOL)swizzleMethod:(SEL)origSel withMethod:(SEL)altSel
{
    Method origMethod = class_getInstanceMethod(self, origSel);
    if (!origSel) {
        //UPDINFO(@"original method %@ not found for class %@", NSStringFromSelector(origSel), [self class]);
        return NO;
    }
    
    Method altMethod = class_getInstanceMethod(self, altSel);
    if (!altMethod) {
        //UPDINFO(@"original method %@ not found for class %@", NSStringFromSelector(altSel), [self class]);
        return NO;
    }
    
    class_addMethod(self,
                    origSel,
                    class_getMethodImplementation(self, origSel),
                    method_getTypeEncoding(origMethod));
    class_addMethod(self,
                    altSel,
                    class_getMethodImplementation(self, altSel),
                    method_getTypeEncoding(altMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, origSel), class_getInstanceMethod(self, altSel));
    
    return YES;
}

+ (BOOL)swizzleClassMethod:(SEL)origSel withClassMethod:(SEL)altSel
{
    Class c = object_getClass((id)self);
    return [c swizzleMethod:origSel withMethod:altSel];
}

@end