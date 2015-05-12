//
//  UPWebAppAlertViewDelegate.h
//  UPClientV3
//
//  Created by wxzhao on 13-4-23.
//
//

#import <Foundation/Foundation.h>

@protocol UPWWebAppAlertViewDelegate <NSObject>

- (void)buttonOKClicked:(NSInteger) tag;
- (void)buttonCancelClicked:(NSInteger) tag;

@end
