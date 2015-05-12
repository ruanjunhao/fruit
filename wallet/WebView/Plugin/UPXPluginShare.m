//
//  UPXPluginShare.m
//  UPClientV3
//
//  Created by lu on 14-3-24.
//
//


#import "UPXPluginShare.h"
//#import "UPXPublicPaySharedViewController.h"
#import "NSData+MKBase64.h"

@implementation UPXPluginShare

#warning 先屏蔽掉分享
- (void)share:(CDVInvokedUrlCommand *)commands{
//    UPXBaseViewController* viewController = (UPXBaseViewController*) self.viewController;
//    UPXPublicPaySharedViewController *controller = [[UPXPublicPaySharedViewController alloc] initWithNibName:nil bundle:nil];
//    controller.isHideSharedBox = YES;
//    NSString *arg = [commands.arguments firstObject];
//    NSDictionary *params = [UPXUtils dictionaryFromCordovaArgument:arg];
//    NSData *imageData = [NSData dataFromBase64String:[params objectForKey:@"shareImg"]];
//    UIImage *image = [UIImage imageWithData:imageData];
//    NSMutableDictionary *mutableArgDic = [[NSMutableDictionary alloc] initWithDictionary:params];
//    [mutableArgDic setObject:image forKey:@"shareImg"];
//    controller.shareParams = mutableArgDic;
////    controller.isAutoPop = NO;
//    controller.poptoController = (UPXBaseViewController*)UP_SHDAT.homeVC;
//
//    [viewController customPushViewController:controller withType:nil subType:nil];

}

@end
