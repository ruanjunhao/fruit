//
//  UPImageView.m
//  CHSP
//
//  Created by wxzhao on 12-11-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UPImageView.h"
#import "UIImageView+WebCache.h"
#import "UPWEnvMgr.h"
#import "UPWBussUtil.h"

@interface UPImageView () {
    UIImageView* mImageView;
}
@end

@implementation UPImageView

- (void)dealloc
{
    mImageView = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:mImageView];
        
        self.layer.cornerRadius = 3.0f;
        self.layer.masksToBounds = YES;
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    mImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setImage:(UIImage*)image
{
    mImageView.image = image;
}

- (void)setImageWithURL:(NSString*)url
{
    return [self setImageWithURL:url withPlaceHolder:nil withFailedImage:nil];
}

- (void)setImageWithURL:(NSString *)url withPlaceHolder:(UIImage*)placeholder withFailedImage:(UIImage*)failedimage
{
    if([UPWAppUtil isEmpty:url]) {
        mImageView.image = placeholder;
        return;
    }
    
    NSString *fullUrl = nil;
    if ([UPWBussUtil isWebFullUrl:url]) {
        fullUrl = url;
    } else {
        fullUrl = [NSString stringWithFormat:@"%@/%@", [UPWEnvMgr chspImgServerUrl], url];
    }
    
    UIActivityIndicatorView * aiv;
    if(placeholder) {
        mImageView.image = placeholder;
    }
    else {
        aiv = [self createActivityIndicatorView];
        [self addSubview:aiv];
    }
    
     __block UPImageView * __weak wself = self;
    [mImageView setImageWithURL:[NSURL URLWithString:fullUrl] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if(!wself) {
            return;
        }
        [aiv stopAnimating];
        if (error) {
            if(failedimage) {
                UIImageView * myImageView = [wself myImageView];
                myImageView.image = failedimage;
            }
        }
    }];
}

- (UIImageView *)myImageView
{
    return mImageView;
}

- (UIActivityIndicatorView *)createActivityIndicatorView
{
    UIActivityIndicatorView * aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = self.frame;
    int w = 20;
    aiv.frame = CGRectMake((frame.size.width - w)/2, (frame.size.height - w)/2, w, w);
    [aiv startAnimating];
    
    return aiv;
}

@end
