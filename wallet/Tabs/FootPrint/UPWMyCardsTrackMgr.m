//
//  UPWMyCardsTrackMgr.m
//  wallet
//
//  Created by jhyu on 14/11/4.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWMyCardsTrackMgr.h"
#import "UPWBaseViewController.h"
#import "UPWDataFactoryBaseViewController.h"
#import "UPWMyFPViewController.h"
#import "UPWMyHuaXiaoViewController.h"
#import "UPWMyFPModel.h"
#import "UPWCardsListModel.h"

@interface UPWMyCardsTrackMgr () {
}

@property (nonatomic, weak) UPWBaseViewController * ownerVC;
@property (nonatomic, assign) EDFPageType eDFPageType;

@end

static BOOL mock = YES;

@implementation UPWMyCardsTrackMgr

//- (id)initWithPageSource:(EDFPageType)eDFPageType ownerVC:(UPWBaseViewController *)ownerVC
//{
//    self = [super init];
//    if(self) {
//        self.ownerVC = ownerVC;
//        self.eDFPageType = eDFPageType;
//    }
//    
//    return self;
//}

- (id)initWithOwnerVC:(UPWBaseViewController *)ownerVC
{
    self = [super init];
    if(self) {
        self.ownerVC = ownerVC;
    }
    
    return self;
}

#pragma mark - 打开我的足迹页面

- (void)openMyFootPrintPage
{
    self.eDFPageType = EDFPageByFootPrint;
    
    __weak typeof(self) weakSelf = self;
    
    [self.ownerVC showLoadingWithMessage:@"足迹数据获取中..."];
    
    if(mock) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf.ownerVC dismissLoading];
            //NSDictionary * dict = [ toDictionary];
            //[weakSelf myFootPrintRequestHandlerWithData:[UPWMyFPViewController mockResponseDataWithIndex:1]];
            
            [weakSelf.ownerVC.navigationController pushViewController:[[UPWMyFPViewController alloc] initWithFirstPageData:[UPWMyFPViewController mockResponseDataWithIndex:1]] animated:YES];
        });
    }
    else {
        NSDictionary * params = @{@"cdhdUsrId":UP_SHDAT.userInfoModel.userIdC,
                                  @"currentPage":[@(0) stringValue], @"pageSize":[@(kPageSize) stringValue]};
        UPWMessage * message = [UPWMessage messageWithUrl:@"spending/footPrintList" params:params cmd:nil ver:nil encrypt:YES isPost:NO];
        
        [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
            
            [weakSelf.ownerVC dismissLoading];
            [weakSelf myFootPrintRequestHandlerWithData:responseJSON];
        } fail:^(NSError *error) {
            
            [weakSelf.ownerVC dismissLoading];
            [weakSelf failedHandlerWithError:error];
        }];
    }
}

- (void)myFootPrintRequestHandlerWithData:(NSDictionary *)responseJSON
{
    if(responseJSON.count == 0) {
        [self.ownerVC showFlashInfo:UP_STR(@"抱歉，没有查询到您的任何足迹数据！")];
        
        // 根据CardList的请求来确定为什么没有数据。
    }
    else {
        [self.ownerVC.navigationController pushViewController:[[UPWMyFPViewController alloc] initWithFirstPageData:[UPWMyFPViewController dictionary2Model:responseJSON]] animated:YES];
    }
}

- (void)failedHandlerWithError:(NSError *)error
{
    if([[error localizedFailureReason] isEqualToString:kNoRealAuthenCardsErrorReason]) {
        // 没有实名认证过的卡，加载实名认证页面。
        [self.ownerVC.navigationController pushViewController:[[UPWDataFactoryBaseViewController alloc] initWithPageSource:EDFPageByFootPrint] animated:YES];
    }
    else {
        // 我的足迹TOP后台服务异常时，弹出错误信息，没有任何数据返回到前一个页面。
        [self.ownerVC showFlashInfo:[self.ownerVC stringWithError:error]];
    }
}

#pragma mark - 打开我的花销页面

- (void)openMyHuaXiaoPage
{
    self.eDFPageType = EDFPageByHuaXiao;
    
    __weak typeof(self) weakSelf = self;

    [self.ownerVC showLoadingWithMessage:@"花销数据获取中..."];
    
    if(mock) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf.ownerVC dismissLoading];
            NSDictionary * dict = [[UPWMyFPViewController mockResponseDataWithIndex:1] toDictionary];
            [weakSelf myHuaXiaoRequestHandlerWithData:dict];
        });
    }
    else {
        
        NSDictionary * params = @{@"cdhdUsrId":UP_SHDAT.userInfoModel.userIdC,
                                  @"currentPage":[@(0) stringValue], @"pageSize":[@(kPageSize) stringValue]};
        UPWMessage * message = [UPWMessage messageWithUrl:@"spending/footPrintList" params:params cmd:nil ver:nil encrypt:YES isPost:NO];
        
        [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
            
            [weakSelf.ownerVC dismissLoading];
            [weakSelf myFootPrintRequestHandlerWithData:responseJSON];
        } fail:^(NSError *error) {
            
            [weakSelf.ownerVC dismissLoading];
            [weakSelf failedHandlerWithError:error];
        }];
    }
}

- (void)myHuaXiaoRequestHandlerWithData:(NSDictionary *)responseJSON
{
    // 消费偏好
#define kStrCostDefault             @"其他"
#define kStrCostFood                @"美食"
#define kStrCostTravel              @"出行"
#define kStrCostShopping            @"购物"
#define kStrCostOnline              @"网购"
#define kStrCostDailyLife           @"生活"
#define kStrCostFunny               @"娱乐"
    
    NSArray * types = @[kStrCostDefault, kStrCostFood, kStrCostTravel, kStrCostShopping, kStrCostDailyLife, kStrCostFunny, kStrCostOnline];
    
    NSMutableArray * bkCards = [NSMutableArray array];
    for(int i = 0; i < 5; ++i) {
        UPWCardModel * cardModel = [[UPWCardModel alloc] init];
        cardModel.pan = @"6259 6508 0295 5895";
        cardModel.bank = @"招商银行";
        [bkCards addObject:cardModel];
    }
    
    UPWMyHuaXiaoViewController * vc = [[UPWMyHuaXiaoViewController alloc] initWithFirstPageData:nil cardsList:bkCards payTypes:types];
    [_ownerVC.navigationController pushViewController:vc animated:YES];
}

@end

