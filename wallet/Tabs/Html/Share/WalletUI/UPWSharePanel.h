//
//  UpNewShareView.h
//  CHSP
//
//  Created by jhyu on 13-11-6.
//
//

#import <UIKit/UIKit.h>

/*! @brief 分享类型
 */
typedef NS_OPTIONS(NSUInteger, UPShareType) {
    UPWeiXin = 0x1,
    UPWeiXinGroup = 0x2,
    UPSinaWeiBo = 0x4,
    UPSMS = 0x8
};

@class UPShareContent;

@protocol UPWSharePanelDelegate <NSObject>

- (void)didSelectShareType:(UPShareType)shareType;

@end

@interface UPWSharePanel : NSObject {
    // 方便子类继承
    UIView* _overlayView;
}

@property (nonatomic, weak) id<UPWSharePanelDelegate> delegate;
@property (nonatomic, copy, readonly) NSArray * channels;

+ (BOOL)isAvailableForShare;
- (id)initWithTitle:(NSString *)title;

- (void)show;
// 子类可以重载
- (void)dismiss;

@end
