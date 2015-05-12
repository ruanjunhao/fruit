//
//  smsShare.h
//  CHSP
//
//  Created by jhyu on 13-6-5.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface smsShare : NSObject <MFMessageComposeViewControllerDelegate>

+ (BOOL)isSmsAvailable;
- (BOOL)shareMessageWithTopVC:(UIViewController *)topVC message:(NSString *)message;

@end
