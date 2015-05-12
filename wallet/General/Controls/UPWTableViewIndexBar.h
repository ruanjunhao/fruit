//
//  UPTableViewIndexBar.h
//  CHSP
//
//  Created by TZ_JSKFZX_CAOQ on 14-2-25.
//
//


#import <Foundation/Foundation.h>

@protocol UPWTableViewIndexBarDelegate;
@protocol UPWTableViewIndexBarDataSource;

@interface UPWTableViewIndexBar : UIView

- (id)init;
- (id)initWithFrame:(CGRect)frame;
- (void)reloadData;

@property (nonatomic, weak) id<UPWTableViewIndexBarDelegate> delegate;
@property (nonatomic, weak) id<UPWTableViewIndexBarDataSource> dataSource;
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFont;

@end

@protocol UPWTableViewIndexBarDelegate<NSObject>
@optional
- (void)indexSelectionDidChange:(UPWTableViewIndexBar *)indexBar index:(NSInteger)index title:(NSString*)title;
@end

@protocol UPWTableViewIndexBarDataSource<NSObject>
@optional
- (NSArray*)sectionIndexBarTitles;
@end

