//
//  UPExNSDictionary.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-5-22.
//
//

#import <UIKit/UIKit.h>


@interface NSDictionary (UPXExtensions)
- (BOOL)boolForKey_upex:(NSString *)keyName;
- (float)floatForKey_upex_st:(NSString *)keyName;      //跟分辨率无关
- (float)floatForKey_upex:(NSString *)keyName;        //跟分辨率有关
- (CGSize)sizeForKey_upex:(NSString *)keyName;        //跟分辨率有关
- (CGRect)rectForKey_upex:(NSString *)keyName;        //跟分辨率有关
- (CGRect)rectForKey_upexTheme:(NSString *)keyName;   //跟分辨率无关
- (CGPoint)pointForKey_upex:(NSString *)keyName;      //跟分辨率有关
- (NSInteger)integerForKey_upex:(NSString *)keyName;
- (NSString *)stringForKey_upex:(NSString *)keyName;
- (NSDictionary *)dictionaryForKey_upex:(NSString *)keyName;
-(void)setBool_upex:(BOOL)value forKey:(NSString*)keyName;
-(void)setInteger_upex:(NSInteger)value forKey:(NSString*)keyName;
- (BOOL)writeToFile_upex:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
@end
