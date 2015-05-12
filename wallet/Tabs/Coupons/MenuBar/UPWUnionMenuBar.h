//
//  UPUnionMenuBar.h
//  ttttttestv
//
//  Created by TZ_JSKFZX_CAOQ on 13-11-11.
//  Copyright (c) 2013年 China Unionpay Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMenuBarHeight 42

@class UPWUnionMenuBar, UPWUnionMenuList, UPWUnionMenuButton;

@protocol UPWUnionMenuDelegate <NSObject>

@required

- (NSInteger)unionMenuBar:(UPWUnionMenuBar *)unionMenuBar numberOfRowsAtIndexPath:(NSIndexPath *)indexPath;

- (id)unionMenuBar:(UPWUnionMenuBar *)unionMenuBar dataForItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)unionMenuBar:(UPWUnionMenuBar *)unionMenuBar didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (NSString *)unionMenuBar:(UPWUnionMenuBar *)unionMenuBar leftImageUrlForItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)didSelectUnionMenuButton:(UPWUnionMenuButton *)unionMenuButton;

@end


@interface UPWUnionMenuBar : UIView

@property (assign, nonatomic) id <UPWUnionMenuDelegate> delegate;
@property (retain, nonatomic) UIColor *backgroundColor;
@property (retain, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;
@property (assign, nonatomic) CGFloat arrowSize;
@property (assign, nonatomic) CGFloat arrowHeightFactor;
@property (assign, nonatomic) CFTimeInterval animationDuration;
@property (retain, nonatomic) UIColor *shadowColor;
@property (assign, nonatomic) CGFloat shadowRadius;
@property (assign, nonatomic) CGFloat shadowOpacity;
@property (assign, nonatomic) CGSize shadowOffset;
@property (assign, nonatomic) UIEdgeInsets menuEdgeInsets;
@property (assign, nonatomic) CGRect listRect;
@property (strong, nonatomic) NSArray *listRectArray;
@property (assign, nonatomic) CGRect dimmedBackgroundRect;
@property (strong, nonatomic) NSMutableArray *buttons;
@property (assign, nonatomic) BOOL  buttonInteractionEnabled;


- (void)registerClass:(NSString *)className forIdentifier:(NSString *)identifier;

- (UPWUnionMenuButton *)addMenuButtonWithTitle:(NSString *)title withListIdentifier:(NSString *)listIdentifier forIdentifier:(NSString *)identifier showWordsLength:(NSInteger)length;

- (void)addMenuListForIdentifier:(NSString *)identifier;

- (void)clearSelectedButton;

- (NSArray *)indexPathsForSelectedItems;

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface UPWUnionMenuBarBackground : UIView

@property (assign, nonatomic) CGFloat arrowSize;
@property (assign, nonatomic) CGFloat arrowHeightFactor;
@property (assign, nonatomic) CFTimeInterval animationDuration;

@end


@protocol UPWUnionMenuButtonDelegate <NSObject>

@optional
- (void)didSelectUnionMenuButton:(UPWUnionMenuButton *)unionMenuButton;

@end

@interface UPWUnionMenuButton : UIButton

@property (nonatomic,copy) NSString *listIdentifier;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,assign) BOOL buttonSelected;
@property (nonatomic, assign) NSInteger showWordsLength;
@property (nonatomic, weak) id<UPWUnionMenuButtonDelegate> delegate;

- (void)setButtonTitle:(NSString *)title showWordsLength:(NSInteger)length;

@end


@protocol UPWUnionMenuListDelegate <NSObject>

@required

- (CGRect)unionMenuList:(UPWUnionMenuList *)unionMenuList rectForListInIndex:(NSInteger)index;

- (CGRect)unionMenuList:(UPWUnionMenuList *)unionMenuList rectForDimmedBackgroundInIndex:(NSInteger)index;

- (NSInteger)unionMenuList:(UPWUnionMenuList *)unionMenuList numberOfRowsAtIndexPath:(NSIndexPath *)indexPath;

- (id)unionMenuList:(UPWUnionMenuList *)unionMenuList dataForItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)unionMenuList:(UPWUnionMenuList *)unionMenuList didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (NSString *)unionMenuList:(UPWUnionMenuList *)unionMenuList leftImageUrlForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface UPWUnionMenuList : UIView

@property (nonatomic, unsafe_unretained) UPWUnionMenuBar *menuBar;
@property (nonatomic, unsafe_unretained) UPWUnionMenuButton *button;
@property (nonatomic, assign) CGRect listDisplayRect;
@property (nonatomic, assign) id<UPWUnionMenuListDelegate> delegate;

- (void)willCloseMenuList;
- (void)closeMenuList;
- (void)reloadData;
- (void)selectRowsByItems:(NSSet*)set;
@end

@interface UPWUnionMenuListTableView : UITableView

@end

@interface NSIndexPath (UPWUnionMenuBar)

@property (nonatomic, readonly) NSUInteger upIndex;
@property (nonatomic, readonly) NSUInteger upColumn;
@property (nonatomic, readonly) NSUInteger upRow;

+ (NSIndexPath *)indexPathForRow:(NSInteger)row inColumn:(NSInteger)column inIndex:(NSInteger)index;

@end
