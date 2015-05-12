//
//  UPWSharePanel.m
//  CHSP
//
//  Created by jhyu on 14-7-18.
//
//

#import "UPWLightGridView.h"
#import "UPWSharePanel.h"
#import "UPWWebUtility.h"
#import "UPWUiUtil.h"

#define kMaxIconsPerRow             4

#define kGridWidth           60.0f
#define kGridHeight          80.0f
#define kBtnHeight           44.0f
#define xMargin              15.0f

@interface UPWSharePanel () <UPWLightGridViewDataSource, UPWLightGridViewDelegate> {
    UPWLightGridView*  _gridView;
}

@property (nonatomic, copy) NSString*  title;
@property (nonatomic, copy, readwrite) NSArray* channels;

@end

#pragma mark -
#pragma mark - Class UPWSharePanel implementation

@implementation UPWSharePanel

#pragma mark -
#pragma mark - Public methods

+ (BOOL)isAvailableForShare
{
    return ([UPWWebUtility shareChannels].count > 0);
}

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if(self) {
        _channels = [UPWWebUtility shareChannels];
        _title = [title copy];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)show
{
    [UPWDataCollectMgr upTrackPageBegin:@"ShareView"];

    // 创建当前显示蒙罩View.
    CGFloat offset = 43;
    _overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _overlayView.backgroundColor = UP_COL_RGBA(UP_BLACK_MASK);
    
    CGRect rc = _overlayView.bounds;
    rc.origin.y = offset;
    rc.size.height = 24;
    UILabel * label = [[UILabel alloc] initWithFrame:rc];
    label.text = _title;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20.0f];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    [_overlayView addSubview:label];
    
    CGRect rcLine = CGRectZero;
    rcLine.origin = CGPointMake(15.0f, CGRectGetMaxY(label.frame) + 21.0f);
    rcLine.size.width = CGRectGetMaxX(_overlayView.bounds) - 2 * rcLine.origin.x;
    rcLine.size.height = 1.0f;
    UIView * line = [UPWUiUtil createGreyLineViewWithRect:rcLine];
    [_overlayView addSubview:line];
    
    // 分享类型按钮
    CGRect rcGrid = _overlayView.bounds;
    rcGrid.size.height = kGridHeight;
    rcGrid.origin.y = CGRectGetMinY(line.frame) + 110.0f;
    _gridView = [[UPWLightGridView alloc] initWithFrame:rcGrid];
    _gridView.customDataSource = self;
    _gridView.customDelegate = self;
    [_overlayView addSubview:_gridView];
    
    // 取消按钮
    CGRect rcBtn = _overlayView.bounds;
    rcBtn.size.height = kBtnHeight;
    rcBtn.origin.y = CGRectGetMaxY(_overlayView.bounds) - rcBtn.size.height - offset;
    rcBtn.size.width = rcBtn.size.height;
    rcBtn.origin.x = (_overlayView.bounds.size.width - rcBtn.size.width) / 2;
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = rcBtn;
    [cancelBtn setImage:UP_GETIMG(@"share_close") forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(dismissShareView:) forControlEvents:UIControlEventTouchUpInside];
    [_overlayView addSubview:cancelBtn];
    
    [UPWUiUtil showOverlayView:_overlayView animatedByContentView:nil];
}

#pragma mark - Action & Event

- (void)dismissShareView:(id)sender
{
    [UPWDataCollectMgr upTrackPageEnd:@"ShareView"];
    [self dismiss];
}

- (void)dismiss
{
    [UPWUiUtil dismissOverlayViewAnimated:_overlayView];
}

#pragma mark -
#pragma mark UPLightGridViewDatasource

- (NSInteger)countOfCellForLightGridView:(UPWLightGridView*)gridView
{
    return [self.channels count];
}

- (NSInteger)columnNumberForLightGridView:(UPWLightGridView*)gridView
{
    return kMaxIconsPerRow;
}

/*
 * Icons排版需求：
 * 1. 一版最多四个，若分享渠道>=4, 则按左边界对齐。
 * 2. 若分享渠道<4, 则居中对齐。
 *
 */
- (CGFloat)borderMarginForLightGridView:(UPWLightGridView*)gridView
{
    CGFloat margin = xMargin; // case #1
    if(self.channels.count < kMaxIconsPerRow) {
        // case #2
        margin = [self innerMarginForLightGridView:gridView];
    }
    
    return margin;
}

- (CGFloat)innerMarginForLightGridView:(UPWLightGridView *)gridView
{
    CGFloat margin;
    if(self.channels.count < kMaxIconsPerRow) {
        // case #2, 居中对齐
        margin = (_gridView.bounds.size.width - self.channels.count * kGridWidth) / (self.channels.count + 1);
    }
    else {
        // case #1, 左对齐
        margin = (_gridView.bounds.size.width - 2 * xMargin - kMaxIconsPerRow * kGridWidth) / (kMaxIconsPerRow - 1);
    }
    
    return margin;
    
}

- (CGSize)itemSizeForLightGridView:(UPWLightGridView*)gridView
{
    return CGSizeMake(kGridWidth, kGridHeight);
}

- (UIControl*)lightGridView:(UPWLightGridView*)gridView cellAtIndex:(NSInteger)index
{
    if(index >= self.channels.count) {
        // Overflow.
        return nil;
    }
    
    NSString* imageNamed;
    NSString* title;
    
    switch ([self.channels[index] integerValue]) {
        case UPWeiXin:
            imageNamed = @"weixin";
            title = UP_STR(@"kStrWeixin") ;
            break;
        
        case UPWeiXinGroup:
            imageNamed = @"weixinGroup";
            title = UP_STR(@"kStrWeixinGroup");
            break;
            
        case UPSinaWeiBo:
            imageNamed = @"weibo";
            title = UP_STR(@"kStrSinaWeibo");
            break;
            
        case UPSMS:
            imageNamed = @"sms";
            title = UP_STR(@"kStrSms");
            break;
            
        default:
            break;
    }
    
    UIControl* gridViewCell = [[UIControl alloc] init];
    gridViewCell.backgroundColor = [UIColor clearColor];
    
    UIImage * image = [UIImage imageNamed:imageNamed];
    CGRect rcImage = CGRectZero;
    rcImage.size = image.size;
    rcImage.origin.x = (kGridWidth - rcImage.size.width) / 2;
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:rcImage];
    imageView.image = image;
    [gridViewCell addSubview:imageView];
    
    CGRect rcTitle = rcImage;
    rcTitle.origin.y = CGRectGetMaxY(rcImage) + 8.0f;
    rcTitle.size.height = kGridHeight - rcTitle.origin.y;
    UILabel* label = [[UILabel alloc] initWithFrame:rcTitle];
    label.textColor = UP_COL_RGB(0xC3C3C3);
    label.font = [UIFont systemFontOfSize:13.0f];
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [gridViewCell addSubview:label];
    
    return gridViewCell;
}

#pragma mark - UPLightGridViewDelegate

- (void)lightGridView:(UPWLightGridView*)lightGridView didSelectAtIndex:(NSInteger)index cell:(UIControl *)cell
{
    if(index >= self.channels.count) {
        // Empty grid.
        return;
    }
    
    UPShareType eType = [self.channels[index] integerValue];
    [self.delegate didSelectShareType:eType];
    [self dismissShareView:nil];
}

@end



