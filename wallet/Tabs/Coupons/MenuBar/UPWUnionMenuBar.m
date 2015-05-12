//
//  UPUnionMenuBar.m
//  ttttttestv
//
//  Created by TZ_JSKFZX_CAOQ on 13-11-11.
//  Copyright (c) 2013年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWUnionMenuBar.h"

@interface UPWUnionMenuBar()<UPWUnionMenuListDelegate, UPWUnionMenuButtonDelegate>
{
    NSInteger   _selectedMenuButtonIndex;
    NSInteger   _lastSelectedMenuButtonIndex;
    NSMutableDictionary *_classDict;
    UPWUnionMenuBarBackground       *_menuBarBackground;
    UIView*             _currentListView;
    NSMutableSet *_indexPathsForSelectedItems;

}
@property (strong, nonatomic) NSMutableDictionary *lists;

@end

@interface UPWUnionMenuBarBackground()

@property (nonatomic, retain) CAShapeLayer *borderBottomLayer;

- (void)drawPathsFromPosition:(CGFloat)oldPosition toPosition:(CGFloat)position animationDuration:(CFTimeInterval)duration;

@end



@interface UPWUnionMenuButton()
{
    BOOL _buttonSelected;
}

@end

@interface UPWUnionMenuList()
{
    UIView* _alphaView;
    UITapGestureRecognizer* _tapGr;
}

@end


#pragma mark - UPUnionMenuBar

@implementation UPWUnionMenuBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _selectedMenuButtonIndex = -1;
        _lastSelectedMenuButtonIndex = -1;
        
        _buttonInteractionEnabled = YES;
        
        _menuEdgeInsets = UIEdgeInsetsMake(0, 0, 5, 0);

        _buttons = [[NSMutableArray alloc] init];
        _lists = [[NSMutableDictionary alloc] init];

        _classDict = [[NSMutableDictionary alloc] init];
        _indexPathsForSelectedItems =[[NSMutableSet alloc] init];
        
        _menuBarBackground = [[UPWUnionMenuBarBackground alloc] init];
        
        [self addSubview:_menuBarBackground];

        UIImage* line = [[UIImage imageNamed:@"separator"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        UIImageView* buttomLine = [[UIImageView alloc]
                                   initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-0.5, CGRectGetWidth(self.frame), 0.5)];
        buttomLine.image = line;
        [self  addSubview:buttomLine];
    }
    return self;
}

- (void)dealloc
{
    [_buttons removeAllObjects];
}

#pragma mark - public method

- (UPWUnionMenuButton *)addMenuButtonWithTitle:(NSString *)title withListIdentifier:(NSString *)listIdentifier forIdentifier:(NSString *)identifier showWordsLength:(NSInteger)length
{
    NSString* buttonClass = _classDict[identifier];
    UPWUnionMenuButton* menuButton = nil;
    if (buttonClass == nil) {
         menuButton = [[UPWUnionMenuButton alloc] init];
    }
    else{
        menuButton = [[NSClassFromString(buttonClass) alloc] init];
    }
    menuButton.listIdentifier = listIdentifier;
    [menuButton addTarget:self action:@selector(handleMenuButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    menuButton.alpha = 0;
    [menuButton setButtonTitle:title showWordsLength:length];
    menuButton.showWordsLength = length;
    [menuButton sizeToFit];
    
    [_menuBarBackground addSubview:menuButton];
    menuButton.index = self.buttons.count;
    [self.buttons addObject:menuButton];
    menuButton.delegate = self;
    
    return menuButton;
}


- (void)addMenuListForIdentifier:(NSString *)identifier
{
    NSString* listClass = _classDict[identifier];
    UPWUnionMenuList* list = nil;
    if (listClass == nil) {
        list = [[UPWUnionMenuList alloc] init];
    }
    else{
        list = [[NSClassFromString(listClass) alloc] init];
    }
    if (list) {
        list.delegate = self;
        [list sizeToFit];
        self.lists[identifier] = list;
    }
}

- (void)registerClass:(NSString *)className forIdentifier:(NSString *)identifier
{
    _classDict[identifier] = className;
}


- (void)handleMenuList:(UPWUnionMenuButton*)sender
{
    UPWUnionMenuList* list = self.lists[sender.listIdentifier];
    if (!list) return;
    
    list.menuBar = self;
    list.button = sender;
    list.frame = CGRectMake(0,  0, CGRectGetWidth(_menuBarBackground.frame), CGRectGetHeight(self.frame));
    [list reloadData];
    if (sender.buttonSelected) {
        [self insertSubview:list belowSubview:_menuBarBackground];
        [list selectRowsByItems:_indexPathsForSelectedItems];
        [list setNeedsLayout];
        _currentListView = list;
    }
    else{
        [list willCloseMenuList];        //消失前保存一些东西
        [list removeFromSuperview];
        _currentListView = nil;
    }
}

- (NSArray *)indexPathsForSelectedItems {
    return [_indexPathsForSelectedItems allObjects];
}

#pragma mark - delegate


- (CGRect)unionMenuList:(UPWUnionMenuList *)unionMenuList rectForListInIndex:(NSInteger)index
{
    if (!CGRectEqualToRect(CGRectFromString(self.listRectArray[index]), CGRectZero) && CGRectFromString(self.listRectArray[index]).size.height < self.listRect.size.height) {
        return CGRectFromString(self.listRectArray[index]);
    }
    return self.listRect;
}

- (CGRect)unionMenuList:(UPWUnionMenuList *)unionMenuList rectForDimmedBackgroundInIndex:(NSInteger)index
{
    return self.dimmedBackgroundRect;
}

- (NSInteger)unionMenuList:(UPWUnionMenuList *)unionMenuList numberOfRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate unionMenuBar:self numberOfRowsAtIndexPath:indexPath];
}

- (id)unionMenuList:(UPWUnionMenuList *)unionMenuList dataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate unionMenuBar:self dataForItemAtIndexPath:indexPath];
}

- (NSString *)unionMenuList:(UPWUnionMenuList *)unionMenuList leftImageUrlForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.delegate respondsToSelector:@selector(unionMenuBar:leftImageUrlForItemAtIndexPath:)]) {
        return [self.delegate unionMenuBar:self leftImageUrlForItemAtIndexPath:indexPath];
    }

    return nil;
}

- (void)unionMenuList:(UPWUnionMenuList *)unionMenuList didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectItemAtIndexPath:indexPath];
    return [self.delegate unionMenuBar:self didSelectItemAtIndexPath:indexPath];
}

- (void)didSelectUnionMenuButton:(UPWUnionMenuButton *)unionMenuButton
{
    if([self.delegate respondsToSelector:@selector(didSelectUnionMenuButton:)]) {
        return [self.delegate didSelectUnionMenuButton:unionMenuButton];
    }
}

#pragma mark - private method

- (CGFloat)arrowSize
{
    return _menuBarBackground.arrowSize;
}

- (void)setArrowSize:(CGFloat)arrowSize
{
    _menuBarBackground.arrowSize = arrowSize;
}

- (CGFloat)arrowHeightFactor
{
    return _menuBarBackground.arrowHeightFactor;
}

- (void)setArrowHeightFactor:(CGFloat)arrowHeightFactor
{
    _menuBarBackground.arrowHeightFactor = arrowHeightFactor;
}

- (CFTimeInterval)animationDuration
{
    return _menuBarBackground.animationDuration;
}

- (void)setAnimationDuration:(CFTimeInterval)animationDuration
{
    _menuBarBackground.animationDuration = animationDuration;
}

- (UIColor *)backgroundColor
{
    return [UIColor colorWithCGColor:((CAShapeLayer *)_menuBarBackground.layer).fillColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    ((CAShapeLayer *)_menuBarBackground.layer).fillColor = backgroundColor.CGColor;
}

- (UIColor *)shadowColor
{
    return [UIColor colorWithCGColor:_menuBarBackground.layer.shadowColor];
}

- (void)setShadowColor:(UIColor *)color
{
    _menuBarBackground.layer.shadowColor = color.CGColor;
}

- (CGFloat)shadowRadius
{
    return _menuBarBackground.layer.shadowRadius;
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    _menuBarBackground.layer.shadowRadius = shadowRadius;
}

- (CGFloat)shadowOpacity
{
    return _menuBarBackground.layer.shadowOpacity;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    _menuBarBackground.layer.shadowOpacity = shadowOpacity;
}

- (CGSize)shadowOffset
{
    return _menuBarBackground.layer.shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    _menuBarBackground.layer.shadowOffset = shadowOffset;
}

- (CGFloat)borderWidth
{
    return _menuBarBackground.borderBottomLayer.lineWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _menuBarBackground.borderBottomLayer.lineWidth = borderWidth;
}

- (UIColor *)borderColor
{
    return [UIColor colorWithCGColor:_menuBarBackground.borderBottomLayer.strokeColor];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _menuBarBackground.borderBottomLayer.strokeColor = borderColor.CGColor;
}

#pragma mark - private method
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {
        for (UIView *subview in self.subviews.reverseObjectEnumerator) {
            CGPoint subPoint = [subview convertPoint:point fromView:self];
            UIView *result = [subview hitTest:subPoint withEvent:event];
            if (result != nil) {
                return result;
                break;
            }
        }
    }
    return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _menuBarBackground.frame = CGRectMake(0, 0, self.frame.size.width, kMenuBarHeight);

    [self layoutMenuButtons];
    
    CGFloat oldPosition = 0;
    CGFloat selectedItemCenterPosition = 0;
    if (_selectedMenuButtonIndex == -1)
    {
        self.arrowSize = 0;
        if (_lastSelectedMenuButtonIndex > -1) {
            UPWUnionMenuButton *lastItem = (UPWUnionMenuButton*)self.buttons[_lastSelectedMenuButtonIndex];
            oldPosition = lastItem.center.x;
            selectedItemCenterPosition = lastItem.center.x;
        }
    }
    else{
        self.arrowSize = 6.0;
        UPWUnionMenuButton *item = (UPWUnionMenuButton*)self.buttons[_selectedMenuButtonIndex];
        oldPosition = item.center.x;
        selectedItemCenterPosition = item.center.x;
    }

    [_menuBarBackground drawPathsFromPosition:oldPosition toPosition:selectedItemCenterPosition animationDuration:0];
}

- (void)layoutMenuButtons
{
    CGFloat totalItemWidth = CGRectGetWidth(_menuBarBackground.bounds) - self.menuEdgeInsets.left - self.menuEdgeInsets.right;
    CGFloat itemWidth = totalItemWidth/self.buttons.count;
    CGFloat itemHeight = CGRectGetHeight(_menuBarBackground.bounds) - self.menuEdgeInsets.bottom - self.menuEdgeInsets.top;
    __block CGFloat currentItemPosition = self.menuEdgeInsets.left;
    
    [self.buttons enumerateObjectsUsingBlock:^(UPWUnionMenuButton *item, NSUInteger idx, BOOL *stop)
     {
         item.alpha = 1;
         item.frame = CGRectIntegral(CGRectMake(currentItemPosition, self.menuEdgeInsets.top,itemWidth, itemHeight));
         currentItemPosition = CGRectGetMaxX(item.frame);
         
         //layoutMenuSeparator
         if (idx != (self.buttons.count -1)) {
             UIImageView *separatorView = [[UIImageView alloc] init];
             separatorView.backgroundColor = UP_COL_RGB(0xd4d4d4);
             CGFloat imgWidth = 0.5;
             CGFloat imgHeight = 22;
             if (imgWidth < itemWidth && imgHeight < itemHeight) {
                 separatorView.frame = CGRectMake(itemWidth - imgWidth, (itemHeight - imgHeight)/2, imgWidth, imgHeight);
             }
             [item addSubview:separatorView];
         }
     }];
}


- (void)handleMenuButtonSelect:(UPWUnionMenuButton*)sender
{
    if (!self.buttonInteractionEnabled) {
        return;
    }
    NSInteger selected = -1;
    if (_selectedMenuButtonIndex != -1) {
        selected = _selectedMenuButtonIndex;
        [self clearSelectedButton];
    }
    
    _selectedMenuButtonIndex = selected;
    if (_selectedMenuButtonIndex != sender.index) {
        _selectedMenuButtonIndex = sender.index;
        [sender setButtonSelected:YES];
    }
    else{
        _selectedMenuButtonIndex = -1;
        [sender setButtonSelected:NO];
    }
    [self handleMenuList:sender];
    [self setNeedsLayout];
}



- (void)clearSelectedButton
{
    for (UPWUnionMenuButton *b in self.buttons) {
        if (b.buttonSelected) {
            _lastSelectedMenuButtonIndex = b.index;
        }
        [b setButtonSelected:NO];
        [self handleMenuList:b];
    }
    _selectedMenuButtonIndex = -1;
}

- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(upIndex != %d) || (upColumn != %d)", indexPath.upIndex, indexPath.upColumn];
    [_indexPathsForSelectedItems filterUsingPredicate:predicate];
    [_indexPathsForSelectedItems addObject:indexPath];
}


@end



#pragma mark - UPUnionMenuBarBackground

@implementation UPWUnionMenuBarBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = UIColor.clearColor;
//        self.arrowHeightFactor = -1.0;
//        self.arrowSize = 6.0;
//        self.animationDuration = 0.5;
//        ((CAShapeLayer *)self.layer).fillColor = UIColor.whiteColor.CGColor;
        
//        self.layer.shadowColor = UIColor.blackColor.CGColor;
//        self.layer.shadowOpacity =  .25;
//        self.layer.shadowOffset = CGSizeMake(0, 1);
//        self.layer.shadowRadius = 0.7;
        
//        [self.layer addSublayer:_borderBottomLayer = CAShapeLayer.layer];
//        _borderBottomLayer.fillColor = nil;
        

    }
    return self;
}

+ (Class)layerClass
{
    return CAShapeLayer.class;
}

- (void)drawPathsToPosition:(CGFloat)position animated:(BOOL)animated
{
    [self drawPathsToPosition:position animationDuration:animated ? self.animationDuration : 0 completion:nil];
}

- (void)drawPathsToPosition:(CGFloat)position animationDuration:(CFTimeInterval)duration completion:(void (^)(void))completion
{
    [self drawPathsFromPosition:CGFLOAT_MAX toPosition:position animationDuration:duration completion:completion];
}
- (void)drawPathsFromPosition:(CGFloat)oldPosition toPosition:(CGFloat)position animationDuration:(CFTimeInterval)duration
{
    [self drawPathsFromPosition:oldPosition toPosition:position animationDuration:duration completion:nil];
}
- (void)drawPathsFromPosition:(CGFloat)oldPosition toPosition:(CGFloat)position animationDuration:(CFTimeInterval)duration completion:(void (^)(void))completion
{
    CGRect bounds = self.bounds;
    CGFloat left = CGRectGetMinX(bounds);
    CGFloat right = CGRectGetMaxX(bounds);
    CGFloat top = CGRectGetMinY(bounds);
    CGFloat bottom = CGRectGetMaxY(bounds);
    
    //
    // Mask
    //
    __block UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:bounds.origin];
    [self addArrowAtPoint:CGPointMake(position, bottom) toPath:path withLineWidth:0.0];
    [path addLineToPoint:CGPointMake(right, top)];
    [path addLineToPoint:CGPointMake(left, top)];
    
    //
    // Shadow mask
    //
    top += 10;
    __block UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    [shadowPath moveToPoint:CGPointMake(left, top)];
    [self addArrowAtPoint:CGPointMake(position, bottom) toPath:shadowPath withLineWidth:0.0];
    [shadowPath addLineToPoint:CGPointMake(right, top)];
    [shadowPath addLineToPoint:CGPointMake(left, top)];
    
    //
    // Bottom white line
    //
    _borderBottomLayer.frame = self.bounds;
    __block UIBezierPath *borderBottomPath = [UIBezierPath bezierPath];
    const CGFloat lineY = bottom - _borderBottomLayer.lineWidth;
    [self addArrowAtPoint:CGPointMake(position, lineY) toPath:borderBottomPath withLineWidth:_borderBottomLayer.lineWidth];
    
    
    // Skip current animations and ensure the completion block was applied
    // otherwise this will end up in ugly effects if the selection was changed very fast
    [self.layer removeAllAnimations];
    [_borderBottomLayer removeAllAnimations];
    
    // Build block
    void(^assignLayerPaths)() = ^
    {
        ((CAShapeLayer *)self.layer).path = path.CGPath;
        self.layer.shadowPath = shadowPath.CGPath;
        _borderBottomLayer.path = borderBottomPath.CGPath;
    };
    
    __block void(^animationCompletion)();
    if (completion)
    {
        animationCompletion = ^
        {
            assignLayerPaths();
            completion();
        };
    }
    else
    {
        animationCompletion = assignLayerPaths;
    }
    
    // Apply new paths
    if (duration > 0)
    {
        // That's a bit fragile: we detect stop animation call by duration!
        NSString *timingFuncName = duration < self.animationDuration ? kCAMediaTimingFunctionEaseIn : kCAMediaTimingFunctionEaseInEaseOut;
        
        // Check if we have to do a stop animation, which means that we first
        // animate to have a fully visible arrow and then move the arrow.
        // Otherwise there will be ugly effects.
        CFTimeInterval stopDuration = -1;
        CGFloat stopPosition = -1;
        if (oldPosition < CGFLOAT_MAX)
        {
            if (oldPosition < left+self.arrowSize)
            {
                stopPosition = left+self.arrowSize;
            }
            else if (oldPosition > right-self.arrowSize)
            {
                stopPosition = right-self.arrowSize;
            }
            
            if (stopPosition > 0)
            {
                float relStopDuration = ABS((stopPosition - oldPosition) / (position - oldPosition));
                if (relStopDuration > 1)
                {
                    relStopDuration = 1.0 / relStopDuration;
                }
                stopDuration = duration * relStopDuration;
                duration -= stopDuration;
                timingFuncName  = kCAMediaTimingFunctionEaseOut;
            }
        }
        
        void (^animation)() = ^
        {
            [CATransaction begin];
            [CATransaction setAnimationDuration:duration];
            CAMediaTimingFunction *timing = [CAMediaTimingFunction functionWithName:timingFuncName];
            [CATransaction setAnimationTimingFunction:timing];
            [CATransaction setCompletionBlock:animationCompletion];
            
            [self addAnimationWithDuration:duration onLayer:self.layer forKey:@"path" toPath:path];
            [self addAnimationWithDuration:duration onLayer:self.layer forKey:@"shadow" toPath:shadowPath];
            [self addAnimationWithDuration:duration onLayer:_borderBottomLayer forKey:@"path" toPath:borderBottomPath];
            
            [CATransaction commit];
        };
        
        if (stopPosition > 0)
        {
            [self drawPathsToPosition:stopPosition animationDuration:stopDuration completion:animation];
        }
        else
        {
            animation();
        }
    }
    else
    {
        assignLayerPaths();
    }
    
}

- (void)addAnimationWithDuration:(CFTimeInterval)duration onLayer:(CALayer *)layer forKey:(NSString *)key toPath:(UIBezierPath *)path
{
    NSString *camelCaseKeyPath;
    NSString *keyPath;
    
    if ([key isEqual:@"path"])
    {
        camelCaseKeyPath = key;
        keyPath = key;
    }
    else
    {
        camelCaseKeyPath = [NSString stringWithFormat:@"%@Path", key];
        keyPath = [NSString stringWithFormat:@"%@.path", key];
    }
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:camelCaseKeyPath];
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.duration = duration;
    pathAnimation.fromValue = [layer valueForKey:keyPath];
    pathAnimation.toValue = (id)path.CGPath;
    [layer addAnimation:pathAnimation forKey:key];
}

- (void)addArrowAtPoint:(CGPoint)point toPath:(UIBezierPath *)path withLineWidth:(CGFloat)lineWidth
{
    // The arrow is added like below, whereas P is the point argument
    // and 1-5 are the points which were added to the path. It must be
    // always five points, otherwise animations will look ugly.
    //
    // P: point.x
    // s: self.arrowSize - line.width
    // w: self.bounds.size.width
    //
    //
    //   s < P < w-s:      P < -s:         P = MAX:       w+s < P:
    //
    //        3
    //       / \
    //      /   \
    //  1--2  P  4--5   1234--------5   1--2--3--4--5   1--------2345
    //
    //
    //    0 < P < s:       -s < P:
    //
    //     3
    //    / \           123
    //  12   \             \
    //     P  4-----5    P  4------5
    //
    
    const CGFloat left = CGRectGetMinX(self.bounds);
    const CGFloat right = CGRectGetMaxX(self.bounds);
    const CGFloat center = (right-left) / 2;
    const CGFloat width = self.arrowSize - lineWidth;
    const CGFloat height = self.arrowSize + lineWidth/2;
    const CGFloat ratio = self.arrowHeightFactor;
    
    __block NSMutableArray *points = [NSMutableArray array];
    BOOL hasCustomLastPoint = NO;
    
    void (^addPoint)(CGFloat x, CGFloat y) = ^(CGFloat x, CGFloat y)
    {
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    };
    
    // Add first point
    addPoint(left, point.y);
    
    if (_arrowSize <= 0.02)
    {
        addPoint(point.x - lineWidth, point.y);
        addPoint(point.x,             point.y);
        addPoint(point.x + lineWidth, point.y);
    }
    else if (point.x >= left+width && point.x <= right-width)
    {
        // Arrow is completely inside the view
        addPoint(point.x - width, point.y);
        addPoint(point.x,         point.y + ratio * height);
        addPoint(point.x + width, point.y);
    }
    else
    {
        // Just some tricks, to allow correctly cutted arrows and
        // to have always a proper animation.
        if (point.x <= left-width)
        {
            // Left aligned points
            addPoint(left + 0.01, point.y);
            addPoint(left + 0.02, point.y);
            addPoint(left + 0.03, point.y);
        }
        else if (point.x < left+width && point.x > left-width)
        {
            // Left cutted arrow
            [points removeAllObjects]; // Custom first point
            if (point.x < left)
            {
                CGFloat x = width + point.x;
                addPoint(left,        point.y + ratio * x);
                addPoint(left + 0.01, point.y + ratio * (x + 0.01));
                addPoint(left + 0.02, point.y + ratio * (x + 0.02));
                addPoint(left + x,    point.y);
            }
            else
            {
                CGFloat x = width - point.x;
                addPoint(left,            point.y + ratio * x);
                addPoint(left + 0.01,     point.y + ratio * (x + 0.01));
                addPoint(point.x,         point.y + ratio * height);
                addPoint(point.x + width, point.y);
            }
        }
        else if (point.x == CGFLOAT_MAX)
        {
            // Centered "arrow", with zero height
            addPoint(center - width, point.y);
            addPoint(center,         point.y);
            addPoint(center + width, point.y);
        }
        else if (point.x < right+width && point.x > right-width)
        {
            // Right cutted arrow, is like left cutted arrow but:
            //  * swapped if/else case
            //  * inverse point order
            //  * other calculation of x
            hasCustomLastPoint = YES; // Custom last point
            if (point.x < right)
            {
                CGFloat x = width - (right - point.x);
                addPoint(point.x - width, point.y);
                addPoint(point.x,         point.y + ratio * height);
                addPoint(right - 0.01,    point.y + ratio * (x + 0.01));
                addPoint(right,           point.y + ratio * x);
            }
            else
            {
                CGFloat x = width + (right - point.x);
                addPoint(right - x,    point.y);
                addPoint(right - 0.02, point.y + ratio * (x + 0.02));
                addPoint(right - 0.01, point.y + ratio * (x + 0.01));
                addPoint(right,        point.y + ratio * x);
            }
        }
        else
        {
            // Right aligned points
            addPoint(right - 0.03, point.y);
            addPoint(right - 0.02, point.y);
            addPoint(right - 0.01, point.y);
        }
    }
    
    // Add points from array to path
    CGPoint node = ((NSValue *)[points objectAtIndex:0]).CGPointValue;
    if (path.isEmpty)
    {
        [path moveToPoint:node];
    }
    else
    {
        [path addLineToPoint:node];
    }
    for (int i=1; i<points.count; i++)
    {
        node = ((NSValue *)[points objectAtIndex:i]).CGPointValue;
        [path addLineToPoint:node];
    }
    
    // Add last point of not replaced
    if (!hasCustomLastPoint)
    {
        [path addLineToPoint:CGPointMake(right, point.y)];
    }
}

@end

#pragma mark - UPUnionMenuButton



@implementation UPWUnionMenuButton

@synthesize buttonSelected = _buttonSelected;

- (void)setButtonTitle:(NSString *)title showWordsLength:(NSInteger)length
{
    
}

- (void)setButtonSelected:(BOOL)selected
{
    _buttonSelected = selected;
    
    if(selected && [self.delegate respondsToSelector:@selector(didSelectUnionMenuButton:)]) {
        [self.delegate didSelectUnionMenuButton:self];
    }
}

- (BOOL)buttonSelected
{
    return _buttonSelected;
}

@end

#pragma mark - UPUnionMenuList



@implementation UPWUnionMenuList


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _alphaView = [[UIView alloc] initWithFrame:CGRectZero];
        _alphaView.backgroundColor = UIColor.blackColor;
        _alphaView.alpha = 0.5;
        [self addSubview:_alphaView];
        _tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeMenuList)];
        [_alphaView addGestureRecognizer:_tapGr];
    }
    return self;
}

- (void)dealloc
{
    [_alphaView removeGestureRecognizer:_tapGr];
}

- (void)layoutSubviews
{
    self.listDisplayRect = [self.delegate unionMenuList:self rectForListInIndex:self.button.index];
    CGRect rect = [self.delegate unionMenuList:self rectForDimmedBackgroundInIndex:self.button.index];
    _alphaView.frame = rect;
    self.frame = rect;
}

- (void)willCloseMenuList
{
    //子类继承
    
}

- (void)closeMenuList
{
    [self.menuBar clearSelectedButton];
}

- (void)reloadData
{
    //子类继承
}

- (void)selectRowsByItems:(NSSet*)set
{
    //子类继承,处理显示已选择的item
}



@end

#pragma mark - UPUnionMenuListTableView


@implementation UPWUnionMenuListTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentInset = UIEdgeInsetsMake(kMenuBarHeight, 0, 0, 0);
        self.contentOffset = (CGPoint){0,-kMenuBarHeight};
        self.scrollIndicatorInsets = UIEdgeInsetsMake(kMenuBarHeight, 0, 0, 0);
    }
    return self;
}

@end

#pragma mark - NSIndexPath Extension


@implementation NSIndexPath(UPUnionMenuBar)

+ (NSIndexPath *)indexPathForRow:(NSInteger)row inColumn:(NSInteger)column inIndex:(NSInteger)index
{
    NSUInteger indexes[3] = {row, column, index};
    return [NSIndexPath indexPathWithIndexes:indexes length:3];
    
}

- (NSUInteger)upRow {
    return [self indexAtPosition:0];
}

- (NSUInteger)upColumn {
    return [self indexAtPosition:1];
}

- (NSUInteger)upIndex {
    return [self indexAtPosition:2];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[upRow %lu,upColumn %lu,upIndex %lu]", (unsigned long)[self upRow],  (unsigned long)[self upColumn], (unsigned long)[self upIndex]];
}

@end