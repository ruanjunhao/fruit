//
//  UPLinkView.m
//  CHSP
//
//  Created by wxzhao on 13-1-15.
//
//

#import "UPWLinkView.h"

@implementation UPWLinkView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        label.textColor = UP_COL_RGB(0x008aff);
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.tag = 100;
        [label setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:label];
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 200;
        btn.backgroundColor = [UIColor clearColor];
        [btn setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:btn];
    }
    return self;
}

/*
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context    = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);
    
    UILabel* label = (UILabel*)[self viewWithTag:100];
    CGSize size = [label.text sizeWithFont:label.font];
    float start = (self.frame.size.width - size.width) * 0.5f;
    float end = start + size.width;
    CGContextMoveToPoint(context, start,self.frame.size.height); //start at this point
    
    CGContextAddLineToPoint(context, end, self.frame.size.height); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
}
*/

- (void)setText:(NSString *)text alignment:(NSTextAlignment)alignment
{
    UILabel* label = (UILabel*)[self viewWithTag:100];
    [label setText:text];
    label.textAlignment = alignment;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    UIButton* btn = (UIButton*)[self viewWithTag:200];
    [btn addTarget:target action:action forControlEvents:controlEvents];
}

@end
