//
//  UPXCryptUtil.h
//  UPXCryptUtil
//
//  Created by wxzhao on 12-9-4.
//  Copyright (c) 2012年 China UnionPay. All rights reserved.
//


#ifndef __UPXCryptUtil_H__
#define __UPXCryptUtil_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define  kKeyLength         32

class UPXCryptUtil
{
private:
    int _sessionKeyLength;
    char *_sessionKey;
    char* _publicKey;
    char* _sha1Head;
    
    

public:
    UPXCryptUtil();
    
    // 设置key长度
    UPXCryptUtil(int keyLen);
    
    ~UPXCryptUtil();
    
    // random 3DES session key
    void randomSessionKey(char** szDataOut);

    // set 3DES sesssion key
    void setSessionKey(const char* sessionKey);
    
    // set RSA public key
    void setPublicKey(const char* publicKey);
    
    // set sha1 head
    void setSHA1Head(const char* sha1Head);
    
    // RSA encrypt sessionKey
    bool rsaEncryptMsg(const char* szDataIn, char** szDataOut);
    
    // 3Des encrpt/decrypt message
    bool desEncryptMsg(const char* szDataIn, char** szDataOut);
    bool desDecryptMsg(const char* szDataIn, char** szDataOut);
    
};

#endif

