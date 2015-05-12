//
//  UPWSysInitModel.h
//  wallet
//
//  Created by qcao on 14/10/29.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "JSONModel.h"
#import "UPWUpdateInfoModel.h"



@interface UPWSysInitModel : JSONModel

@property (nonatomic,strong) NSString<Optional>* uniIdentifier;
@property (nonatomic,strong) NSString<Optional>* resVersion;
@property (nonatomic,strong) NSString<Optional>* encryptedCk;
@property (nonatomic,strong) NSString<Optional>* vcSwitch;
@property (nonatomic,strong) NSString<Optional>* vid;
@property (nonatomic,strong) NSString<Optional>* confVersion;
@property (nonatomic,strong) NSString<Optional>* baseUrl;
@property (nonatomic,strong) NSString<Optional>* imgFolder;
@property (nonatomic,strong) NSString<Optional>* loginRegex;
@property (nonatomic,strong) NSString<Optional>* rateUrl;
@property (nonatomic,strong) NSString<Optional>* uploadSwitch;
@property (nonatomic,strong) NSString<Optional>* appWebUrl;
@property (nonatomic,strong) UPWUpdateInfoModel<Optional>* updateInfo;



@end


