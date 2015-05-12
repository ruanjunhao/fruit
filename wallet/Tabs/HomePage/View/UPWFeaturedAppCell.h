//
//  UPBusiGridViewCell.h
//  UPWallet
//
//  Created by wxzhao on 14-7-16.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPWCatagoryListModel.h"

#define kHotAppWidth  50
#define kHotAppHeight 100

@interface UPWFeaturedAppCell : UIView

- (void)setCellModel:(UPWCatagoryCellModel*)model;

- (void)setCellModelWithImage:(UIImage *)image text:(NSString *)text;

@end
