//
//  UPListNoContentView.m
//  CHSP
//
//  Created by TZ_JSKFZX_CAOQ on 13-11-27.
//
//

#import "UPWListNoContentView.h"
#import "UPWConst.h"

@interface UPWListNoContentView()
{
    UIImageView* _imageView;
    UILabel*    _titleLabel;
    UILabel*    _contentLabel;
    CGFloat     _titleWidth;
    CGFloat     _contentWidth;
}
@end


@implementation UPWListNoContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        
        // Initialization code
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.image = nil;//[UIImage imageNamed:@"list_no_content"];
        _imageView.userInteractionEnabled = NO;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = UP_STR(@"kStrNoContent");
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = UP_COL_RGB(0x999999);
        //        _titleLabel.alpha = 0.8;
        _titleWidth = [_titleLabel.text sizeWithFont:_titleLabel.font].width;
        _titleLabel.userInteractionEnabled = NO;
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.backgroundColor = [UIColor clearColor];
        // _contentLabel.text = KSTR_WORK_HARD;
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textColor = UP_COL_RGB(0x999999);
        //        _contentLabel.alpha = 0.4;
        _contentWidth = [_contentLabel.text sizeWithFont:_contentLabel.font].width;
        _contentLabel.userInteractionEnabled = NO;
        
        [self addSubview:_imageView];
        [self addSubview:_titleLabel];
        [self addSubview:_contentLabel];
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    if (image == nil) {
        _imageView.image = nil;
    } else if (_image != image) {
        _imageView.image = image;
    }
}

- (void)setTitle:(NSString *)title
{
    if (title == nil) {
        _titleLabel.text = nil;
    } else if (![_title isEqualToString:title]) {
        _title = [title copy];
        _titleLabel.text = title;
        _titleWidth = [_titleLabel.text sizeWithFont:_titleLabel.font].width;
    }
}

- (void)setContent:(NSString *)content
{
    if (content == nil) {
        _contentLabel.text = nil;
    } else if (![_content isEqualToString:content]) {
        _content = [content copy];
        _contentLabel.text = content;
        _contentWidth = [_contentLabel.text sizeWithFont:_contentLabel.font].width;
    }
}

- (void)setListCenter:(CGPoint)listCenter
{
    
    //    if (!CGPointEqualToPoint(listCenter, _listCenter)) {
    _listCenter = listCenter;
    
    if (CGPointEqualToPoint(_listCenter, CGPointZero)) {
        return;
    }
    
    CGFloat width = _imageView.image.size.width;
    CGFloat height = _imageView.image.size.height;
    CGFloat x = _listCenter.x - width/2;
    CGFloat minY = _listCenter.y - height -5;
    _imageView.frame = CGRectMake(x, 0, width , height);
    x = _listCenter.x - _titleWidth/2;
    CGFloat y = CGRectGetMaxY(_imageView.frame) + 10;
    _titleLabel.frame = CGRectMake(x, y , _titleWidth, 15);
    x = _listCenter.x - _contentWidth/2;
    y = CGRectGetMaxY(_titleLabel.frame) + 5;
    _contentLabel.frame = CGRectMake(x, y, _contentWidth, 15);
    self.frame = CGRectMake(0, minY, 320, y - CGRectGetMinY(_imageView.frame));
    [self setNeedsDisplay];
    //    }
}

@end