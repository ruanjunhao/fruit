//
//  weixinShare.m
//  CHSP
//
//  Created by jhyu on 13-11-5.
//
//

#import "weixinShare.h"
#import "ShareMgr.h"

const CGFloat wxThumbImagePixes = 99.0f;

@implementation weixinShare

- (BOOL)isWeixinAvailable
{
    return [WXApi isWXAppInstalled];
}

- (BOOL)isWeixinGroupAvailable
{
    return ([self isWeixinAvailable] && [WXApi isWXAppSupportApi]);
}

- (id)initWithAppKey:(NSString *)appKey
{
    self = [super init];
    if(self) {
        BOOL ret = [WXApi registerApp:appKey];
        if(!ret) {
            return nil;
        }
    }
    
    return self;
}

- (BOOL)shareWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image url:(NSString *)url isGroupShare:(BOOL)isGroupShare
{
    WXMediaMessage * message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    if(image) {
        UIImage * thumbImage = image;
        if(image.size.width > wxThumbImagePixes || image.size.height > wxThumbImagePixes) {
            thumbImage = [self scaledThumbImage:thumbImage];
        }
        [message setThumbImage:thumbImage];
    }

    id webUrl = url;
    if([[NSURL URLWithString:webUrl] scheme].length > 0) {
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = webUrl;
        message.mediaObject = ext;
    }
    
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
    req.message = message;
    if(isGroupShare) {
        req.scene = WXSceneTimeline;
    }
    else {
        req.scene = WXSceneSession;
    }
    
    if(image || webUrl) {
        req.bText = NO;
    }
    else {
        req.bText = YES;
        req.text = description;
    }
    
    BOOL ret = [WXApi sendReq:req];
    return ret;
}

- (UIImage *)scaledThumbImage:(UIImage *)normalImage
{
    UIImage * thumbImage = normalImage;
    if(thumbImage) {
        CGSize newSize = CGSizeMake(wxThumbImagePixes, wxThumbImagePixes);
        UIGraphicsBeginImageContext(newSize);
        CGRect rect = CGRectZero;
        rect.size = newSize;
        [thumbImage drawInRect:rect];
        thumbImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return thumbImage;
}

#pragma mark -- WXApiDelegate

- (void)onResp:(BaseResp*)resp
{
    // 微信Response back.
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        EShareResult eResult = EShareUndefined;
        
        if(resp.errCode == 0) {
            eResult = EShareSuccess;
        }
        else if(resp.errCode == WXErrCodeUserCancel){
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