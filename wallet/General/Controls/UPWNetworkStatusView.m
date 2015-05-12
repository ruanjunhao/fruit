//
//  UPNetworkStatusView.m
//  CHSP
//
//  Created by TZ_JSKFZX_CAOQ on 13-11-28.
//
//

#import "UPWNetworkStatusView.h"
#import "UPWConst.h"
#import "UPXConstStrings.h"
#import "UPWLoadingView.h"

//#define kUPActivityViewSize CGSizeMake(20,20)

@interface UPWNetworkStatusView()
{
    UPWLoadingView* _loadingView;
    UIImageView* _networkErrorImage;
    UIImageView* _messageErrorImage;
    UILabel* _networkErrorLabel;
    CGFloat _networkErrorLabelWidth;
    UILabel* _messageErrorLabel;
    CGFloat _messageErrorLabelWidth;
    UILabel* _retryLabel;
    CGFloat _retryLabelWidth;
    BOOL    _shouldRetry;
    RetryBlock _retryBlock;
    UITapGestureRecognizer* _tapGr;
}
@end

@implementation UPWNetworkStatusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.hidden = YES;
        
        _networkErrorImage = [[UIImageView alloc] initWithImage:nil];//[UIImage imageNamed:@"list_network_error"]
        [self addSubview:_networkErrorImage];
        
        _messageErrorImage = [[UIImageView alloc] initWithImage:nil];//[UIImage imageNamed:@"list_message_error"]
        [self addSubview:_messageErrorImage];
        
        _networkErrorLabel = [[UILabel alloc] init];
        _networkErrorLabel.backgroundColor = [UIColor clearColor];
        _networkErrorLabel.font = [UIFont systemFontOfSize:round(UPFloat(15))];
        _networkErrorLabel.textColor = UP_COL_RGB(0x999999);
        _networkErrorLabel.alpha = 0.8;
//        _networkErrorLabel.text = UP_STR(@"kStrNetstatusError");
        _networkErrorLabelWidth = [_networkErrorLabel.text sizeWithFont:_networkErrorLabel.font].width;
        [self addSubview:_networkErrorLabel];
        
        _messageErrorLabel = [[UILabel alloc] init];
        _messageErrorLabel.backgroundColor = [UIColor clearColor];
        _messageErrorLabel.font = [UIFont systemFontOfSize:round(UPFloat(14))];
        _messageErrorLabel.textColor = UP_COL_RGB(0x999999);
        _messageErrorLabel.alpha = 0.4;
//        _messageErrorLabel.text = UP_STR(@"kStrSystemError");
        _messageErrorLabelWidth = [_messageErrorLabel.text sizeWithFont:_messageErrorLabel.font].width;
        [self addSubview:_messageErrorLabel];
        
        
        _retryLabel = [[UILabel alloc] init];
        _retryLabel.backgroundColor = [UIColor clearColor];
        _retryLabel.font = [UIFont systemFontOfSize:round(UPFloat(15))];
        _retryLabel.textColor = UP_COL_RGB(0x999999);//UP_COL_RGB(0x158cfb);
        _retryLabel.text = UP_STR(@"kStrTapRetry");
        _retryLabelWidth = [_retryLabel.text sizeWithFont:_retryLabel.font].width;
        [self addSubview:_retryLabel];
        
        _tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retry:)];
        [self addGestureRecognizer:_tapGr];
        
        _retryRect = CGRectZero;
        _shouldRetry = NO;
    }
    return self;
}


- (void)dealloc
{
    [self removeGestureRecognizer:_tapGr];
    self.retryBlock = nil;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* hitResult = [super hitTest:point withEvent:event];
    
    if (CGRectEqualToRect(_retryRect, CGRectZero)) {
        return hitResult;
    }
    
    CGRect touchRect = [self.superview convertRect:_retryRect toView:self];
    if (CGRectContainsPoint(touchRect, point))
        return self;
    else
        return hitResult;
}

- (void)setViewCenter:(CGPoint)viewCenter
{
    if (!CGPointEqualToPoint(viewCenter, _viewCenter)) {
        _viewCenter = viewCenter;
        
        if (CGPointEqualToPoint(_viewCenter, CGPointZero)) {
            return;
        }
        [self setNeedsDisplay];
    }
}

- (void)setNetworkStatus:(UPNetworkStatus)networkStatus
{
    if (_networkStatus != networkStatus) {
        _networkStatus = networkStatus;
        [self handleNetworkStatusChanged];
    }
}


- (void)handleNetworkStatusChanged
{
    switch (self.networkStatus) {
        case UPNetworkStatusSuccess:
        {
            self.hidden = YES;
            [self.superview sendSubviewToBack:self];
            [self hideNetworkFailedPage];
            [self hideNetworkLoadingPage];
            [self hideMessageErrorPage];
        }
            break;
        case UPNetworkStatusFailed:
        {
            if (_retryBlock) {
                self.hidden = NO;
                [self.superview bringSubviewToFront:self];
                [self hideNetworkLoadingPage];
                [self hideMessageErrorPage];
                [self showNetworkFailedPage];
            }
            else{
                self.hidden = YES;
                [self.superview sendSubviewToBack:self];
                [self hideNetworkFailedPage];
                [self hideNetworkLoadingPage];
                [self hideMessageErrorPage];
            }
        }
            break;
        case UPNetworkStatusLoading:
        {
            self.hidden = NO;
            [self.superview bringSubviewToFront:self];
            [self hideNetworkFailedPage];
            [self hideMessageErrorPage];
            [self showNetworkLoadingPage];
        }
            break;
        case UPNetworkStatusMessageError:
        {
            if (_retryBlock) {
                self.hidden = NO;
                [self.superview bringSubviewToFront:self];
                [self hideNetworkFailedPage];
                [self hideNetworkLoadingPage];
                [self showMessageErrorPage];
            }
            else{
                self.hidden = YES;
                [self.superview sendSubviewToBack:self];
                [self hideNetworkFailedPage];
                [self hideNetworkLoadingPage];
                [self hideMessageErrorPage];
            }
        }
            break;
        default:
            break;
    }
}

- (void)showNetworkLoadingPage
{
    CGFloat loadingWidth = UPFloat(50);
    CGFloat loadingHeight = UPFloat(50);
    if (!_loadingView) {
        _loadingView = [[UPWLoadingView alloc] initWithFrame:CGRectMake(_viewCenter.x - loadingWidth/2, 0, loadingWidth, loadingHeight)];
        [self addSubview:_loadingView];
    }
     self.frame = CGRectMake(0, _viewCenter.y - loadingHeight/2, CGRectGetWidth(_retryRect), loadingHeight);
    [_loadingView startAnimation];
}

- (void)showNetworkFailedPage
{
    _shouldRetry = YES;
    
    _networkErrorImage.hidden = NO;
    CGFloat width = _networkErrorImage.image.size.width;
    CGFloat height = _networkErrorImage.image.size.height;
    CGFloat x = _viewCenter.x - width/2;
    //重新加载在 Y 中心

    CGFloat minY = _viewCenter.y - UPFloat(8 + 30 + 14 + 15) - height;

    if (UP_IPHONE4) {
        minY += 44;
    }
    
    _networkErrorImage.frame = CGRectMake(x, 0, width , height);
    
    _networkErrorLabel.hidden = NO;
    x = _viewCenter.x - _networkErrorLabelWidth/2;
    CGFloat y = CGRectGetMaxY(_networkErrorImage.frame) + UPFloat(15);
    _networkErrorLabel.frame = CGRectMake(x, y , _networkErrorLabelWidth, UPFloat(14));
    
    _retryLabel.hidden = NO;
    x = _viewCenter.x - _retryLabelWidth/2;
    y = CGRectGetMaxY(_networkErrorLabel.frame) + UPFloat(30);
    _retryLabel.frame = CGRectMake(x, y, _retryLabelWidth, UPFloat(16));
    

    self.frame = CGRectMake(0, minY,  CGRectGetWidth(_retryRect), CGRectGetMaxY(_retryLabel.frame) - CGRectGetMinY(_networkErrorImage.frame));
    [self setNeedsDisplay];
}

- (void)showMessageErrorPage
{
    _shouldRetry = YES;
    
    _messageErrorImage.hidden = NO;
    CGFloat width = _messageErrorImage.image.size.width;
    CGFloat height = _messageErrorImage.image.size.height;
    CGFloat x = _viewCenter.x - width/2;
    CGFloat minY = _viewCenter.y - height - UPFloat(15);
    _messageErrorImage.frame = CGRectMake(x, 0, width , height);
    
    _messageErrorLabel.hidden = NO;
    x = _viewCenter.x - _messageErrorLabelWidth/2;
    CGFloat y = CGRectGetMaxY(_messageErrorImage.frame) + UPFloat(10);
    _messageErrorLabel.frame = CGRectMake(x, y , _messageErrorLabelWidth, UPFloat(14));
    
    _retryLabel.hidden = NO;
    x = _viewCenter.x - _retryLabelWidth/2;
    y = CGRectGetMaxY(_messageErrorLabel.frame) + UPFloat(5);
    _retryLabel.frame = CGRectMake(x, y, _retryLabelWidth, UPFloat(14));
    self.frame = CGRectMake(0, minY, CGRectGetWidth(_retryRect), CGRectGetMaxY(_retryLabel.frame) - CGRectGetMinY(_networkErrorImage.frame));
    [self setNeedsDisplay];
}


- (void)hideNetworkLoadingPage
{
    if (_loadingView) {
        [_loadingView stopAnimation];
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
}

- (void)hideNetworkFailedPage
{
    _networkErrorImage.hidden = YES;
    _networkErrorLabel.hidden = YES;
    _retryLabel.hidden = YES;
    _shouldRetry = NO;
}

- (void)hideMessageErrorPage
{
    _messageErrorImage.hidden = YES;
    _messageErrorLabel.hidden = YES;
    _retryLabel.hidden = YES;
    _shouldRetry = NO;

}


- (void)retry:(UIGestureRecognizer*)gesture
{
    if(_shouldRetry)
    {
        _retryRect = CGRectZero;
        if (_retryBlock) {
            _retryBlock();
        }
    }
}

@end
