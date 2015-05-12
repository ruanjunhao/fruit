//
//  UPSegmentedControl.h
//  CHSP
//
//  Created by wxzhao on 13-1-2.
//
//

#import <UIKit/UIKit.h>
#import "UPSegmentedControlDelegate.h"

#define kHeightSegmentView 32

@interface UPSegmentedControl : UIView
{
    NSArray* mTitleArray;
    NSMutableArray* mButtonArray;
    NSInteger mSelectedIndex;
}

@property(nonatomic,assign)id<UPSegmentedControlDelegate>delegate;

- (id)initWithFrame:(CGRect)frame Items:(NSArray*)items;
- (void)setSelectedSegmentIndex:(NSInteger)selectedIndex;
- (NSInteger)selectedSegmentIndex;

@end
