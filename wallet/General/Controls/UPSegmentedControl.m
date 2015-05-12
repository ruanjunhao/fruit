//
//  UPSegmentedControl.m
//  CHSP
//
//  Created by wxzhao on 13-1-2.
//
//

#import "UPSegmentedControl.h"

@implementation UPSegmentedControl

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame Items:(NSArray *)items
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UP_COL_RGB(0xffffff);
        self.layer.borderWidth = 1;
        self.layer.borderColor = UP_COL_RGB(0xffffff).CGColor;
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat height = frame.size.height - 2*y;
        CGFloat width = (frame.size.width - items.count + 1) / items.count;
        mTitleArray = [items copy];
        mButtonArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0; i < [items count]; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(x + width*i + i, y, width, height)];
            [btn setTitle:[items objectAtIndex:i] forState:UIControlStateNormal];
            [btn setTitleColor:UP_COL_RGB(0x666666) forState:UIControlStateNormal];
            [btn setTitleColor:UP_COL_RGB(0xff6633) forState:UIControlStateHighlighted];
            [btn setTitleColor:UP_COL_RGB(0xff6633) forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            btn.backgroundColor = UP_COL_RGB(0xffffff);
            btn.adjustsImageWhenHighlighted = NO;
            btn.adjustsImageWhenDisabled = NO;
            [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            btn.exclusiveTouch = YES;

            [self addSubview:btn];
            
            [mButtonArray addObject:btn];
        }
        for (int i = 0; i < [mTitleArray count] - 1; i++) {
            UIButton *btn = [mButtonArray objectAtIndex:i];
            x = btn.frame.origin.x + btn.frame.size.width;
            width = 0.5;
            y = 0;
            height = self.frame.size.height - 2 * y;
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            iv.backgroundColor = UP_COL_RGB(0xa9a9a9);
            [self addSubview:iv];
        }
    }
    return self;
}

- (void)setSelectedSegmentIndex:(NSInteger)index
{
    mSelectedIndex = index;
    UIButton* item = [mButtonArray objectAtIndex:index];
    
    [item setSelected:YES];
    
    [delegate segmentedControlAction:index];
}

- (NSInteger)selectedSegmentIndex
{
    return mSelectedIndex;
}

- (void)buttonAction:(id)sender
{
    NSInteger index = 0;
    UIButton* btn = (UIButton*)sender;
    for (int i = 0; i < [mButtonArray count]; i++)
    {
        UIButton* item = [mButtonArray objectAtIndex:i];
        if (btn == item)
        {
            index = i;
        }
        [item setSelected:NO];
    }
    [btn setSelected:YES];
    
    mSelectedIndex = index;
    [delegate segmentedControlAction:index];
}

@end

