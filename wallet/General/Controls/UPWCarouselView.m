//
//  UPWCarouselView.m
//  UPWallet
//
//  Created by wxzhao on 14-6-8.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWCarouselView.h"


@implementation UPWPageControl

@synthesize inactiveImage;
@synthesize activeImage;

 -(id) initWithFrame:(CGRect)frame
 {
     self = [super initWithFrame:frame];
     
     if(self) {
     
         self.activeImage = [UIImage imageNamed:@"pageControl_on"] ;
         self.inactiveImage = [UIImage imageNamed:@"pageControl_off"] ;
     }
     
     return self;
}

 -(void) updateDots {
     
     for (int i = 0; i < [self.subviews count]; i++)
     {
         UIView* dotView = [self.subviews objectAtIndex:i];
         UIImageView* dot = nil;
         
         for (UIView* subview in dotView.subviews)
         {
             if ([subview isKindOfClass:[UIImageView class]])
             {
                 dot = (UIImageView*)subview;
                 break;
             }
         }
         
         if (dot == nil)
         {
             dot = [[UIImageView alloc] initWithFrame:CGRectMake(-0.5f, -0.5f, dotView.frame.size.width + 1, dotView.frame.size.height + 1)];
             [dotView addSubview:dot];
         }
         
         if (i == self.currentPage)
         {
             if(self.activeImage)
                 dot.image = activeImage;
         }
         else
         {
             if (self.inactiveImage)
                 dot.image = inactiveImage;
         }
     }
}

 -(void) setCurrentPage:(NSInteger)page {
     
    [super setCurrentPage:page];
    [self updateDots];
}



@end


@implementation UPWCarouselView

@synthesize delegate;
@synthesize datasource;
@synthesize bounces = _bounces;
@synthesize showIndicator = _showIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        view.backgroundColor = [UIColor whiteColor];
        [self addSubview:view];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _showIndicator = YES;
        [view addSubview:_scrollView];
        
        _pageControl = [[UPWPageControl alloc] initWithFrame:CGRectZero];
        _pageControl.backgroundColor = [UIColor clearColor];
        
//        if (iOS6) {
//            _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
//            _pageControl.pageIndicatorTintColor = [UIColor grayColor];
//        }
        [_pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_pageControl];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSArray* subViewArray = [_scrollView subviews];
    for (UIView* view in subViewArray)
    {
        [view removeFromSuperview];
    }
    
    NSInteger count = [self.datasource countOfCellForCarouselView:self];
    _scrollView.contentSize = CGSizeMake(self.frame.size.width*count, self.frame.size.height);
    for (int i = 0; i < count; i++)
    {
        UIControl* control = [[UIControl alloc] initWithFrame:CGRectMake(i*self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        control.userInteractionEnabled = YES;
        
        UIView* subView = [self.datasource carouselView:self cellAtIndex:i];
        
        [subView setBackgroundColor:UP_COL_RGB(0XF4F4F4)];
        [control addSubview:subView];
        [_scrollView addSubview:control];
        [control addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    _pageControl.frame = CGRectMake(0, self.frame.size.height - 11 - self.pageControlButtomMargin, self.frame.size.width, 15);
    
    _pageControl.numberOfPages = count;
    _pageControl.currentPage = 0;
    _pageControl.hidden = !_showIndicator;
    
    if (_showIndicator && count == 1) {
        _pageControl.hidden = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
}

- (void)changePage:(id)sender
{
    NSInteger page = _pageControl.currentPage;
    CGRect frame = _scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_scrollView scrollRectToVisible:frame animated:YES];
}

- (void)itemAction:(id)sender
{
    NSArray* itemArray = [_scrollView subviews];
    for (int i = 0; i < [itemArray count]; i++)
    {
        if (sender == [itemArray objectAtIndex:i])
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:didSelectAtIndex:)])
            {
                [delegate carouselView:self didSelectAtIndex:i];
            }
            break;
        }
    }
}

- (void)setShowIndicator:(BOOL)showIndicator
{
    _showIndicator = showIndicator;
    _pageControl.hidden = !_showIndicator;
}

- (void)setBounces:(BOOL)bounces
{
    _bounces = bounces;
    _scrollView.bounces = _bounces;
}

@end
