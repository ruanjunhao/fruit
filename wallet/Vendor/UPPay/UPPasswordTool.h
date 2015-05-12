//
//  UPChannelExpress.h
//  UPChannelExpress
//
//  Created by wxzhao on 12-9-4.
//  Copyright (c) 2012年 China UnionPay. All rights reserved.
//

#ifndef __UPPASSWORDTOOL_H__
#define __UPPASSWORDTOOL_H__
#include "UPXPasswordUtil.h"
#include "UPXProguardUtil.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

class UPPasswordTool
{

private:
    UPXProguardUtil *_proguardUtil;
    UPXPasswordUtil *_passwordUtil;
    bool _testMode;
    
private:
    void getPublicKeyForPinBlock(char **publicKey);
    void getProductPublicKey(char **publicKey);
    void getTestPublicKey(char **publicKey);
    void getPinBlockPublicKeyWithModulues(const char *modulues1, const char *modulues2, const char *modulues3, const char *modulues4, const char *modulues5, const char *modulues6, char **PublicKey);
    
    
    
public:
    UPPasswordTool(bool testMode);
    ~UPPasswordTool();
    
    // 删除一个PIN
    void deleteOnePin();
    
    // 增加一个PIN
    void appendOnePin(const char *pin);
    
    // 清除所有PIN
    void clearAllPin();
    
    // 获取加密后的PINBLOCK
    void startEncryptPinBlock(const char *pan, char **encryptedPinBlock);
    
    // 获取明文PIN
    void getPin(char **pin);
};
#else
#endif
