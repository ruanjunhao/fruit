//
//  UPWCarouselView.h
//  UPWallet
//
//  Created by wxzhao on 14-6-8.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UPWPageControl : UIPageControl {
    UIImage* activeImage;
    UIImage* inactiveImage;
}

@property (nonatomic,retain) UIImage *activeImage;
@property (nonatomic,retain) UIImage *inactiveImage;

@end


@class UPWCarouselView;
@protocol UPWCarouselViewDatasource <NSObject>

- (NSInteger)countOfCellForCarouselView:(UPWCarouselView*)carouselView;
- (UIView*)carouselView:(UPWCarouselView*)carouselView cellAtIndex:(NSInteger)index;

@end

@protocol UPWCarouselViewDelegate <NSObject>

@optional
- (void)carouselView:(UPWCarouselView*)carouselView didSelectAtIndex:(NSInteger)index;

@end

@interface UPWCarouselView : UIView<UIScrollViewDelegate>
{
    UIScrollView* _scrollView;
    UPWPageControl* _pageControl;
    
    BOOL _showIndicator;
    BOOL _bounces;
}

@property(nonatomic,assign) BOOL bounces;
@property(nonatomic,weak) id<UPWCarouselViewDelegate> delegate;
@property(nonatomic,weak) id<UPWCarouselViewDatasource> datasource;

@property(nonatomic,assign) BOOL showIndicator;
@property(nonatomic,assign) CGFloat pageControlButtomMargin;
- (id)initWithFrame:(CGRect)frame;

@end
