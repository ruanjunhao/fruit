//
//  UPXConstReg.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-6-5.
//
//

/*
 用来保存正则表达式常量
 
 */


/* 正则表达式 */

//注册用户名验证的邮箱正则
#define kRegisterEmailPredicate @"(?=.{0,64})\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"
//注册用户名验证的手机号正则
#define kRegisterPhoneNumberPredicate @"1\\d{10}"
//注册用户名验证的自定义用户名正则
#define kRegisterCustomNamePredicate @"^\\w*[a-zA-Z_]+\\w*$"
//登录用户名验证的自定义用户名正则
#define kLoginCustomNamePredicate @"([\\w\\d]{6,20})"
//信用卡 号 校验
#define kCreditCardPredicate @"\\d{13,19}"
// 信用卡 卡号 输入时 校验0-19位数字
#define kCreditCardInputPredicate @"[0-9]{0,19}"
// 信用卡 有效期校验
#define kCreditCardValidity @"[0-9]{4}"
// 信用卡 cvn2 校验
#define kCreditCardCVN2Predicate @"[0-9]{3}"
// 信用卡密码 校验
#define kCredicCardPasswordPredicate @"[0-9]{6}"

// 短信验证码 校验
#define kSMSCodePredicate @"[0-9]{6}"


// 数字 金额 校验 @"^[0-9]+(.|.[0-9]{1,2})?$"
#define kAmountPredicate @"^[0-9]+(\\.|\\.[0-9]{1,2})?$"
#define kAmountPredicateOnlyPoint @"(\\.|\\e.[0-9]{1,2})?$"

// 安全问题及答案
#define kSecurityQuestionPredicate @"[^!$%\\^&*?<>]{2,16}"

// 密码全为数字
#define kAllCharacterIsNumber @"\\d*"

// 密码全为字母
#define kAllCharacterIsLetter @"[a-zA-Z]*"

// 用户真实姓名
#define kRealNamePredicate @"[^!$%\\^&*?<>]{2,10}"

// 用户地址
#define kAddressPredicate @"[^!$%\\^&*?<>]*"

// 邮政编码
#define kPostcodePredicate @"\\d{6}"


// 图片验证码 4位数字校验
#define kImageCodePredicate @"[0-9]{0,4}"

#define ValidPhoneNumberLength 11

// 信用卡 卡号分割
#define kSeperatorCreditCardNumber @"4"
// 手机号 分割
#define kSeperatorMobileNumber @"3,4"
// 通用号码校验
#define kTelAndPhoneNumber      @"^[0-9*#,;+-]+$"

// 手机号 输入时 校验0-11位数字
#define kMobleNumInputPredicate @"[0-9]{0,11}"

