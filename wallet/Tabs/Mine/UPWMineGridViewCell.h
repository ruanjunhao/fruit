//
//  UPMineGridViewCell.h
//  UPWallet
//
//  Created by wxzhao on 14-7-26.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPWMineGridViewCell : UIControl

@property(nonatomic,strong) NSString* imageName;
@property(nonatomic,strong) NSString* title;
@property(nonatomic,strong) NSString* number;
@property(nonatomic,assign) BOOL isRightCell;
@property(nonatomic,assign) BOOL isLastLine;
@property(nonatomic,assign) BOOL hasRedDot; // 是否显示小红点
@end
