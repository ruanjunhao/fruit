//
//  UPNetworkStatusView.h
//  CHSP
//
//  Created by TZ_JSKFZX_CAOQ on 13-11-28.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    UPNetworkStatusIdle,
    UPNetworkStatusLoading,
    UPNetworkStatusSuccess,
    UPNetworkStatusFailed,
    UPNetworkStatusMessageError
} UPNetworkStatus;


typedef void (^RetryBlock)(void);


@interface UPWNetworkStatusView : UIView

@property (nonatomic, assign) CGPoint viewCenter;
@property (nonatomic ,assign) UPNetworkStatus networkStatus;
@property (nonatomic ,assign) CGRect retryRect;
@property (nonatomic, copy) RetryBlock retryBlock;

@end