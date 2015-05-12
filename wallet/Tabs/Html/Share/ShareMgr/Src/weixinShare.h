//
//  weixinShare.h
//  CHSP
//
//  Created by jhyu on 13-11-5.
//
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface weixinShare : NSObject <WXApiDelegate>

- (id)initWithAppKey:(NSString *)appKey;
- (BOOL)isWeixinAvailable;
- (BOOL)isWeixinGroupAvailable;
- (BOOL)shareWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image url:(NSString *)url isGroupShare:(BOOL)isGroupShare;

@end
