//
//  UPPlaceholderTextView.h
//  Test
//
//  Created by lu on 13-5-30.
//  Copyright (c) 2013年 lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPWPlaceholderTextView : UITextView

/**
 The string that is displayed when there is no other text in the text view.
 
 The default value is `nil`.
 */
@property (nonatomic, retain) NSString *placeholder;

/**
 The color of the placeholder.
 
 The default is `[UIColor lightGrayColor]`.
 */
@property (nonatomic, retain) UIColor *placeholderColor;

@end

