//
//  UPXConstKey.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-6-5.
//
//

/*
 用来保存字典中的key常量
 
 */

// add by Cao Qi.


#pragma mark - 记录在UserDefault中的key

// 上一次登录成功的用户名
#define kUDKeyLastLoginName                                              @"lastLoginName_400"
#define kUDKeyLastUserName                                              @"lastUserName_400"
#define kUDKeyPushSettingSwitch       @"pushSettingSwitch_400"
#define KUDKeyFirstLaunch          @"firstLaunched_400"
#define kUDKeyLatestCity           @"latestCity_400"
#define kUDKeyLatestUsername       @"latestUsername_400"
#define kUDKeySearchHistory        @"searchHistory_400"
#define kUDKeyLastVersion          @"lastVersion_400"
#define kUDKeyTradeTypes              @"tradeTypes_400"
#define kUDKeyDeviceToken    @"deviceToken_400"
#define kUDKeyBadgeAllowed   @"badgeAllowed_400"
#define KUDKeyBankRecordCard  @"bankRecordCard_400"
#define kUDKeyLatitude @"latitude_400"
#define kUDKeyLongitude @"longitude_400"
//全应用列表时间戳
#define kUDKeyAllAppInfoTimeStamp @"allAppInfoTimeStamp_400"
#define kUDKeyHasInitialPatternFailed @"hasInitialPatternFailed_400"



#pragma mark -
#pragma mark 其他key

/* 默认的 device token,解除绑定时使用 */
#define kDefaultDeviceToken @"88888888"


/* 时间戳格式 */
#define kUPClientTimeFormat @"yyyy-MM-dd HH:mm:ss"

/* 默认时间戳 */
#define kDefaultTimeStamp @"0001-01-01 00:00:00"

// 添加借记卡规则 key

#define kPWD                @"pin"

#pragma mark -
#pragma mark 信息上传
#define kUploadInfoAppDownload @"AppDownload"



#pragma mark -
#pragma mark catalogs

#define kKeyCatalogBgColor @"bg_color"
#define kKeyCatalogType @"type"
#define kKeyCatalogName @"name"
#define kKeyCatalogID @"id"
#define kKeyCatalogPerm @"perm"
#define kKeyCatalogDest @"dest"
#define kKeyCatalogConfig @"config"
#define kKeyCatalogIconURL @"icon_url"
#define kKeyCatalogIconStatus @"status"
//#define kKeyCatalogIconVersion @"v"
#define kKeyCatalogIconBadgeUrl @"badge_url"
// classification
#define kKeyCatalogClassification  @"classification"

#pragma mark -
#pragma mark sync

#define kSyncUpload @"upload"
#define kSyncDownload @"download"


#define kSyncTypeLocalSettings @"\"local_settings\""
#define kSyncTypeShortcuts @"\"shortcuts\""
#define kSyncTypeRemindDays @"\"remind_days\""
#define kSyncTypeBills @"\"bills\""

#define kUserLoginSyncInfo   @"\"shortcuts_ts\",\"remind_days_ts\",\"bills_ts\",\"local_settings_ts\""


#define kJSONRemindDaysKey @"remindDays"
#define kJSONShortcutsKey @"shortcuts"
#define kJSONLocalSettingsKey @"local_settings"
#define kJSONBillsKey @"bills"
#define kJSONBillsAppKey @"bills_app"
#define kJSONSyncBillAppIdsKey @"sync_bill_app_ids"

#define kJSONAppActionKey @"app_action"

// add by Yang.

// 支付插件 传入的 app_id,现在改成 bundleIdentifier
#define kUPPayPluginAppId [[NSBundle mainBundle]bundleIdentifier]

// 水电煤 缴费 默认地区为 上海，areaCode为 31
#define kUPPublicPayDefaultAreaCode @"31"

// app中的 type/dest字段
#define kUPAppTypeHtml @"html"
#define kUPAppTypeNative @"native"

#define kUPAppDestPrefixJiaofei @"jiaofei"
#define kUPAppDestPrefixChongzhi @"chongzhi"
#define kUPAppDestPrefixHuankuan @"huankuan"
#define kUPAppDestPrefixFakuan @"fakuan"
#define kUPAppDestPrefixHuodong @"huodong"
#define kUPAppDestPrefixTrans @"trans"

#define kUPAppDestParamsTypeYiDond @"s01"
#define kUPAppDestParamsTypeLianTong @"s02"
#define kUPAppDestParamsTypeDianXin @"s03"
#define kUPAppDestParamsTypeWater @"s05"
#define kUPAppDestParamsTypeElec @"s06"
#define kUPAppDestParamsTypeGas @"s07"
#define kUPAppDestParamsTypeWuYe @"s08"



// 水电煤支付 中 的 action 字段的 value，（prepay,prequery）
#define kPublicPayAction @"action"
#define kPublicPayActionPrepay @"prepay"
#define kPublicPayActionPrequery @"prequery"
#define kPublicPayForm @"form"

// 调用支付插件，返回的 回调 success 表示成功
#define kUPPayPluginSuccess @"success"
#define kUPPayPluginFailed @"fail"
#define kUPPayPluginCancel @"cancel"

// prepay 中上传qn，默认值为 00000000
#define kUPXPayPrepayDefaultQn @"00000000"

// orderPay 中 的 order_type : 01 -- 自动订单 02 -- 手动订单
#define kUPXPayOrderPayTypeAutoOrder  @"01"
#define kUPXPayOrderPayTypeManualOrder  @"02"
#define kUPXPayOrderPayUpOrder @"uporder"
//01表示 待支付订单
#define kUPXPayOrderUnPay @"01"
#define kUPXPayOrderStatus @"orderStatus"

// 第三方app，calssification == 02
#define kUPXPayKeyClassificationIsThirdPartyApp  @"02"

// jiaofei.preapy中 上送uporder 对象中的 关键字
#define kKeyUporderAppName @"app_name"
#define kKeyUporderAppID @"app_id"
#define kKeyUporderUsrNum @"usr_num"
#define kKeyUporderBussCode @"buss_code"
#define kKeyUporderBussName @"buss_name"
#define kKeyUporderAmount @"amount"
#define kKeyUporderQueryMonth @"query_month"
#define kKeyUporderQn @"qn"


// 远程推送 中 的字段
#define kUPXRemoteNotificationAPS @"aps"
#define kUPXRemoteNotificationAPSAlert @"alert"
#define kUPXRemoteNotificationAPSInfo @"info"

#define kUPXRemoteNotificationApp @"a"
#define kUPXRemoteNotificationAppId @"i"
#define kUPXRemoteNotificationAppName @"n"
#define kUPXRemoteNotificationAppDest @"d"

#define kUPXRemoteNotificationOrder @"o"
#define kUPXRemoteNotificationOrderId @"i"
#define kUPXRemoteNotificationOrderTime @"t"
#define kUPXRemoteNotificationOrderType @"y"
#define kUPXRemoteNotificationOrderAmount @"a"
#define kUPXRemoteNotificationRemindSeq  @"s"

#define kUPXRemoteNotificationData @"d"
#define kUPXRemoteNotificationDataAreaCode @"a"
#define kUPXRemoteNotificationDataCompanyCode @"c"
#define kUPXRemoteNotificationDataUsrNum @"u"

#define kUPXRemoteNotificationMessage @"m"
#define kUPXRemoteNotificationMessageLink @"u"
#define kUPXRemoteNotificationMessageType @"t"


// webApp中 payPlugins 调用 order.prehandle 的通知
#define kUPXNotfifcationWebPluginPayOrderPrehandle @"getPrehandle"

// webApp中 JS和支付控件交互 的key
#define kUPWebPluginPayToJSResultCode @"code"
#define kUPWebPluginPayToJSResultMessage @"desc"

#define kUPWebPluginPayToJSResultCodeSuccess @"00"
#define kUPWebPluginPayToJSResultCodeCancel @"01"
#define kUPWebPluginPayToJSResultCodeFailed @"02"


//web plugin 
#define kUPPluginJSResultCode @"code"
#define kUPPluginJSResultMessage @"desc"


// ##添加提醒日##
// remind_type（取值：1-订阅自动查询账单，0-普通提醒日推送；客户端应保证：对于直接缴费业务，不允许将该字段设置成1）
#define kUPXRemindTypePay @"0"
#define kUPXRemindTypeQueryAndPay @"1"

// 手机充值，信用卡还款  最大存储历史记录数
#define kCreditRepaymetnMaxHistoryCount 6
#define kMobileRechargeMaxHistoryCount  6
//每个app id最多保留10条历史纪录
#define kUPXModelHistoryMaxCount 10

// 数字金额 最大输入位数
#define kInputMoneyMaxCount 10
// 银行卡号 最多 19位
#define kInputBankCardNumMaxCount 19
// 手机号 最多 11为
#define kInputMobileMaxCount 11

// cell indentifier
#define kRemindCellIdentifier @"UPRemindCellIdentifier"

// json key
#define kJSONParamsKey @"params"
#define kJSONCmdKey @"cmd"
#define kJSONRespKey @"resp"
#define kJSONMsgKey @"msg"
#define kJSONAppsKey @"apps"
#define kJSONIDKey @"id"
//#define kJSONVKey @"v"
#define kJSONNameKey @"name"
#define kJSONTypeKey @"type"
#define kJSONCodeKey @"code"
#define kJSONAreasKey @"areas"
#define kJSONStatusKey @"status"
#define kJSONBizKey @"biz"


// prehandle 返回的 order_id order_time
#define kJSONPrehandleOrderId @"order_id"
#define kJSONPrehandleOrderTime @"order_time"

// json value
#define kJSONRemindListValue @"remind.list"
#define kJSONRemindEditValue @"remind.edit"
#define kJSONRemindDelValue @"remind.del"
#define kJSONMsgPromotionValue @"msg.promotion"

// kvo key path
#define kKeuPathIsNeedUpdate @"isNeedUpdate"

#define kConstMsgSwitchValue @"11"



#define kAllBenefitsCellShopName            @"name"
#define kAllBenefitsCellOfferTab            @"discount"
#define kAllBenefitsCellBankName            @"bank"
#define kAllBenefitsCellIconImage           @"thumbnail"


#pragma mark
#pragma mark 自定义通知中心消息

#define kNCPersonalScoreVCHadEnter @"UPNotifyPersonalScoreVCHadEnter"
#define kNCLoginStatusChanged @"UPNotifyLoginStatusChanged"
#define kNCLoginCancel  @"UPNotifyLoginCancel"
#define kNCAfterPatternAction  @"UPNotifyAfterPatternAction"
#define kNCLifeStyleChanged @"UPNotifyLifeStyleChanged"
#define kNCUpdateSecurityInfoSucceed @"kUpdateSecurityInfoSucceed"
// 分享微信 失败
#define kNCSharedWeixinSuccess @"UPNotifySharedWeixinSuccess"
// 收到 远程推送的账单通知 或者  支付成功 需要刷新 order.list
#define kNCRefreshOrderList @"UPNotifyRefreshOrderList"
// 添加借记卡成功
#define kNCAddDebitCardSuccess @"AddDebitCardSuccess"

#define kNCUnlockPatternSucceed  @"UPNotifyUnlockPatternSucceed"

//点击进入前台事件通知
#define kNCEnterForeground    @"kNCEnterForeground"

//点击进入后台事件通知
#define kNCEnterBackground    @"kNCEnterBackground"

//点击applicationWillResignActive通知
#define kNCResignActive       @"kNCResignActive"

#define KNCDeleteThePatternView @"KNCDeleteThePatternView"


#pragma mark - 分享中从web传入参数 字典 shareParams中的key
#define kShareParamsString  @"shareStr"
#define kShareParamsUrl  @"shareUrl"
#define kShareParamsImage  @"shareImg"


#pragma mark -
#pragma mark Balance rules key

#define kBalanceRules       @"rules"
#define kBalanceRulesValue  @"value"


#pragma mark - sysinit 优惠活动 中的 key
#define kSpecialOffers  @"special_offers"
#define kSpecialOffers_Url  @"url"
#define kSpecialOffers_Config  @"config"
#define kSpecialOffers_DismissTime  @"dismiss_time"

#define kRemoveThePatternViewFromWindow  @"RemoveThePatternViewFromWindow"

//勾选
#define kChecksure                   @"selected"
//取消勾选
#define kCheckcancel                 @"selected"
//支付成功
#define KPaysuccess                  @"paysuccess"
//历史查询
#define kPublicpayhistory            @"publicpayhistory"
//公司
#define kPublicpaycompany            @"publicpaycompany"
//查询
#define kQuery                       @"query"
//支付
#define kPay                         @"pay"
//选择金额
#define kSelectamount                @"amount"
//选择项
#define kSelect                      @"index"

//登录成功信息
#define kLogsuccessmsg               @"uid"
//登录失败信息
#define kLoginfailedmsg              @"errorDesc"
//提醒日期
#define kReminderdate                @"date"
//查询失败信息
#define kQueryfailedmsg              @"errorDesc"
//查询时间
#define kQuerydate                   @"date"
//应用id
#define kAppid                       @"appID"
//位置编号
#define kPositionnum                 @"pos"
//地域
#define kArea                        @"area"
//话费充值失败信息
#define kMobilefarefailedmsg          @"errorDesc"
//支付错误信息
#define kPayfailedmsg                 @"errorDesc"
//当前页面号
#define kPageTonum                    @"to_index"
#define kPageFromnum                  @"from_index"

//实名认证成功以后，返回通知中包含该卡的卡号
#define kBindCardPan                  @"pan"

// 高德地图KEY
#define MAP_API_KEY [UPWAppUtil gaodeMapAppKey]

// 随行：433602054  钱包：600273928
#define kAppStoreId                   @"998533347"
#define kAppName                      @"银联钱包" //@"银联随行"
#define kUPCallCenter                 @"95516"

