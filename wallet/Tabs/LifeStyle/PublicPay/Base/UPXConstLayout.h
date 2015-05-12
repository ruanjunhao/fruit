//
//  UPXConstLayout.h
//  UPClientV3
//
//  Created by TZ_JSKFZX_CAOQ on 13-6-5.
//
//

/*
 用来保存长度,高度,宽度,CGRect,CGPoint,CGSize等布局相关常量
 
 */

#import "UPWConst.h"


/* 个人中心按钮消息数目图标中心位置 */
#define  kPersonBadgeCenter  CGPointMake(309, 15)

/* 主页ICON的宽高 */
#define   kIconWidth        44
#define   kIconHeight       44

/* UIPageControl 高度(首页) */
#define  kPageCtrlHeight    30
/* UIPageControl 下边距(首页) */
#define  kPageCtrlButtomMargin    12


/* UIPageControl 高度(引导教程) */ 
#define  kTutorialPageCtrlHeight    17
/* UIPageControl 下边距(引导教程) */
#define  kTutorialPageCtrlButtomMargin    10


/* 定义一般按钮宽高 */
#define kCommonButtonLeftMargin 15
#define kCommonButtonHeight  44

/* 定义一般Toast宽高 */
#define kCommonToastSize CGSizeMake(150, 90)

/* 定义一般文字输入框左边距 */
#define kCommonTextFieldTextRectLeftMargin 15
#define kCommonTextFieldTextRectRightMargin 10

#define kCommonTextFieldEditingRectLeftMargin 15
#define kCommonTextFieldEditingRectRightMargin 0
#define kCommonTextFieldHeight                 44

/* 定义一般switch高度 */
#define kDefaultSwitchSize  CGSizeMake(72, 27)


/* 定义导航栏和Application的高宽 */
#define  kNavigationBarHeight              44
#define  kStatusBarHeight                  20
#define  kWebViewToolBarHeight              44

#define  kScreenWidth             ([UIScreen mainScreen].bounds.size.width)
#define  kScreenHeight            ([UIScreen mainScreen].bounds.size.height - kStatusBarHeight)

//定义左侧菜单宽度
#define  kMenuWidth               270
//导航栏左侧按钮左边距
#define kNavigationLeftButtonMargin 6
//导航栏右侧按钮右边距
#define kNavigationRightButtonMargin 6
// 定义 分享界面 的宽度
#define kShareViewWidth 290


//Sys.init失败, 显示的Label区域
#define kSystemInitFailHintRect CGRectMake(0, 200, 320, 200)
//进入银联随行 按钮
#define kEnterHomeButtonRect CGRectMake(15 + 3*kScreenWidth, 366, 290, 44)
#define kEnterHomeButtonRect4Inch CGRectMake(15 + 3*kScreenWidth, 431, 290, 44)


//Home界面系统消息Table View
#define kHomeSysMsgTableViewMaxItem 4
#define kHomeSysMsgTableViewCellHeight 40
#define kHomeSysMsgTableViewMaxHeight (kHomeSysMsgTableViewCellHeight*kHomeSysMsgTableViewMaxItem)
#define kHomeSysMsgTableViewWidth 240

//登录界面
#define kLoginTableMarginX   5
#define kLoginTableMarginY   6
#define kLoginTableViewHeight   150
#define kLoginTableRowHeight 50
#define kLoginRowMargin 20

//登录界面输入框
#define kLoginTableTextFieldLeftMargin 62
#define kLoginTableTextFieldTopMargin  12
#define kLoginTableTextFieldRightMargin 32
#define kLoginTableTextFieldHeight  25
#define kLoginTableVerifyImageWidth  100

//验证码
#define kLoginTableVerifyButtonWidth  65
#define kLoginTableVerifyButtonHeight  26
#define kLoginTableVerifyButtonInnerRightMargin  3
//验证码菊花
#define kRefreshVerifyActivityCenter CGPointMake(232,25)

#define kResetPasswordButtonWidth 80
#define kResetPasswordButtonHeight 25
//找回密码按钮位置 距离tableview 16
#define kResetPasswordButtonOffsetY 130
//验证码图片显示时的找回密码按钮位置
#define kResetPasswordButtonWithVerifyOffsetY 180

//登录按钮位置
#define kLoginButtonOffsetY   171



//验证码输入框位置
#define kLoginVerifyCodeFieldRect CGRectMake(20,204,80,24)
//登录界面table view相关
#define     kLoginTableImageRect  CGRectMake(15, 13, 24, 24)
#define     kLoginTableLineRect CGRectMake(50, 0, 1, 50)
#define     kLoginTableLineSize CGSizeMake(1, 50)




// 从Frame 获取 Bounds
#define CGRectBoundsFromFrame(frame) CGRectMake(0, 0, frame.size.width, frame.size.height)

// 显示 区域的 坐标
#define kSubviewMarginX 0.0    //15.0
#define kSubviewMarginY 15.0
#define kFormItemHeight 40.0
#define kFormItemHeightLabel 15.0
#define kFormItemVerticalSpacing 10.0
#define kFormItemMarginX 15.0
#define kFormItemVerticalSpacingButton kFormItemVerticalSpacing*1.5

// 多选框 中，内容左边距
#define kFormItemMultiBillContextMarginX 13.0
#define kFormItemMultiBillContextMarginY 13.0
#define kFormItemMultiBillTableHeight 44.0

#define kFormItemMBillCell_billLabelOriginY 15
#define kFormItemMBillCell_allLabelOriginY 14
#define kFormItemMBillCell_allLabelOriginX 10
#define kFormItemMBillCell_billLabelWidth 205
#define kFormItemMBillCell_alLabelWidth 270

// checkbox 勾选框的高度
#define kCheckBoxHeight 19.0

// 设置提醒日 控件的高度
#define kFormItemHeightSetRemindDay 80.0

// 点击重试 中文字的默认高度
#define kNetworkErrorViewLabelHeight 14
#define kNetworkErrorViewLabelSpacing 20

// view 的 高度,宽度
#define  kViewWidth   kScreenWidth
#define  kViewHeight  (kScreenHeight - kNavigationBarHeight)
// 定义 view的 frame
#define kViewFrame CGRectMake(0, kNavigationBarHeight, kScreenWidth, kViewHeight)
// 定义 view的 size
#define kViewSize CGSizeMake(kViewWidth, kViewHeight)

// add by Jiang Dalong.
#define UP_NO_UI 1
#define UPXRect(p, s) CGRectMake(p.x, p.y, s.width, s.height)
#define UPXRectLBPoint(r) CGPointMake(r.origin.x, r.origin.y+r.size.height)
#define UPXRectWithAnchorPoint(p)

// rect utli
static inline CGRect UPXRectOffsetFromR(CGRect rect, CGFloat w)
{
    rect.origin.x = kScreenWidth - w - rect.size.width;
    return rect;
}

static inline CGRect UPXRectOffset(CGRect rect, CGPoint p)
{
    return CGRectOffset(rect, p.x, p.y);
}

// 下一个rect.x +width +w
static inline CGRect UPXRectOffsetWX(CGRect rect, CGFloat w)
{
    rect.origin.x = rect.origin.x + rect.size.width +w;
    return rect;
}

//add by ymm

/* tabBar */
//#define kTabBarHeight                       44
#define kTagOffset                          1000

/* UPXAllBenefitsCell */
#define kAllBenefitsCellHeight              81.0f

/* UPXMyCardsCell */
#define kMyCardsCellHeight1                 95.0f

/* UPXQueryBillCell */
#define kQueryBillCellHeight                62.0f

/* UPXElectronicBill */
#define kElectronicBillCellHeight           104.0f

/* 城市列表 */
#define kCitySearchBarHeight 39.0f
#define kCityListPageCellHeight 44.0f
#define kCityListPageSectionHeight 22.0f
#define kCityListPageTopShadowHight 2.0f
