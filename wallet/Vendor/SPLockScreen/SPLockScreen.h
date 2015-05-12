//
//  SPLockScreen.h
//  SuQian
//
//  Created by Suraj on 24/9/12.
//  Copyright (c) 2012 Suraj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPLockOverlay.h"


#define kSeed									23
#define kAlterOne                               1234
#define kAlterTwo                               4321
#define kTagIdentifier                          22222

@class SPLockScreen;
@class NormalCircle;

@protocol LockScreenDelegate <NSObject>

- (int)lockScreen:(SPLockScreen *)lockScreen didEndWithPattern:(NSNumber *)patternNumber;

@end

@interface SPLockScreen : UIView

@property (nonatomic, strong) NormalCircle *selectedCell;
@property (nonatomic, strong) SPLockOverlay *overLay;
@property (nonatomic) NSInteger oldCellIndex,currentCellIndex;
@property (nonatomic, strong) NSMutableDictionary *drawnLines;
@property (nonatomic, strong) NSMutableArray *finalLines, *cellsInOrder;

@property (nonatomic, strong) id<LockScreenDelegate> delegate;

@property (nonatomic) BOOL allowClosedPattern;			// Set to YES to allow a closed pattern, a complex type pattern; NO by default
@property (nonatomic) BOOL allowPan;

- (NormalCircle *)cellAtIndex:(NSInteger)index;
- (void)resetScreen;

// Init Method

- (id)initWithDelegate:(id<LockScreenDelegate>)lockDelegate;
@end
