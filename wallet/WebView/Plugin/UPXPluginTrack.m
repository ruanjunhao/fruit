//
//  UPXPluginTrack.m
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 14-9-15.
//
//

#import "UPXPluginTrack.h"
#import "UPWDataCollectMgr.h"
#import "UPXUtils.h"


@implementation UPXPluginTrack

- (void)logEvent:(CDVInvokedUrlCommand *)command
{
    UPDSTART();
    NSString* par = [command.arguments firstObject];
    
    NSDictionary *dict = [UPXUtils dictionaryFromCordovaArgument:par];
    
    NSString* name = dict[@"name"];
    if (!UP_IS_NIL(name)) {
        NSDictionary* arg = dict[@"data"];
        if (arg && ![arg isEqual:[NSNull null]]) {
            [UPWDataCollectMgr upTrackEvent:name label:nil parameters:arg];
        }
        else{
            [UPWDataCollectMgr upTrackEvent:name];
        }
    }
    
    CDVPluginResult* result =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    UPDEND();
}


- (void)logPageBegin:(CDVInvokedUrlCommand *)command
{
    UPDSTART();
    NSString* par = [command.arguments firstObject];
    NSDictionary *dict = [UPXUtils dictionaryFromCordovaArgument:par];
    if (!UP_IS_NIL(dict[@"name"])) {

        [UPWDataCollectMgr upTrackPageBegin:dict[@"name"]];
        CDVPluginResult* result =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
    else{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
    UPDEND();
}

- (void)logPageEnd:(CDVInvokedUrlCommand *)command
{
    UPDSTART();
    NSString* par = [command.arguments firstObject];
    NSDictionary *dict = [UPXUtils dictionaryFromCordovaArgument:par];
    if (!UP_IS_NIL(dict[@"name"])) {
        [UPWDataCollectMgr upTrackPageEnd:dict[@"name"]];
        CDVPluginResult* result =  [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
    else{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }

    UPDEND();
}
@end
