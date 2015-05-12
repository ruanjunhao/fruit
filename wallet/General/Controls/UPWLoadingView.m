//
//  UPWLoadingView.m
//  wallet
//
//  Created by qcao on 14/10/22.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWLoadingView.h"
#import "UPWRotateAnimationView.h"

@interface UPWLoadingView()
{
    UPWRotateAnimationView* _rotateView;
}
@end

@implementation UPWLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];//[UIColor colorWithWhite:0.0 alpha:0.04];
        self.layer.cornerRadius  = 3.0;
        
        UIImage* loading = UP_GETIMG(@"icon_activity");
        _rotateView = [[UPWRotateAnimationView alloc] initWithFrame:CGRectMake((frame.size.width - loading.size.width)/2, (frame.size.height - loading.size.height)/2, loading.size.width, loading.size.height)];
        _rotateView.image = loading;
        [self addSubview:_rotateView];

    }
    return self;
    
}

- (void)startAnimation
{
    [_rotateView startRotating];
}

- (void)stopAnimation
{
    [_rotateView stopRotating];
}

@end
