//
//  UPXFontUtils.h
//  UPClientV3
//
//  Created by Jack on 13-5-23.
//
//

#import <Foundation/Foundation.h>

#define UPFont [UPXFontUtils defaultFont]
#define UPFontWithSize(x) [UPXFontUtils defaultFontWihtSize:x]

@interface UPXFontUtils : NSObject

// 默认字体
+ (UIFont*)defaultFont;
+ (UIFont*)defaultFontWihtSize:(CGFloat)size;
+ (UIFont*)navigationTitleFont;
+ (UIFont*)navigationButtonFont;
+ (UIFont*)commonButtonTitleFont;
+ (UIFont*)smallButtonTitleFont; 
+ (UIFont*)commonTextFieldFont;
+ (UIFont*)alertViewTitleFont;
+ (UIFont*)alertViewMessageFont;
+ (UIFont*)alertViewActivityInfoFont;
+ (UIFont*)homeCellAppNameFont;
+ (UIFont*)remindListFont;


+ (UIFont*)publicPayDetailFont;

+ (UIFont*)publicPayHistoryFont;
+ (UIFont*)publicPayHistoryDetailFont;

+ (UIFont*)publicPayTextFieldFont;

// 成功页 勾选框 的字体
+ (UIFont*)publicPayCheckBoxFont;
// 成功后 分享的 字体
+ (UIFont*)publicPaySharedTextFont;
// 信用卡还款，支持银行列表 的字体
+ (UIFont*)creditCardSupportBankListFont;

// 手机充值 第二个界面 label 字体
+ (UIFont*)mobileCarrierTextSizeFont;

+ (UIFont*)customRightViewFieldTextSizeFont;

//应用中心cell的app名字
+ (UIFont*)appCenterAppNameFont;

//应用中心section header的字体
+ (UIFont*)appCenterSectionTitleFont;


+ (UIFont*)textboxButtonFont;

//系统消息等小图标的字体
+ (UIFont*)badgeTextFont;

// 电子对账单
+ (UIFont *)eBillHeaderDealCountTitleFont;
+ (UIFont *)eBillHeaderDealCountValueFont;
+ (UIFont *)eBillCellCardNumFont;
+ (UIFont *)eBillCellDealCountTitleFont;
+ (UIFont *)eBillCellDealCountValueFont;

// 交易查询 商户名称 字体
+ (UIFont *)queryBillShopNameFont;
+ (UIFont *)queryBillDateFont;
+ (UIFont *)queryBillAmountFont;


@end
