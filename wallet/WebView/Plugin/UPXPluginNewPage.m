//
//  UPXPluginNewPage.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-9-10.
//
//

#import "UPXPluginNewPage.h"
#import "UPWWebViewController.h"
#import "UPXUtils.h"

@implementation UPXPluginNewPage

@synthesize callbackId;

#pragma mark -
#pragma mark 加载一个UPWebAppViewController，其中包含新的UIWebView

- (void)createWebPage:(CDVInvokedUrlCommand*)command
{
    UPDSTART();
    NSString* arg = [command.arguments firstObject];
    UPDINFO(@"arg %@",arg);
    NSDictionary *params = [UPXUtils dictionaryFromCordovaArgument:arg];
    if (params) {
        UPWWebViewController* viewController = [[UPWWebViewController alloc] init];
        viewController.isLoadingView = [[params[@"loading"] lowercaseString] isEqualToString:@"yes"];
        viewController.isWaitingView = [[params[@"waiting"] lowercaseString] isEqualToString:@"yes"];
        viewController.hasToolbar = [[params[@"toolbar"] lowercaseString] isEqualToString:@"yes"];
        viewController.title = params[@"title"];
        viewController.startPage = params[@"url"];
        UPDINFO(@"createWebPage %@",params);
        // 多加一层保护，先判断self.viewController 是不是UPWWebViewController
        if ([self.viewController isKindOfClass:[UPWWebViewController class]]) {
            viewController.webAppHolder = ((UPWWebViewController *)self.viewController).webAppHolder;
            viewController.appInfo = ((UPWWebViewController *)self.viewController).appInfo;
            viewController.authPlugins = ((UPWWebViewController *)self.viewController).authPlugins;
        }else {
            viewController.webAppHolder = self.viewController;
        }
        
        [self.viewController.navigationController pushViewController:viewController animated:YES];
    }

    UPDEND();
}
@end
