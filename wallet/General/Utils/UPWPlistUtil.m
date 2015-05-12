//
//  UPXPlistUtils.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-5-22.
//
//

#import "UPWPlistUtil.h"
#import "UPWPathUtil.h"
#import "NSDictionary+UPEx.h"


static UPWPlistUtil* localizedPlistInstance = nil;
static UPWPlistUtil* publicPayPlistInstance = nil;
static UPWPlistUtil* syncRemindDaysPlistInstance = nil;
static UPWPlistUtil* syncBillHistoryPlistInstance = nil;
static UPWPlistUtil* userMessagesPlistInstance = nil;
static UPWPlistUtil* userInfoPlistInstance = nil;
static UPWPlistUtil* uploadInfoPlistInstance = nil;

@interface UPWPlistUtil()
@property(nonatomic, retain)NSMutableDictionary* plistDict;
@property(nonatomic, copy)NSString* plistPath;

+(instancetype) localizedPlistInstance;
- (id)initWithPlistPath:(NSString*)path;

@end


@implementation UPWPlistUtil

@synthesize plistDict = plistDict_ ;
@synthesize plistPath = plistPath_ ;

#pragma mark- Private Method

+ (instancetype)localizedPlistInstance
{
	if (localizedPlistInstance == nil){
		NSString* path   = [UPWPathUtil localizedPlistPath];
		localizedPlistInstance = [[UPWPlistUtil alloc] initWithPlistPath:path];
	}
	return localizedPlistInstance;
}

+ (instancetype)publicPayPlistCache
{
    if (publicPayPlistInstance == nil){
        NSString* path   = [UPWPathUtil publicPayPlistPath];
        publicPayPlistInstance = [[UPWPlistUtil alloc] initWithPlistPath:path];
    }
    return publicPayPlistInstance;
}

+ (instancetype)syncRemindDaysPlistInstance
{
	if (syncRemindDaysPlistInstance == nil){
		NSString* path   = [UPWPathUtil syncRemindDaysPlistPath];
		syncRemindDaysPlistInstance = [[UPWPlistUtil alloc] initWithPlistPath:path];
	}
	return syncRemindDaysPlistInstance;
}

+ (instancetype)syncBillHistoryPlistInstance
{
	if (syncBillHistoryPlistInstance == nil){
		NSString* path   = [UPWPathUtil syncBillHistoryPlistPath];
		syncBillHistoryPlistInstance = [[UPWPlistUtil alloc] initWithPlistPath:path];
	}
	return syncBillHistoryPlistInstance;
}

+ (instancetype)userMessagesPlistInstance
{
	if (userMessagesPlistInstance == nil){
		NSString* path   = [UPWPathUtil userMessagePlistPath];
		userMessagesPlistInstance = [[UPWPlistUtil alloc] initWithPlistPath:path];
	}
	return userMessagesPlistInstance;
}



+ (instancetype)uploadInfoPlistInstance
{
    if (uploadInfoPlistInstance == nil) {
        NSString * path = [UPWPathUtil uploadInfoPlistPath];
        uploadInfoPlistInstance = [[UPWPlistUtil alloc] initWithPlistPath:path];
    }
    return uploadInfoPlistInstance;
}



- (id)initWithPlistPath:(NSString*)path
{
	self = [super init];
	if (self)
	{
		plistDict_ = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
		if (plistDict_==nil)
		{
			plistDict_ = [[NSMutableDictionary alloc] initWithCapacity:0];
		}
		self.plistPath = path;
	}
	return self;
}



#pragma mark - Public Method


+ (instancetype)plistWithType:(PlistType)type
{
	UPWPlistUtil* instance = nil;
	switch (type)
	{
		case kPlistTypeLocalization:
			instance = [self localizedPlistInstance];
			break;
        case kPlistTypePublicPayCache:
            instance = [self publicPayPlistCache];
            break;
        case kPlistTypeSyncRemindDays:
            instance = [self syncRemindDaysPlistInstance];
            break;
        case kPlistTypeSyncBillHistory:
            instance = [self syncBillHistoryPlistInstance];
            break;
        case kPlistTypeUserMessages:
            instance = [self userMessagesPlistInstance];
            break;
        case kPlistTypeUploadInfo:
            instance = [self uploadInfoPlistInstance];
            break;
		default:
			break;
	}
	return instance;
}

+ (void)releasePlist:(PlistType)type
{
	switch (type)
	{
		case kPlistTypeLocalization:
			localizedPlistInstance = nil;
			break;
        case kPlistTypeSyncRemindDays:
            syncRemindDaysPlistInstance = nil;
            break;
        case kPlistTypeSyncBillHistory:
            syncBillHistoryPlistInstance = nil;
            break;
        case kPlistTypeUserMessages:
            userMessagesPlistInstance = nil;
            break;
        case kPlistTypeUploadInfo:
            uploadInfoPlistInstance = nil;
            break;
		default:
			break;
	}
}

+ (instancetype)reloadPlistWithType:(PlistType)type
{
	[UPWPlistUtil releasePlist:type];
	return [UPWPlistUtil plistWithType:type];
}

+ (void)removePlistWithType:(PlistType)type
{
    [self releasePlist:type];
    NSString* filePath = nil;
	switch (type)
	{
		case kPlistTypeLocalization:
             filePath = [UPWPathUtil localizedPlistPath];
			break;
        case kPlistTypeSyncRemindDays:
            filePath = [UPWPathUtil syncRemindDaysPlistPath];
            break;
        case kPlistTypeSyncBillHistory:
            filePath = [UPWPathUtil syncBillHistoryPlistPath];
            break;
        case kPlistTypeUserMessages:
            filePath = [UPWPathUtil userMessagePlistPath];
            break;
        case kPlistTypeUploadInfo:
            filePath = [UPWPathUtil uploadInfoPlistPath];
            break;
		default:
			break;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError* error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error) {
            UPDERROR(@"removePlistWithType error = %@, path = %@",[error localizedDescription],filePath );
        }
    }
}


- (NSUInteger)count
{
    return [plistDict_ count];
}


-(NSString *)description
{
    NSMutableString* string = [NSMutableString string];
    [string appendFormat:@"<UPXPlistUtils %p> \n(%@)\n",self,[[plistPath_ pathComponents] lastObject]];
    [string appendFormat:@"%@",[plistDict_ description]];
    return string;
}


-(id)objectForKey:(NSString*)key
{
	return [plistDict_ objectForKey:key];
}

- (void)setObject:(id)object forKey:(NSString*)key
{
	[plistDict_ setObject:object forKey:key];
}

- (NSString *)stringForKey:(NSString *)key
{
	NSString* str = [plistDict_ objectForKey:key];
	return str;
}

- (NSArray *)arrayForKey:(NSString *)key
{
	NSArray* arr = [plistDict_ objectForKey:key];
	return arr;
}
- (NSDictionary *)dictionaryForKey:(NSString *)key
{
	NSDictionary* dict = [plistDict_ objectForKey:key];
	return dict;
}

- (NSInteger)integerForKey:(NSString *)key
{
	return [[plistDict_ objectForKey:key] integerValue];
}

- (float)floatForKey:(NSString *)key
{
	return [[plistDict_ objectForKey:key] floatValue];
}

- (BOOL)boolForKey:(NSString *)key
{
	return [[plistDict_ objectForKey:key] boolValue];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key
{
	[plistDict_ setObject:[NSNumber numberWithInteger:value] forKey:key];
}

- (void)setFloat:(float)value forKey:(NSString *)key
{
	[plistDict_ setObject:[NSNumber numberWithFloat:value] forKey:key];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key
{
	[plistDict_ setObject:[NSNumber numberWithBool:value] forKey:key];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    [plistDict_ enumerateKeysAndObjectsUsingBlock:block];
}

- (void)removeObjectsForKeys:(NSArray*)array
{
    [plistDict_ removeObjectsForKeys:array];
}


- (BOOL)synchronize
{
	return [plistDict_ writeToFile_upex:plistPath_ atomically:YES];
}

- (void)removeObjectForKey:(NSString *)key
{
	return [plistDict_ removeObjectForKey:key];
}

@end
