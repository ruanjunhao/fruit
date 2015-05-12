//
//  UPLinkLabel.h
//  UPWallet
//
//  Created by wxzhao on 14-7-14.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UPWLinkLabel;

@protocol UPWLinkLabelDelegate <NSObject>

- (void)didSelectLinkLabel:(UPWLinkLabel*)linkLabel content:(NSString*)linkContent;

@end

@interface UPWLinkLabel : UIView

@property(nonatomic,copy)NSString* text;
@property(nonatomic,copy)NSString* linkText;
@property(nonatomic,copy)NSString* linkContent;
@property(nonatomic,assign)BOOL textCenter;

@property(nonatomic,weak)id<UPWLinkLabelDelegate> deleagate;

@end
