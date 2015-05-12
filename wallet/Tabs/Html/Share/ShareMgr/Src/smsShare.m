//
//  smsShare.m
//  CHSP
//
//  Created by jhyu on 13-6-5.
//
//

#import "smsShare.h"

@interface smsShare () {
     __weak UIViewController*  _topVC;
}
@end

@implementation smsShare

+ (BOOL)isSmsAvailable
{
    return [MFMessageComposeViewController canSendText];
}

- (BOOL)shareMessageWithTopVC:(UIViewController *)topVC message:(NSString *)message
{
    if (NO == [[self class] isSmsAvailable]){
        // eg: iPad.
        return NO;
    }
    
    _topVC = topVC;
    
    MFMessageComposeViewController* vc = [[MFMessageComposeViewController alloc] init];
    vc.messageComposeDelegate = self;
    [vc setBody:message];
    [_topVC presentModalViewController:vc animated:YES];
    
    return YES;
}

#pragma mark -
#pragma mark MFMessageComposeViewControllerDelegate

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [_topVC dismissModalViewControllerAnimated:YES];
}

@end
