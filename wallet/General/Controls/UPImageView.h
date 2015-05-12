//
//  UPImageView.h
//  CHSP
//
//  Created by wxzhao on 12-11-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPImageView : UIView

- (id)initWithFrame:(CGRect)frame;
- (void)setImage:(UIImage*)image;
- (void)setImageWithURL:(NSString*)url;
- (void)setImageWithURL:(NSString *)url withPlaceHolder:(UIImage*)placeholder withFailedImage:(UIImage*)failedimage;

@end
