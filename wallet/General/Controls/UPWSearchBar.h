//
//  UPSearchBar.h
//  CHSP
//
//  Created by TZ_JSKFZX_CAOQ on 13-11-18.
//
//

#import <UIKit/UIKit.h>

@class UPWSearchBar;

@protocol UPWSearchBarDelegate<NSObject>

@optional

- (BOOL)searchBarShouldBeginEditing:(UPWSearchBar *)searchBar;

- (void)searchBarTextDidBeginEditing:(UPWSearchBar *)searchBar;

- (BOOL)searchBarShouldEndEditing:(UPWSearchBar *)searchBar;

- (void)searchBarTextDidEndEditing:(UPWSearchBar *)searchBar;

- (void)searchBar:(UPWSearchBar *)searchBar textDidChange:(NSString *)searchText;

- (BOOL)searchBar:(UPWSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)searchBarCancelButtonClicked:(UPWSearchBar *) searchBar;

- (void)searchBarShouldClear:(UPWSearchBar *)searchBar;

- (void)searchBarSearchButtonClicked:(UPWSearchBar *)searchBar;

@end

@interface UPWSearchBar : UIView

@property (nonatomic, assign) id<UPWSearchBarDelegate> delegate;
@property (nonatomic, retain) UIImage* backgroundImage;
@property (nonatomic, copy)   NSString* placeholder;
@property (nonatomic, copy)   NSString* searchString;

- (void)setSearchFieldSize:(CGSize)searchFieldSize animated:(BOOL)animated;

- (void)setImageforSearchBarIcon:(UIImage *)iconImage;

- (void)setSearchFieldBackgroundImage:(UIImage *)backgroundImage;

- (void)setShowsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated;

@end
