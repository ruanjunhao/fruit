//
//  UPCityModel.h
//  UPWallet
//
//  Created by wxzhao on 14-7-19.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "JSONModel.h"

@interface UPWCityModel : JSONModel

@property (nonatomic,strong) NSString<Optional>* cityCd;
@property (nonatomic,strong) NSString<Optional>* cityEnNm;
@property (nonatomic,strong) NSString<Optional>* cityNm;
@property (nonatomic,strong) NSString<Optional>* firstLetter;
@property (nonatomic,strong) NSString<Optional>* validIn;

//三个字城市名
- (NSString*)threeCityName;

@end
