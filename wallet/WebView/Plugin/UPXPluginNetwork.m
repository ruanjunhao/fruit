//
//  UPXPluginNetwork.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-9-10.
//
//

#import "UPXPluginNetwork.h"
#import "AppDelegate.h"
#import "UPWBaseViewController.h"
#import "UPWMessage.h"
#import "UPWHttpMgr.h"


@implementation UPXPluginNetwork

@synthesize callbackId;

#pragma mark -
#pragma mark POST方式发送消息，处理相关的CallBack

- (void)sendResult:(CDVCommandStatus)status message:(NSString*)msg
{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:status messageAsString:msg];
    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
}


- (void)sendMessage:(CDVInvokedUrlCommand *)command
{
    UPDSTART();
    self.callbackId = command.callbackId;
    
    NSDictionary* dict = [command.arguments firstObject];
    UPDNETMSG(@"html post msg = %@",dict);
    
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        [self sendResult:CDVCommandStatus_ERROR message:@"参数错误"];
        return;
    }
    
    __weak typeof(self) weakSelf = self;

    UPWMessage *message = nil;//[UPWMessage webMessage:dict];
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        
        NSError* error = nil;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:responseJSON
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString  *jsonStr = nil;
        if (error != nil) {
            UPDERROR(@"JSONString error: %@", [error localizedDescription]);
            
        } else {
            jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        [weakSelf sendResult:CDVCommandStatus_OK message:jsonStr];
        
    } fail:^(NSError *error) {
        
        [weakSelf sendResult:CDVCommandStatus_ERROR message:[[error userInfo] objectForKey:NSLocalizedDescriptionKey]];
        
    }];

    UPDEND();
}



@end
