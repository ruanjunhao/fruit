//
//  UPXBanner.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-9-27.
//
//

#import <UIKit/UIKit.h>


typedef void (^UPXNotificationBannerTapHandlingBlock)();

@interface UPXNotificationCenter : NSObject

+ (void)presentNotificationWithTitle:(NSString*)title
                              image:(UIImage*)image
                           tapHandler:(UPXNotificationBannerTapHandlingBlock)tapHandler;

@end

