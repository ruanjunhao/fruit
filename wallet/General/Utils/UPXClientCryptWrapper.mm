//
//  UPXClientCryptWrapper.cpp
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-7-29.
//
//

#include "UPXClientCryptWrapper.h"
#include "UPXProguardUtil.h"
#import "UPWEnvMgr.h"


UPXClientCryptWrapper *UPXClientCryptWrapper::_instance = NULL;
UPXClientCryptWrapper* UPXClientCryptWrapper::instance()
{
    if (_instance == NULL) {
        _instance = new UPXClientCryptWrapper();
    }
    return _instance;
}



UPXClientCryptWrapper::UPXClientCryptWrapper()
{
    _cryptUtil = new UPXCryptUtil(48);
    UPXProguardUtil* utl = new UPXProguardUtil(EProjectClientV3);
//    char* decKey = NULL;
//    utl->decryptData([[UPWEnvMgr cryptKey] UTF8String],&decKey);
    _cryptUtil->setPublicKey([[UPWEnvMgr cryptKey] UTF8String]);
//    delete []decKey;
    delete utl;
}


UPXClientCryptWrapper::~UPXClientCryptWrapper()
{
    if (_sessionKey) {
        delete []_sessionKey;
        _sessionKey = NULL;
    }
    delete _cryptUtil;
}

void UPXClientCryptWrapper::destroy()
{
    if (_instance) {
        delete _instance;
        _instance = NULL;
    }
}

void UPXClientCryptWrapper::setSessionKey(const char* sessionKey)
{
//    printf("setSessionKey %s\n",sessionKey);
    _cryptUtil->setSessionKey(sessionKey);
}


bool UPXClientCryptWrapper::rsaEncryptSessionKey( char **szDataOut)
{
    bool ret = false;
    _cryptUtil->randomSessionKey(&_sessionKey);
    //客户度生成TK时候，需是24个字节的，然后前16个字节随机，后8个字节得和前8个字节一致，示例如下
    //前16字节随机：AABBCCDDEEFF00991122334455667788
    //则后8个字节为：AABBCCDDEEFF0099
    //完整TK是：AABBCCDDEEFF00991122334455667788AABBCCDDEEFF0099
    size_t count = strlen(_sessionKey);
    if (count == 48) {
        strncpy(&_sessionKey[32], _sessionKey, 16);
    }
    _cryptUtil->setSessionKey(_sessionKey);
    ret = _cryptUtil->rsaEncryptMsg(_sessionKey, szDataOut);
    delete []_sessionKey;
    _sessionKey = NULL;
    return ret;
}


// 3Des encrpt/decrypt message
bool UPXClientCryptWrapper::desEncryptMsg(const char* szDataIn, char** szDataOut)
{
    return _cryptUtil->desEncryptMsg(szDataIn,szDataOut);
}
bool UPXClientCryptWrapper::desDecryptMsg(const char* szDataIn, char** szDataOut)
{
    return _cryptUtil->desDecryptMsg(szDataIn,szDataOut);
}

// SHA
//bool UPXClientCryptWrapper::verifySign(const char* szDataIn, const char*sha1Sign)
//{
//    const char* sha1_head = "3021300906052B0E03021A05000414";
//    _cryptUtil->setSHA1Head(sha1_head);
//    return _cryptUtil->verifySign(szDataIn,sha1Sign);
//}


