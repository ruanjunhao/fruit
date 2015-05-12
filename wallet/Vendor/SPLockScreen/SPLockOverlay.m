//
//  SPLockOverlay.m
//  SuQian
//
//  Created by Suraj on 25/9/12.
//  Copyright (c) 2012 Suraj. All rights reserved.
//

#import "SPLockOverlay.h"

#define kLineColor			UP_COL_RGB(0xffffff)
#define kLineGridColor      UP_COL_RGB(0xffffff)
#define kLineRedColor       UP_COL_RGB(0xFA5258)

@implementation SPLockOverlay

@synthesize pointsToDraw,layType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
			self.backgroundColor = [UIColor clearColor];
			self.pointsToDraw = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIColor *dotColor,*lineColor;
    
    if (self.layType == setLay)
    {
        lineColor = kLineColor;
        dotColor = kLineGridColor;
    }
    else
    {
        lineColor = kLineRedColor;
        dotColor = kLineRedColor;
    }
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat lineWidth = 2.0;
	
	CGContextSetLineWidth(context, lineWidth);
	CGContextSetStrokeColorWithColor(context, dotColor.CGColor);
    for(SPLine *line in self.pointsToDraw)
    {
        CGContextMoveToPoint(context, line.fromPoint.x, line.fromPoint.y);
        CGContextAddLineToPoint(context, line.toPoint.x, line.toPoint.y);
        CGContextStrokePath(context);
        
        CGFloat nodeRadius = 12.0;
        
        CGRect fromBubbleFrame = CGRectMake(line.fromPoint.x- nodeRadius/2, line.fromPoint.y - nodeRadius/2, nodeRadius, nodeRadius);
        CGContextSetFillColorWithColor(context, lineColor.CGColor);
        CGContextFillEllipseInRect(context, fromBubbleFrame);
        
        if(line.isFullLength)
        {
            CGRect toBubbleFrame = CGRectMake(line.toPoint.x - nodeRadius/2, line.toPoint.y - nodeRadius/2, nodeRadius, nodeRadius);
            CGContextFillEllipseInRect(context, toBubbleFrame);
        }
    }
}

@end
