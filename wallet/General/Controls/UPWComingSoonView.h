//
//  UPComingSoonView.h
//  CHSP
//
//  Created by TZ_JSKFZX_CAOQ on 13-11-29.
//
//

#import <UIKit/UIKit.h>

@interface UPWComingSoonView : UIView

@property (nonatomic, copy) NSString* type;
@property (nonatomic, copy) NSString* content;
@property (nonatomic, retain) UIImage* image;

@property (nonatomic, strong) UILabel* typeLabel;
@property (nonatomic, strong) UILabel* contentLabel;
@property (nonatomic, strong) UILabel* comingSoonLabel;

@end
