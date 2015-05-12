//
// UIScrollView+SVPullToRefresh.m
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <QuartzCore/QuartzCore.h>
#import "UIScrollView+SVPullToRefresh.h"
#import "UPWRotateAnimationView.h"

//fequalzro() from http://stackoverflow.com/a/1614761/184130
#define fequalzero(a) (fabs(a) < FLT_EPSILON)

static CGFloat const SVPullToRefreshViewHeight = 50;

@interface SVPullToRefreshArrow : UIView

@property (nonatomic, strong) UIColor *arrowColor;

@end


@interface SVPullToRefreshView ()

@property (nonatomic, copy) void (^pullToRefreshActionHandler)(void);

@property (nonatomic, strong) UPWRotateAnimationView* rotateAnimationView;
@property (nonatomic, strong) UIView* stoppedView;
@property (nonatomic, strong) UIView* triggeredView;
@property (nonatomic, strong) UIView *refreshingView;

@property (nonatomic, readwrite) SVPullToRefreshState state;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, readwrite) CGFloat originalTopInset;

@property (nonatomic, assign) BOOL wasTriggeredByUser;
@property (nonatomic, assign) BOOL showsPullToRefresh;
@property(nonatomic, assign) BOOL isObserving;

- (void)resetScrollViewContentInset;
- (void)setScrollViewContentInsetForLoading;
- (void)setScrollViewContentInset:(UIEdgeInsets)insets;

@end



#pragma mark - UIScrollView (SVPullToRefresh)
#import <objc/runtime.h>

static char UIScrollViewPullToRefreshView;

@implementation UIScrollView (SVPullToRefresh)

@dynamic pullToRefreshView, showsPullToRefresh;

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler {
    
    if(!self.pullToRefreshView) {
        SVPullToRefreshView *view = [[SVPullToRefreshView alloc] initWithFrame:CGRectMake(0, -SVPullToRefreshViewHeight, self.bounds.size.width, SVPullToRefreshViewHeight)];
        view.pullToRefreshActionHandler = actionHandler;
        view.scrollView = self;
        [self addSubview:view];
        
        view.originalTopInset = self.contentInset.top;
        self.pullToRefreshView = view;
        self.showsPullToRefresh = YES;
    }
}

- (void)triggerPullToRefresh {
    self.pullToRefreshView.state = SVPullToRefreshStateTriggered;
    [self.pullToRefreshView startAnimating];
}

- (void)setPullToRefreshView:(SVPullToRefreshView *)pullToRefreshView {
    [self willChangeValueForKey:@"SVPullToRefreshView"];
    objc_setAssociatedObject(self, &UIScrollViewPullToRefreshView,
                             pullToRefreshView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"SVPullToRefreshView"];
}

- (SVPullToRefreshView *)pullToRefreshView {
    return objc_getAssociatedObject(self, &UIScrollViewPullToRefreshView);
}

- (void)setShowsPullToRefresh:(BOOL)showsPullToRefresh {
    self.pullToRefreshView.hidden = !showsPullToRefresh;
    
    if(!showsPullToRefresh) {
      if (self.pullToRefreshView.isObserving) {
        [self removeObserver:self.pullToRefreshView forKeyPath:@"contentOffset"];
        [self removeObserver:self.pullToRefreshView forKeyPath:@"frame"];
        [self.pullToRefreshView resetScrollViewContentInset];
        self.pullToRefreshView.isObserving = NO;
      }
    }
    else {
      if (!self.pullToRefreshView.isObserving) {
        [self addObserver:self.pullToRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self.pullToRefreshView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        self.pullToRefreshView.isObserving = YES;
      }
    }
}

- (BOOL)showsPullToRefresh {
    return !self.pullToRefreshView.hidden;
}

@end

#pragma mark - SVPullToRefresh
@implementation SVPullToRefreshView

// public properties
@synthesize pullToRefreshActionHandler;

@synthesize state = _state;
@synthesize scrollView = _scrollView;
@synthesize showsPullToRefresh = _showsPullToRefresh;


- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.state = SVPullToRefreshStateStopped;
    }

    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview { 
    if (self.superview && newSuperview == nil) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsPullToRefresh) {
          if (self.isObserving) {
            //If enter this branch, it is the moment just before "SVPullToRefreshView's dealloc", so remove observer here
            [scrollView removeObserver:self forKeyPath:@"contentOffset"];
            [scrollView removeObserver:self forKeyPath:@"frame"];
            self.isObserving = NO;
          }
        }
    }
}

- (void)layoutSubviews {
    
    switch (self.state) {
        case SVPullToRefreshStateStopped:
        {
//            self.rotateAnimationView.hidden = YES;
            self.stoppedView.hidden = NO;
            self.triggeredView.hidden = YES;
            self.refreshingView.hidden = YES;
//            [self.rotateAnimationView stopRotating];
            CGRect viewBounds = [self.stoppedView bounds];
            CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2), roundf((self.bounds.size.height-viewBounds.size.height)/2));
            [self.stoppedView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];

        }
            break;
        case SVPullToRefreshStateTriggered:
        {
//            self.rotateAnimationView.hidden = YES;
            self.stoppedView.hidden = YES;
            self.triggeredView.hidden = NO;
            self.refreshingView.hidden = YES;
            CGRect viewBounds = [self.triggeredView bounds];
            CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2), roundf((self.bounds.size.height-viewBounds.size.height)/2));
            [self.triggeredView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];
        }
            break;
                
        case SVPullToRefreshStateLoading:
        {
//            self.rotateAnimationView.hidden = NO;
            self.stoppedView.hidden = YES;
            self.triggeredView.hidden = YES;
            self.refreshingView.hidden = NO;
            CGRect viewBounds = [self.refreshingView bounds];
            CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2), roundf((self.bounds.size.height-viewBounds.size.height)/2));
            [self.refreshingView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];
//            UIImage* loading = self.rotateAnimationView.image;
//            self.rotateAnimationView.frame = CGRectMake((self.bounds.size.width - loading.size.width)/2, (self.bounds.size.height - loading.size.height)/2, loading.size.width, loading.size.height);
//            [self.rotateAnimationView startRotating];
        }

            break;
    }
}

#pragma mark - Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForLoading {
    CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = MIN(offset, self.originalTopInset + self.bounds.size.height);
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:NULL];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {    
    if([keyPath isEqualToString:@"contentOffset"])
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    else if([keyPath isEqualToString:@"frame"])
        [self layoutSubviews];
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    [self.scrollView bringSubviewToFront:self.scrollView.pullToRefreshView];
    
    if(self.state != SVPullToRefreshStateLoading) {
        CGFloat scrollOffsetThreshold = self.frame.origin.y-self.originalTopInset;
        
        if(!self.scrollView.isDragging && self.state == SVPullToRefreshStateTriggered)
            self.state = SVPullToRefreshStateLoading;
        else if(contentOffset.y < scrollOffsetThreshold && self.scrollView.isDragging && self.state == SVPullToRefreshStateStopped)
            self.state = SVPullToRefreshStateTriggered;
        else if(contentOffset.y >= scrollOffsetThreshold && self.state != SVPullToRefreshStateStopped)
            self.state = SVPullToRefreshStateStopped;
    } else {
        CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0.0f);
        offset = MIN(offset, self.originalTopInset + self.bounds.size.height);
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);
    }
}

#pragma mark - Getters


- (UPWRotateAnimationView *)rotateAnimationView {
    if(!_rotateAnimationView) {
        _rotateAnimationView = [[UPWRotateAnimationView alloc] init];
        UIImage* loading = UP_GETIMG(@"icon_activity");
        _rotateAnimationView.image = loading;
        _rotateAnimationView.hidden = YES;
        [self addSubview:_rotateAnimationView];
    }
    return _rotateAnimationView;
}

- (UIView *)stoppedView
{
//    if (!_stoppedView) {
//        _stoppedView = [[UIImageView alloc] initWithImage:UP_GETIMG(@"icon_pull_to_refresh2")];
//        [self addSubview:_stoppedView];
//    }
//    return _stoppedView;
    
    if (!_stoppedView) {
        _stoppedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        UILabel *label = [[UILabel alloc] initWithFrame:_stoppedView.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = UP_COL_RGB(0x666666);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"下拉刷新";
        [_stoppedView addSubview:label];
        
        [self addSubview:_stoppedView];
    }
    
    return _stoppedView;
}


- (UIView *)triggeredView
{
//    if (!_triggeredView) {
//        _triggeredView = [[UIImageView alloc] initWithImage:UP_GETIMG(@"icon_pull_to_refresh1")];
//        [self addSubview:_triggeredView];
//    }
//    return _triggeredView;
    
    if (!_triggeredView) {
        _triggeredView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        UILabel *label = [[UILabel alloc] initWithFrame:_triggeredView.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = UP_COL_RGB(0x666666);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"松手刷新";
        [_triggeredView addSubview:label];
        [self addSubview:_triggeredView];
    }
    
    return _triggeredView;
}

- (UIView *)refreshingView
{
    if (!_refreshingView) {
        _refreshingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        UILabel *label = [[UILabel alloc] initWithFrame:_refreshingView.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = UP_COL_RGB(0x666666);
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"正在刷新";
        [_refreshingView addSubview:label];
        [self addSubview:_refreshingView];
    }
    
    return _refreshingView;
}

#pragma mark -

- (void)triggerRefresh {
    [self.scrollView triggerPullToRefresh];
}

- (void)startAnimating{
    if(fequalzero(self.scrollView.contentOffset.y)) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.frame.size.height) animated:YES];
        self.wasTriggeredByUser = NO;
    }
    else
        self.wasTriggeredByUser = YES;
    
    self.state = SVPullToRefreshStateLoading;
}

- (void)stopAnimating {
    self.state = SVPullToRefreshStateStopped;
    
    if(!self.wasTriggeredByUser && self.scrollView.contentOffset.y < -self.originalTopInset)
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.originalTopInset) animated:YES];
}

- (void)setState:(SVPullToRefreshState)newState {
    
    if(_state == newState)
        return;
    
    SVPullToRefreshState previousState = _state;
    _state = newState;
    
    [self setNeedsLayout];
    
    switch (newState) {
        case SVPullToRefreshStateStopped:
            [self resetScrollViewContentInset];
            break;
            
        case SVPullToRefreshStateTriggered:
            break;
            
        case SVPullToRefreshStateLoading:
            [self setScrollViewContentInsetForLoading];
            
            if(previousState == SVPullToRefreshStateTriggered && pullToRefreshActionHandler)
                pullToRefreshActionHandler();
            
            break;
    }
}


@end

