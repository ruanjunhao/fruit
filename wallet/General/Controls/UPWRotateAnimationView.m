//
//  UPRotateAnimationView.m
//  UPWallet
//
//  Created by wxzhao on 14-8-2.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWRotateAnimationView.h"

@interface UPWRotateAnimationView()
{
    UIImage* _image;
    UIImageView* _imageView;
    BOOL _rotating;
}

@end

@implementation UPWRotateAnimationView

@synthesize image = _image;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];

        _rotating = NO;
        _imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:_imageView];
        _imageView.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
    }
    return self;
}


- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setImage:(UIImage*)image
{
    _image = image;
    _imageView.image = image;
}

- (void)startRotating
{
    [self stopRotating];
    
    _rotating = YES;
    _imageView.hidden = NO;

    CATransform3D rotationTransform = CATransform3DMakeRotation(0.5f * M_PI, 0, 0, 1.0);
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
    rotationAnimation.duration = 0.25f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    rotationAnimation.removedOnCompletion = NO;
    [_imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopRotating
{
    _imageView.hidden = YES;
    [_imageView.layer removeAllAnimations];
    _rotating = NO;
}

- (void)applicationWillEnterForeground:(NSNotification*)notification
{
    // 如果正在动画旋转，按home键之后，会导致动画停止，需要监听UIApplicationWillEnterForegroundNotification 重新开始动画
    if (_rotating) {
        [self startRotating];
    }
}

@end
