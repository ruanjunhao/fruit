//
//  UPXWebAppPayPlugin.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-8-21.
//
//

/**
 返回给 JS端的 参数为一个字典：
 @"step": @"2",     // 表示第几步，目前1代表调起支付控件的过程，2表示进入支付控件并从支付控件返回的过程
 @"result": @"success",    // 表示结果，success表示成功，fail表示失败，cancel表示取消，同支付控件返回的结果
 @"code": @"",      // 表示错误码，主要是在step==1时，网络请求产生的错误码；如果step==2，则code为空字符串
  00 成功，01,cancel ,02 fail, 03 参数错误
 @"message": @""    // 表示错误信息，主要是在step==1时，网络请求错误产生的错误信息；如果step==2，则message为空字符串
 
 错误信息 JS端不需要进行提示，native会自动进行错误提示。
 */
#import "CDVPlugin.h"
#import "UPPayPluginDelegate.h"

@interface UPXPluginPay : CDVPlugin <UPPayPluginDelegate>

@property(nonatomic,copy)NSString* callbackId;
@property(nonatomic,retain) CDVInvokedUrlCommand *command;
- (void)pay:(CDVInvokedUrlCommand *)command;


@end
