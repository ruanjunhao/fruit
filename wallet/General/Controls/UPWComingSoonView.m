//
//  UPComingSoonView.m
//  CHSP
//
//  Created by TZ_JSKFZX_CAOQ on 13-11-29.
//
//

#import "UPWComingSoonView.h"
#import "UPWConst.h"

@interface UPWComingSoonView()
{
    UIImageView* _imageView;
    UILabel*    _typeLabel;
    UILabel*    _contentLabel;
    UILabel*    _comingSoonLabel;
    CGFloat     _typeLabelWidth;
    CGFloat     _contentLabelWidth;
    CGFloat     _comingSoonLabelWidth;
}

@end

@implementation UPWComingSoonView

@synthesize typeLabel = _typeLabel;
@synthesize contentLabel = _contentLabel;
@synthesize comingSoonLabel = _comingSoonLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.font = [UIFont boldSystemFontOfSize:16];
        _typeLabel.textAlignment = NSTextAlignmentCenter;
        _typeLabel.textColor = UP_COL_RGB(0x424242);
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.textColor = UP_COL_RGB(0x8a8c8e);
        
        
        _comingSoonLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _comingSoonLabel.backgroundColor = [UIColor clearColor];
        _comingSoonLabel.text = UP_STR(@"kStrComingSoon");
        _comingSoonLabel.font = [UIFont systemFontOfSize:14];
        _comingSoonLabel.textAlignment = NSTextAlignmentCenter;
        _comingSoonLabel.textColor = UP_COL_RGB(0x8a8c8e);
        
        
        [self addSubview:_imageView];
        [self addSubview:_typeLabel];
        [self addSubview:_contentLabel];
        [self addSubview:_comingSoonLabel];


    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.image = self.image;
    _typeLabel.text = self.type;
    _contentLabel.text = self.content;
    _typeLabelWidth = [_typeLabel.text sizeWithFont:_typeLabel.font].width;
    _contentLabelWidth = [_contentLabel.text sizeWithFont:_contentLabel.font].width;
    _comingSoonLabelWidth = [_comingSoonLabel.text sizeWithFont:_comingSoonLabel.font].width;
    
    _imageView.frame = CGRectMake(0, 0, 320, 250);
    _typeLabel.frame = CGRectMake(0, 257, 320, 16);
    _contentLabel.frame = CGRectMake(0, 257+27, 320, 14);
    _comingSoonLabel.frame = CGRectMake(0, 257+27+20, 320, 14);
    

}


@end
