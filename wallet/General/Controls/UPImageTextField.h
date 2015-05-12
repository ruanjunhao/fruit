//
//  UPImageTextField.h
//  UPWallet
//
//  Created by wxzhao on 14-7-11.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPImageTextField : UITextField

@property(nonatomic,assign) NSInteger lenMin;
@property(nonatomic,assign) NSInteger lenMax;
@property(nonatomic,copy) NSString* alert;

- (void)setLeftImage:(NSString*)imageName;
- (void)setLast:(BOOL)last;

- (NSString*)validFormat:(NSString*)text;

@end
