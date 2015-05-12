//
//  weiboShare.h
//  CHSP
//
//  Created by jhyu on 13-6-6.
//
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"

@interface weiboShare : NSObject <WeiboSDKDelegate>

- (id)initWithAppKey:(NSString *)appKey;
- (BOOL)isSinaWeiboAvailable;
- (BOOL)shareWithTopVC:(UIViewController *)topVC message:(NSString *)message url:(NSString *)url image:(UIImage *)image;

@end
