//
//  UPLightGridView.m
//  UPWallet
//
//  Created by wxzhao on 14-6-7.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWLightGridView.h"

@interface UPWLightGridView ()
{
    NSMutableArray *_cellArray;
}

@end

@implementation UPWLightGridView

@synthesize customDataSource;
@synthesize customDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bounces = YES;
        self.scrollsToTop = NO;
        _cellArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)layoutSubviews
{
    NSArray* itemArray = [self subviews];
    for (UIControl* item in itemArray)
    {
        [item removeFromSuperview];
    }
    
    [self layoutCellArray];
}

- (void)layoutCellArray;
{
    NSInteger column = [self.customDataSource columnNumberForLightGridView:self];
    CGFloat borderMargin = [self.customDataSource borderMarginForLightGridView:self];
    CGFloat innerMargin = [self.customDataSource innerMarginForLightGridView:self];
    NSInteger count = [self.customDataSource countOfCellForLightGridView:self];
    CGSize itemSize = [self.customDataSource itemSizeForLightGridView:self];
    
    [_cellArray removeAllObjects];

    if (column <= 0) {
        return;
    }
    
    NSInteger line = count/column;
    if ((count%column != 0)) {
        line++;
    }

    CGFloat width = itemSize.width*column + borderMargin*2 + (column - 1)*innerMargin;
    
    for (NSInteger i = 0; i < count; i++) {
        NSInteger columnIndex = i%column;
        NSInteger lineIndex = i/column;
        
        CGFloat x = borderMargin + columnIndex*innerMargin + columnIndex*itemSize.width;
        CGFloat y = lineIndex*itemSize.height;
        CGRect itemRect = CGRectMake(x, y, itemSize.width, itemSize.height);

        UIView* itemControl  = [self.customDataSource lightGridView:self cellAtIndex:i];
        itemControl.backgroundColor = [UIColor clearColor];
        [itemControl setFrame:itemRect];
        [_cellArray addObject:itemControl];
        [self addSubview:itemControl];

        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        [tapGestureRecognizer addTarget:self action:@selector(tapAction:)];
        [itemControl addGestureRecognizer:tapGestureRecognizer];
    }
    
    // set UIScrollView contentSize
    CGFloat height = itemSize.height*line;
    [self setContentSize:CGSizeMake(width, height)];
}

- (void)tapAction:(UITapGestureRecognizer*)tapGestureRecognizer
{
    NSArray* itemArray = [self subviews];
    for (NSInteger i = 0; i < [itemArray count]; i++)
    {
        if ([itemArray objectAtIndex:i] == tapGestureRecognizer.view) {;
            [self.customDelegate lightGridView:self didSelectAtIndex:i cell:[_cellArray objectAtIndex:i]];
            break;
        }
    }
}

@end
