//
//  weiboShare.m
//  CHSP
//
//  Created by jhyu on 13-6-6.
//
//

#import "weiboShare.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "ShareMgr.h"

// ~ https://github.com/sinaweibosdk/weibo_ios_sdk

@interface weiboShare () {
    NSString*   _message;
    NSString*   _url;
    UIImage*    _image;
    
    __weak UIViewController* _topVC;
}
@end

@implementation weiboShare

- (id)initWithAppKey:(NSString *)appKey
{
    self = [super init];
    if(self) {
        BOOL ret = [WeiboSDK registerApp:appKey];
#ifdef DEBUG
        [WeiboSDK enableDebugMode:YES];
#endif
        if(!ret) {
            return nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
}

- (BOOL)isSinaWeiboAvailable
{
    return [[self class] isWeiboAppInstalled] || [weiboShare isSinaWeiboServiceAvailable];
}

- (BOOL)shareWithTopVC:(UIViewController *)topVC message:(NSString *)message url:(NSString *)url image:(UIImage *)image
{
    _topVC = topVC;
    _message = message;
    _url = url;
    _image = image;
    
    if([self shareBySysIntegration]) {
        return YES;
    }
    else {
        if([[self class] isWeiboAppInstalled]) {
            WBMessageObject* obj = [self createMessageObject];
            WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:obj];
            return [WeiboSDK sendRequest:request];
        }
    }
    
    return NO;
}

+ (BOOL)isWeiboAppInstalled
{
    //return YES; // DEBUG
    BOOL ret = [WeiboSDK isWeiboAppInstalled];
    return ret;
}

- (BOOL)shareBySysIntegration
{    
    if([weiboShare isSinaWeiboServiceAvailable]) {
        SLComposeViewController * controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultCancelled) {
                DLog(@"Cancelled");
            }
            else {
                DLog(@"Done");
            }
            
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        
        controller.completionHandler = myBlock;
        
        if(_message) {
            [controller setInitialText:_message];
        }
        
        if(_url) {
            [controller addURL:[NSURL URLWithString:_url]];
        }
        
        if(_image) {
            [controller addImage:_image];
        }
        
        [_topVC presentModalViewController:controller animated:YES];
        
        return YES;
    }
    
    return NO;
}

+ (BOOL)isSinaWeiboServiceAvailable
{
    return NSClassFromString(@"SLComposeViewController") && [SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo];
}

- (WBMessageObject *)createMessageObject
{
    WBMessageObject* message = [WBMessageObject message];
    message.text = _message;
    if(_image) {
        message.imageObject = [WBImageObject object];
        NSData* data = UIImagePNGRepresentation(_image);
        if (!data) {
            data = UIImageJPEGRepresentation(_image, (CGFloat)1.0);
        }
        
        message.imageObject.imageData = data;
    }
    
    // Ignore url current now.
    
    return message;
}

#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        EShareResult eResult = EShareUndefined;
        
        if(response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            eResult = EShareSuccess;
        }
        else if(response.statusCode == WeiboSDKResponseStatusCodeUserCancel){
            eResult = EShareCancelled;
        }
        else {
            eResult = EShareFailed;
        }
        
        // 通知上层APP分享结果。
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShareResult object:nil userInfo:@{kResultCode:@(eResult)}];
    }
}

@end
