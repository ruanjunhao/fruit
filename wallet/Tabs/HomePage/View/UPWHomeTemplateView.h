//
//  UPWHomeTemplateView.h
//  wallet
//
//  Created by gcwang on 15/3/11.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UPWHomeTemplateView;

@protocol UPWHomeTemplateViewDataSource <NSObject>

- (NSString *)nameForHomeTemplateView:(UPWHomeTemplateView*)templateView;
- (NSInteger)countOfCellForHomeTemplateView:(UPWHomeTemplateView*)templateView;
- (UIView*)homeTemplateView:(UPWHomeTemplateView*)templateView cellAtIndex:(NSInteger)index;

@end

@protocol UPWHomeTemplateViewDelegate <NSObject>

- (void)homeTemplateView:(UPWHomeTemplateView *)templateView didSelectMore:(id)sender;
- (void)homeTemplateView:(UPWHomeTemplateView *)templateView didSelectAtIndex:(NSInteger)index;

@end

@interface UPWHomeTemplateView : UIView

@property (nonatomic, weak) id<UPWHomeTemplateViewDelegate> delegate;
@property (nonatomic, weak) id<UPWHomeTemplateViewDataSource> dataSource;
@property (nonatomic, strong) NSMutableArray *controlArray;

@end
