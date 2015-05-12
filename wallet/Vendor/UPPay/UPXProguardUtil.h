//
//  UPXProguardUtil.h
//  UPCryptDemo
//
//  Created by wxzhao on 13-7-26.
//  Copyright (c) 2013年 wxzhao. All rights reserved.
//

#ifndef __UPXProguardUtil__
#define __UPXProguardUtil__

typedef enum{
    EProjectPlugin,
    EProjectClientV3,
    EProjectWallet,
    EProjectTSM,
    EProjectNone
}EProject;

class UPXProguardUtil
{
private:
    EProject _project;
    
public:
    UPXProguardUtil(EProject project);
    ~UPXProguardUtil();
    
    // 从对称密钥池里面生成用于加密公钥的对称密钥
    void proguardSeed(char** szOut);

    /*
     3Des加密公钥，加密后的公钥保存在C代码中，以防止UltraEdit直接修改公钥;
     此函数不会被APP调用，只当作工具函数使用
     */
    void encryptData(const char* data, char** encData);
    void decryptData(const char* data, char** decData);
};
#else
#endif 
