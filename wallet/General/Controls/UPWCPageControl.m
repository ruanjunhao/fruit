
#import "UPWCPageControl.h"

@interface UPWCPageControl()
{
    NSInteger _currentPage;
    NSUInteger _numberOfPages;
    UIImage*   _normalDotImage;
    UIImage*   _highlightDotImage;
}

@end

@implementation UPWCPageControl

@synthesize numberOfPages = _numberOfPages;
@synthesize hidesForSinglePage = _hidesForSinglePage;
@synthesize currentPage = _currentPage;
@synthesize normalDotImage = _normalDotImage;
@synthesize highlightDotImage = _highlightDotImage;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code.
        self.hidesForSinglePage = YES;
        // make sure the view is redrawn not scaled when the device is rotated
        self.contentMode = UIViewContentModeRedraw;

    }
    return self;
}


- (void)dealloc
{
   
}

- (void)drawRect:(CGRect)rect
{
    UIImage *image;
    if (!_normalDotImage || !_highlightDotImage ) {
        return;
    }
    int  i;
    CGRect  rt;
    const CGFloat kSpacing = 15.0;
    rect = self.bounds;
    
    if ( self.opaque ) {
        [self.backgroundColor set];
        UIRectFill( rect );
    }
    
    if ( self.hidesForSinglePage && self.numberOfPages == 1 )
    {
        return;
    }
    
    rt.size.height = _highlightDotImage.size.height;
    rt.size.width = self.numberOfPages * _highlightDotImage.size.width + ( self.numberOfPages - 1 ) * kSpacing;
    rt.origin.x = floorf( ( rect.size.width - rt.size.width ) / 2.0 );
    rt.origin.y = floorf( ( rect.size.height - rt.size.height ) / 2.0 );
    rt.size.width = _highlightDotImage.size.width;
    
    for ( i = 0; i < self.numberOfPages; ++i ) {
        image = i == self.currentPage ? _highlightDotImage : _normalDotImage;
        [image drawInRect: rt];
        rt.origin.x += _highlightDotImage.size.width + kSpacing;
    }
}

- (void) setCurrentPage:(NSInteger)page
{
    _currentPage = page;
    [self setNeedsDisplay];
}

- (void) setNumberOfPages:(NSUInteger) number
{
    _numberOfPages = number;
    [self setNeedsDisplay];
}


@end
