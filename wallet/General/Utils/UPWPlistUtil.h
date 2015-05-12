//
//  UPXPlistUtils.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-5-22.
//
//

#import <Foundation/Foundation.h>

typedef enum {
	kPlistTypeLocalization,
    kPlistTypePublicPayCache,
    kPlistTypeSyncRemindDays,
    kPlistTypeSyncBillHistory,
    kPlistTypeUserMessages,
    kPlistTypeUploadInfo,
    kPlistTypeSyncLocalSettings
}PlistType;

@interface UPWPlistUtil : NSObject
{
	NSMutableDictionary*  plistDict_;
	NSString*			  plistPath_;
}


+ (instancetype)plistWithType:(PlistType)type;
+ (void)releasePlist:(PlistType)type;
+ (instancetype)reloadPlistWithType:(PlistType)type;
+ (void)removePlistWithType:(PlistType)type;
- (id)initWithPlistPath:(NSString*)path;
- (id)objectForKey:(NSString*)key;
- (void)setObject:(id)object forKey:(NSString*)key;
- (BOOL)synchronize;

- (NSUInteger)count;
- (NSString *)stringForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key;
- (NSDictionary *)dictionaryForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (void)setInteger:(NSInteger)value forKey:(NSString *)key;
- (void)setFloat:(float)value forKey:(NSString *)key;
- (void)setBool:(BOOL)value forKey:(NSString *)key;
- (void)removeObjectsForKeys:(NSArray*)array;
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block;

- (void)removeObjectForKey:(NSString *)key;


@end
