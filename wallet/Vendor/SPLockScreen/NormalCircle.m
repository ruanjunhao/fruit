//
//  NormalCircle.m
//  SuQian
//
//  Created by Suraj on 24/9/12.
//  Copyright (c) 2012 Suraj. All rights reserved.
//

#import "NormalCircle.h"
#import <QuartzCore/QuartzCore.h>

#define kOuterColor         UP_COL_RGB(0xd7dde3)
#define kInnerColor		    [UIColor clearColor] 
#define kHighlightColor     [UIColor clearColor]

@implementation NormalCircle
@synthesize selected,cacheContext;

- (id)initWithFrame:(CGRect)frame
{
    
	self = [super initWithFrame:frame];
	if (self) {
        _highlightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [_highlightImageView setBackgroundColor:[UIColor clearColor]];
        [_highlightImageView setUserInteractionEnabled:YES];
        [_highlightImageView setImage:[UIImage imageNamed:@"lock_point"]];
        [self addSubview:_highlightImageView];
        _highlightImageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [_highlightImageView setHidden:YES];
	}
	return self;
}

- (id)initwithRadius:(CGFloat)radius
{
	CGRect frame = CGRectMake(0, 0, 2*radius, 2*radius);
	NormalCircle *circle = [self initWithFrame:frame];
	if (circle) {
        [circle setBackgroundColor:[UIColor clearColor]];
	}
	return circle;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	self.cacheContext = context;
	CGFloat lineWidth = 0.9;
	CGRect rectToDraw = CGRectMake(rect.origin.x+lineWidth, rect.origin.y+lineWidth, rect.size.width-2*lineWidth, rect.size.height-2*lineWidth);
	CGContextSetLineWidth(context, lineWidth);
	CGContextSetStrokeColorWithColor(context, kOuterColor.CGColor);
	CGContextStrokeEllipseInRect(context, rectToDraw);
	
	// Fill inner part
	CGRect innerRect = CGRectInset(rectToDraw,1, 1);
	CGContextSetFillColorWithColor(context, kInnerColor.CGColor);
	CGContextFillEllipseInRect(context, innerRect);
	
	if(self.selected == NO)
		return;
	
	// For selected View
	CGRect smallerRect = CGRectInset(rectToDraw,10, 10);
	CGContextSetFillColorWithColor(context, kHighlightColor.CGColor);
	CGContextFillEllipseInRect(context, smallerRect);
}

- (void)highlightCell
{
	self.selected = YES;
    [_highlightImageView setHidden:NO];
	[self setNeedsDisplay];
}

- (void)resetCell
{
	self.selected = NO;
    [_highlightImageView setHidden:YES];
	[self setNeedsDisplay];
}


@end
