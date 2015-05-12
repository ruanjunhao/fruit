//
//  UPLightGridView.h
//  UPWallet
//
//  Created by wxzhao on 14-6-7.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UPWLightGridView;

@protocol UPWLightGridViewDataSource <NSObject>

- (NSInteger)countOfCellForLightGridView:(UPWLightGridView*)gridView;
- (NSInteger)columnNumberForLightGridView:(UPWLightGridView*)gridView;
- (CGFloat)borderMarginForLightGridView:(UPWLightGridView*)gridView;
- (CGFloat)innerMarginForLightGridView:(UPWLightGridView*)gridView;
- (CGSize)itemSizeForLightGridView:(UPWLightGridView*)gridView;
//- (UIControl*)lightGridView:(UPWLightGridView*)gridView cellAtIndex:(NSInteger)index;
- (UIView*)lightGridView:(UPWLightGridView*)gridView cellAtIndex:(NSInteger)index;

@end

@protocol UPWLightGridViewDelegate <NSObject>

- (void)lightGridView:(UPWLightGridView*)lightGridView didSelectAtIndex:(NSInteger)index cell:(UIControl *)cell;

@end


@interface UPWLightGridView : UIScrollView

@property(nonatomic,weak)id<UPWLightGridViewDataSource> customDataSource;
@property(nonatomic,weak)id<UPWLightGridViewDelegate> customDelegate;

@end


