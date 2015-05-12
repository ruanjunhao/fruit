//
//  UPLinkView.h
//  CHSP
//
//  Created by wxzhao on 13-1-15.
//
//

#import <UIKit/UIKit.h>

@interface UPWLinkView : UIView

- (void)setText:(NSString*)text alignment:(NSTextAlignment)alignment;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
