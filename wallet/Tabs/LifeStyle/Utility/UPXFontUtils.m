//
//  UPXFontUtils.m
//  UPClientV3
//
//  Created by Jack on 13-5-23.
//
//

#import "UPXFontUtils.h"
#import "UPXConstFont.h"

@implementation UPXFontUtils

+ (UIFont*)defaultFontWihtSize:(CGFloat)size
{
    return [UIFont systemFontOfSize:size];
}

+ (UIFont*)defaultFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontSmallSize];
}

+ (UIFont*)navigationTitleFont
{
    return [UIFont boldSystemFontOfSize:kFontNavigationTitle];
}


+ (UIFont*)navigationButtonFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontNavigationButton];
}

+ (UIFont*)commonButtonTitleFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontCommonButtonTitleSize];
}


+ (UIFont*)smallButtonTitleFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontSmallButtonTitleSize];
}


+ (UIFont*)commonTextFieldFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontCommonTextFieldSize];
}

+ (UIFont*)alertViewTitleFont
{
    return [UIFont boldSystemFontOfSize:kFontAlertViewTitleSize];
}

+ (UIFont*)alertViewMessageFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontAlertViewMessageSize];
    
}

+ (UIFont*)alertViewActivityInfoFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontSlertViewActivityInfoSize];
}

+ (UIFont*)homeCellAppNameFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontHomeCellAppNameSize];
}

+ (UIFont*)remindListFont
{
    return [UPXFontUtils defaultFontWihtSize:16];
    
}


+ (UIFont*)publicPayDetailFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontPublicPayDetailTextSize];
}
+ (UIFont*)publicPayHistoryFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontPublicPayHistoryTextSize];
}

+ (UIFont*)publicPayHistoryDetailFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontPublicPayHistoryDetailTextSize];
}

+ (UIFont*)publicPayTextFieldFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontPublicPayTextFieldTextSize];
}

+ (UIFont*)publicPayCheckBoxFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontPublicPayCheckBoxTextSize];
}

+ (UIFont*)publicPaySharedTextFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontPublicPaySharedTextSize];
}

+ (UIFont*)creditCardSupportBankListFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontCreditCardSupportBankList];
}

+ (UIFont*)mobileCarrierTextSizeFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontMobileCarrierTextSize];
}

+ (UIFont*)customRightViewFieldTextSizeFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontCustomRightViewFieldTextSize];
}

+ (UIFont*)appCenterAppNameFont
{
    return [UPXFontUtils defaultFontWihtSize:kAppCenterAppNameTextSize];
}

+ (UIFont*)appCenterSectionTitleFont
{
    return [UPXFontUtils defaultFontWihtSize:kAppCenterSectionTitleSize];
}



+ (UIFont*)textboxButtonFont
{
    return [UPXFontUtils defaultFontWihtSize:kTextboxButtonFont];
}

//系统消息等小图标的字体
+ (UIFont*)badgeTextFont
{
    return [UPXFontUtils defaultFontWihtSize:kFontBadgeTextFontSize];
}


// 电子对账单 字体
+ (UIFont *)eBillHeaderDealCountTitleFont {
    return [UPXFontUtils defaultFontWihtSize:kFontEBillHeaderDealCountTitle];
}
+ (UIFont *)eBillHeaderDealCountValueFont {
    return [UPXFontUtils defaultFontWihtSize:kFontEBillHeaderDealCountValue];
}
+ (UIFont *)eBillCellCardNumFont {
    return [UPXFontUtils defaultFontWihtSize:kFontEBillCellCardNum];
}
+ (UIFont *)eBillCellDealCountTitleFont {
    return [UPXFontUtils defaultFontWihtSize:kFontEBillCellDealCountTitle];
}
+ (UIFont *)eBillCellDealCountValueFont {
    return [UPXFontUtils defaultFontWihtSize:kFontEBillCellDealCountValue];
}


// 交易查询 商户名称 字体
+ (UIFont *)queryBillShopNameFont {
    return [UPXFontUtils defaultFontWihtSize:kFontQueryBillShopName];
}
+ (UIFont *)queryBillDateFont {
    return [UPXFontUtils defaultFontWihtSize:kFontQueryBillDate];
}
+ (UIFont *)queryBillAmountFont {
    return [UPXFontUtils defaultFontWihtSize:kFontQueryBillAmount];
}



@end
