
#import <UIKit/UIKit.h>

@interface UPWCPageControl : UIControl
{
}

- (id)initWithFrame:(CGRect)frame;


@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, assign) BOOL hidesForSinglePage;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,retain) UIImage* normalDotImage;
@property (nonatomic,retain) UIImage* highlightDotImage;

@end
