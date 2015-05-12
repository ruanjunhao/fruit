//
//  UPHistoryView.h
//  UPWallet
//
//  Created by wxzhao on 14-7-12.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPWTabelViewSearchCell : UITableViewCell

@end

@class UPWHistoryView;

@protocol UPWHistoryViewDelegate <NSObject>

- (void)didSelectString:(NSString*)string;
- (void)historyViewWillBeginDragging:(UPWHistoryView *)view;

@end

@interface UPWHistoryView : UIView

@property(nonatomic,weak)id<UPWHistoryViewDelegate> delegate;

- (void)saveSearchString:(NSString*)searchString;
- (void)filterKeyword:(NSString*)keyword;

- (void)showHistoryView:(BOOL)show;
- (void)showFilterView:(BOOL)show;

@end
