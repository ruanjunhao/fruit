//
//  UPLinkLabel.m
//  UPWallet
//
//  Created by wxzhao on 14-7-14.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWLinkLabel.h"

@implementation UPWLinkLabel

@synthesize text;
@synthesize linkText;
@synthesize linkContent;
@synthesize textCenter;
@synthesize deleagate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    UIFont* font = [UIFont systemFontOfSize:14];
    CGSize textSize = [self.text sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 0.0) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize linkSize = [self.linkText sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 0.0) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat textHeight = [self.linkText sizeWithFont:font
                          constrainedToSize:CGSizeMake(100.0, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping].height;

    
    CGFloat offsetX = 0;
    if (self.textCenter)
    {
        offsetX = (self.frame.size.width - (textSize.width + linkSize.width))/2;
    }
    offsetX = MAX(0.0f, offsetX);
    CGFloat offsetY = (self.frame.size.height - textHeight)/2;
    
    UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, offsetY, textSize.width, textHeight)];
    textLabel.text = self.text;
    textLabel.font = font;
    textLabel.textColor = [UIColor blackColor];
    textLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:textLabel];
    
    UIButton* linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    linkButton.frame = CGRectMake(CGRectGetMaxX(textLabel.frame), 1, linkSize.width, self.frame.size.height);
    [linkButton setTitle:self.linkText forState:UIControlStateNormal];
    linkButton.titleLabel.font = font;
    linkButton.titleLabel.textColor = UP_COL_RGB(0xc5c5c5);
    linkButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [linkButton setTitleColor:UP_COL_RGB(0xc5c5c5) forState:UIControlStateNormal];
    
    [linkButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:linkButton];
}


- (void)buttonAction:(id)sender
{
    if (self.deleagate) {
        [self.deleagate didSelectLinkLabel:self content:self.linkContent];
    }
}

@end
