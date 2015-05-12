//
//  UPXClientCryptWrapper.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-7-29.
//
//

#ifndef __UPClientV3__UPXClientCryptWrapper__
#define __UPClientV3__UPXClientCryptWrapper__

#include <iostream>


#include "UPXCryptUtil.h"


class UPXClientCryptWrapper
{
public:
    static UPXClientCryptWrapper* instance();
    void destroy();
    
    void setSessionKey(const char* sessionKey);

    // RSA encrypt sessionKey
    bool rsaEncryptSessionKey( char **szDataOut);
    
    // 3Des encrpt/decrypt message
    bool desEncryptMsg(const char* szDataIn, char** szDataOut);
    bool desDecryptMsg(const char* szDataIn, char** szDataOut);
    
    // SHA
    bool verifySign(const char* szDataIn, const char*sha1Sign);

private:
    UPXClientCryptWrapper();
    ~UPXClientCryptWrapper();
    static UPXClientCryptWrapper *_instance;
    UPXCryptUtil* _cryptUtil;
    char*    _sessionKey;
};





#endif /* defined(__UPClientV3__UPXClientCryptWrapper__) */
