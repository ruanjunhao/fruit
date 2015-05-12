/*
*
* Create by zhaogq on 2011-09-20, from risetek
*
* Copyright 2011. All rights reserved.
*
* UPCard 应用接口
*
*/
#ifndef __UPHEXCODE_H__
#define __UPHEXCODE_H__

namespace UPClientV3Ex
{
#ifdef __cplusplus 
extern "C" { 
#endif 


#ifndef NULL
#define NULL 0
#endif

/**
 * HEX解码 将形如0x12 0x2A 0x01 转换为122A01
 */
int UPXHexDecode(const unsigned char *szIn ,int len, char **szOut);

/**
 * HEX编码 将形如122A01 转换为0x12 0x2A 0x01
 */
int UPXHexEncode(const char* szIn, const int len, unsigned char **szOut);


#ifdef __cplusplus 
}
#endif 

}
    
#endif