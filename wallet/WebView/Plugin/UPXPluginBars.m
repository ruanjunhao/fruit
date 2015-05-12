//
//  UPXPluginBars.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-10-9.
//
//

#import "UPXPluginBars.h"
#import "UPWWebViewController.h"
#import "UPXUtils.h"


@implementation UPXPluginBars

- (void)setBarStatus:(CDVInvokedUrlCommand *)command
{
//    UPDSTART();
    NSString* arg = [command.arguments firstObject];
    UPDINFO(@"arg %@",arg);
    
    NSDictionary *params = [UPXUtils dictionaryFromCordovaArgument:arg];
    BOOL hideNavigationBar = NO;
    BOOL hideToolBar = NO;
    if (params) {
        hideNavigationBar = [params[@"shownavigationbar"] isEqualToString:@"no"];
        hideToolBar = [params[@"showtoolbar"] isEqualToString:@"no"];
    }
    UPWWebViewController* viewController = (UPWWebViewController*) self.viewController;
    
    [viewController setNavigationBarHidden:hideNavigationBar toolBarHidden:hideToolBar];
//    UPDEND();
}

- (void)setNavigationBarTitle:(CDVInvokedUrlCommand *)command
{
//    UPDSTART();
    NSString* arg = [command.arguments firstObject];
    UPDINFO(@"arg %@",arg);
    
    if (arg) {
    }
    UPWWebViewController* viewController = (UPWWebViewController*) self.viewController;
    [viewController setNaviTitle:arg];
    
//    UPDEND();
}

@end
