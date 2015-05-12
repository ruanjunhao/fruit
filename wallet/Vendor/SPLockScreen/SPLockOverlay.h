//
//  SPLockOverlay.h
//  SuQian
//
//  Created by Suraj on 25/9/12.
//  Copyright (c) 2012 Suraj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPLine.h"

typedef enum
{
    setLay = 20,
    wrongWayLay
}LayStyle;

@interface SPLockOverlay : UIView

@property (nonatomic, strong) NSMutableArray *pointsToDraw;
@property (nonatomic) LayStyle layType;


@end
