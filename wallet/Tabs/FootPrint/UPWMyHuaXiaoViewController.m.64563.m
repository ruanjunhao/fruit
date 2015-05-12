//
//  UPWMyHuaXiaoViewController.m
//  wallet
//
//  Created by jhyu on 14/11/3.
//  Copyright (c) 2014年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWMyHuaXiaoViewController.h"
#import "UPWUnionMenuBar.h"
#import "UPWCardsListModel.h"
#import "UPWWebViewController.h"
#import "UPWBankCostRecordDetailViewController.h"
#import "UPWBankCostRecordCell.h"
#import "UPWCostTableHeader.h"
#import "UPWAppUtil.h"
#import "UPWMessage.h"
#import "UPWGlobalData.h"
#import "UPWConst.h"
#import "UPWBussUtil.h"
#import "UPWFileUtil.h"
#import "UPWPathUtil.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "UPWUnionMenuButtonCHSP.h"
#import "UPWWebData.h"

#define kMaxReqSections 6
#define kFirstSectionIndex 0
#define kBKCardNormalLength 16
#define kBKCardMaxLength 19

#define kCurSectionIndex  @"CurSectionIndex"
#define kCurPageIndex  @"CurPageIndex"
#define kIsMoreDataAvailable  @"IsMoreDataAvailable"

@interface UPWMyHuaXiaoViewController () <UPWUnionMenuDelegate, UITableViewDataSource, UITableViewDelegate, UPWCostTableHeaderDelegate> {
    
    UPWCardsListModel * _cardsListModel;
    UPWCardModel * _selectedBkCard;
    NSString *     _selectedCostType;
    BOOL _onceFlag;
    
    NSMutableArray *_isUnfoldArray;
    NSMutableDictionary *_dataHere;
    NSInteger _tempRecordNum;
    
    UITableView *_tableView;
    UILabel * _tipsLabel;
    
    NSMutableArray *_sectionKeys;
    NSInteger _curSection;
    NSInteger _currentPage;
    BOOL _isSectionLoadedDone;
    BOOL _isPrevReqSuccess;
    
    UPWUnionMenuButtonCHSP * _menuButton;
}

@property (nonatomic, copy) NSArray* filters;
@property (nonatomic, strong) UPWUnionMenuBar* menuBar;

@end

#define kTipLabelHeight 22
#define kMenuBarHeight  42

@implementation UPWMyHuaXiaoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _ePageType = EDFPageByHuaXiao;
        _selectedCostType = @"";
    }
    return self;
}

- (id)initWithEPageType:(EDFPageType)ePageType
{
    self = [self init];
    if(self) {
        _ePageType = ePageType;
    }
    
    return self;
}

- (void)initSectionKeys
{
    _sectionKeys = [[NSMutableArray alloc] init];
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    [_sectionKeys addObject:@"本月"];
    
    for (NSInteger i = 1; i < kMaxReqSections; i++) {
        
        NSInteger year, month;
        
        if (components.month - i <= 0) {
            year = components.year - 1;
            month = 12 + (components.month - i);
        }
        else {
            year = components.year;
            month = components.month - i;
        }
        
        [_sectionKeys addObject:[NSString stringWithFormat:@"%@年%@月", @(year), @(month)]];
    }
}

- (void)initialize
{
    [self initSectionKeys];
    _isUnfoldArray = [NSMutableArray arrayWithCapacity:kMaxReqSections];
    for(NSInteger i = 0; i < kMaxReqSections; ++i) {
        [_isUnfoldArray addObject:@YES];
    }
    
    _dataHere = [[NSMutableDictionary alloc] init];
    _currentPage = kMessagePageReqStartIndex;
    _curSection = kFirstSectionIndex;
    _tempRecordNum = 0;
    _isPrevReqSuccess = YES;
    _isSectionLoadedDone = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialize];
    
    __weak typeof(self) wself = self;
    [UPWBussUtil fetchTradeTypesWithCompetionBlock:^(NSArray *tradeTypes) {
        wself.filters = tradeTypes;
    }];
    
    //加载交易类型
    [self postCardList];// 获取卡列表
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)postCardList
{
    [self showNetworkLoading:CGPointMake(CGRectGetWidth(_contentView.frame)/2, CGRectGetHeight(_contentView.frame)/2) withRetryRect:_contentView.bounds];
    
    __weak typeof(self) wself = self;
    
    UPWMessage* message = [UPWMessage cardList];
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary * response) {
        
        [wself dismissAll];
        [wself hideNetworkStatusView];
        NSDictionary* cardList = response[kJSONParamsKey];
        [wself cardListSuccessHandler:cardList];
        
    } fail:^(NSError * err) {
        
        [wself dismissAll];
        [wself hideNetworkStatusView];
        [wself cardListFailedHandler:err];
    }];
}

#pragma mark -
#pragma mark - 获取卡列表
- (void)cardListSuccessHandler:(NSDictionary *)cardList
{
#warning mock
    cardList = @{@"bindRelations":@[@{@"pan":@"6222531234567991", @"supPay":@"1"}, @{@"pan":@"6222583123456794", @"supPay":@"1"}, @{@"pan":@"6225887473424493", @"supPay":@"1"}, @{@"pan":@"6227600200027598", @"supPay":@"1"}]};
    
    _cardsListModel = [[UPWCardsListModel alloc] initWithDictionary:cardList error:nil];
    if(_cardsListModel.bindRelations.count == 0) {
        // 没有绑定的卡，提示用户去绑卡。
        [self setupCardBindingPage];
    }
    else {
        NSMutableArray * authCards = [NSMutableArray array];
        for(UPWCardModel * card in _cardsListModel.bindRelations) {
            if([card.supPay isEqualToString:@"1"]) {
                [authCards addObject:card];
            }
        }
        
        if(authCards.count == 0) {
            [self setupRealAuthenPage];
        }
        else {
            _cardsListModel.bindRelations = [authCards copy];
            [self fetchCostRecordInSection:kFirstSectionIndex withPageIndex:kMessagePageReqStartIndex];;
        }
    }
}

- (void)cardListFailedHandler:(NSError *)error
{
    NSDictionary* cardList = [UPWFileUtil readContent:[UPWPathUtil cardListCachePath:UP_SHDAT.bigUserInfo.userInfo.userId]];
    if(cardList.count > 0) {
        [self cardListSuccessHandler:cardList];
    }
    else {
        [self showFlashInfo:UP_STR(@"抱歉，服务器繁忙，请稍后再试！")];
        [self showNetworkFailed];
    }
}

#pragma mark -
#pragma mark "显示NoContentView"

- (void)showNoContentView:(CGPoint)center
{
    [super showNoContentView:center];
    
    [_tableView removeFromSuperview];
    _tableView = nil;
    
    //    [_tipsLabel removeFromSuperview];
    //    _tipsLabel = nil;
    
    if(_menuBar) {
        [_contentView bringSubviewToFront:_menuBar];
    }
}

#pragma mark -
#pragma mark "建立多级选择菜单"
- (void)setupMenuBar
{
    if(!_menuBar) {
        CGFloat viewWidth = CGRectGetWidth(_contentView.bounds);
        CGFloat viewHeight = CGRectGetHeight(_contentView.bounds);
        //CGFloat y = 0.0f;
        CGRect rect = CGRectMake(0, 0.0f, viewWidth, kMenuBarHeight);
        
        static NSString* buttonIdentifier = @"UPMenuBarButtonIdentifier";
        static NSString* singleListIdentifier = @"UPMenuBarSingleListIdentifier";
        
        _menuBar = [[UPWUnionMenuBar alloc] initWithFrame:rect];
        _menuBar.backgroundColor = UP_COL_RGB(0xffffff);
        _menuBar.shadowColor = UIColor.blackColor;
        _menuBar.menuEdgeInsets = UIEdgeInsetsMake(6, 0, 6, 0);
        
        _menuBar.listRect = CGRectMake(0, 0, viewWidth, 272);
        _menuBar.dimmedBackgroundRect = CGRectMake(0, 0, viewWidth, viewHeight - CGRectGetMinY(_menuBar.frame));
        
        [_menuBar registerClass:@"UPWUnionMenuButtonCHSP"
                  forIdentifier:buttonIdentifier];
        [_menuBar registerClass:@"UPWUnionMenuBarSingleList"
                  forIdentifier:singleListIdentifier];
        
        [_menuBar addMenuListForIdentifier:singleListIdentifier];
        
        // 第一列  银行卡列表
        _menuButton = (UPWUnionMenuButtonCHSP *)[_menuBar addMenuButtonWithTitle:UP_STR(@"全部银行卡") withListIdentifier:singleListIdentifier forIdentifier:buttonIdentifier showWordsLength:kBKCardMaxLength];
        
        // 第二列  交易类型列表
        id firstObj = self.filters.firstObject;
        NSString * title = firstObj[@"value"];
        if(UP_IS_NIL(title)) {
            title = UP_STR(@"全部交易类型");
        }
        [_menuBar addMenuButtonWithTitle:title withListIdentifier:singleListIdentifier forIdentifier:buttonIdentifier showWordsLength:16];
        
        _menuBar.delegate = self;
        [_contentView addSubview:_menuBar];
    }
    else {
        [_contentView bringSubviewToFront:_menuBar];
    }
}

- (void)setupTableView
{
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kMenuBarHeight, _contentView.frame.size.width, _contentView.frame.size.height - kMenuBarHeight - kTipLabelHeight) style:UITableViewStylePlain];
        _tableView.backgroundColor = UP_COL_RGB(0xf0f0f0);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_contentView addSubview:_tableView];
        
        __weak typeof(self) wself = self;
        [_tableView addInfiniteScrollingWithActionHandler:^{
            [wself loadTableListData];
        }];
    }
    else {
        [_contentView bringSubviewToFront:_tableView];
    }
}

- (void)loadTableListData
{
    DLog(@"... Load data in section (%@) pageIndex (%@)", [@(_curSection) stringValue], [@(_currentPage) stringValue]);
    
    NSInteger section;
    NSInteger pageIndex;
    
    if(_isPrevReqSuccess) {
        if(_isSectionLoadedDone) {
            section = _curSection + 1;
            pageIndex = kMessagePageReqStartIndex;
        }
        else {
            section = _curSection;
            pageIndex = _currentPage + 1;
        }
    }
    else {
        // 前一个请求失败，请求参数重用以前的。
        section = _curSection;
        pageIndex = _currentPage;
    }
    
    [self fetchCostRecordInSection:section withPageIndex:pageIndex];
    
    [_contentView bringSubviewToFront:_tableView];
}

- (void)setupTipMark
{
    if(!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_tableView.frame), _contentView.frame.size.width, kTipLabelHeight)];
        _tipsLabel.text = UP_STR(@"kStrCardRecordDeclare");
        _tipsLabel.font = [UIFont systemFontOfSize:11];
        _tipsLabel.textColor = UP_COL_RGB(0x999999);
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.backgroundColor = UP_COL_RGB(0xffffff);
        _tipsLabel.layer.borderWidth = 0.5;
        _tipsLabel.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
        [_contentView addSubview:_tipsLabel];
    }
    else {
        [_contentView bringSubviewToFront:_tipsLabel];
    }
}

#pragma mark -
#pragma mark - UITableView delegate & dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataHere.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_isUnfoldArray[section] boolValue]) {
        // 展开模式
        NSInteger cnt = [[self dataInSection:section] count];
        if(cnt == 0) {
            // show NoConetentView.
            return 1;
        }
        
        return cnt;
    }
    else {
        // 折叠模式
        return 0;
    }
}

- (NSArray *)dataInSection:(NSInteger)section
{
    return _dataHere[_sectionKeys[section]][@"record"];
}

- (NSDictionary *)sectionInfoInInSection:(NSInteger)section
{
    return _dataHere[_sectionKeys[section]][@"section"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kBankCostRecordHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UPWCostTableHeader *header = [[UPWCostTableHeader alloc] initWithFrame:CGRectMake(0, 0, _contentView.frame.size.width, kBankCostRecordHeaderHeight)];
    header.delegate = self;
    [header setHeaderWithData:_dataHere[_sectionKeys[_curSection]] inSection:section];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kBankCostRecordCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"UPBankCostRecordCell";
    UPWBankCostRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UPWBankCostRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.contentView.exclusiveTouch = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *data = [self dataInSection:indexPath.section];
    if (data.count == 0) {
        [cell showNoContentView];
    } else {
        [cell setCellWithData:data[indexPath.row] cellCount:data.count indexPath:indexPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *data = [self dataInSection:indexPath.section];
    if (data.count != 0) {
        UPWBankCostRecordDetailViewController *costRecordDetailVC = [[UPWBankCostRecordDetailViewController alloc] initWithModel:[data objectAtIndex:indexPath.row] type:UPCostRecordByNomalSearch];
        [self.navigationController pushViewController:costRecordDetailVC animated:YES];
    }
}

#pragma mark -
#pragma mark - UPCostTableHeaderDelegate

// 用户点击table header将本月数据折叠/展开

- (void)costTableHeader:(UPWCostTableHeader *)tableHeader inSection:(NSInteger)section
{
    BOOL isUnfold = [_isUnfoldArray[section] boolValue];
    _isUnfoldArray[section] = @(!isUnfold);
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if(isUnfold) {
        // 点击主要是收起此Section下的列表(fold)。
        // 收缩某一section时，触发滚动，当满足加载更多条件时，自动加载更多
        if(section == _dataHere.count - 1) {
            // 拉下一个section
            [self fetchCostRecordInSection:(_curSection + 1) withPageIndex:kMessagePageReqStartIndex];
        }
    }
    else {
        // 点击主要是展开起此Section下的列表(unfold)。
        // 看是否需要拉本section的数据。
        NSDictionary * sectionInfo = [self sectionInfoInInSection:section];
        if([sectionInfo[kIsMoreDataAvailable] boolValue]) {
            // 继续加载本Section的数据
            [self fetchCostRecordInSection:section withPageIndex:([sectionInfo[kCurPageIndex] integerValue] + 1)];
        }
        else {
            // do nothing.
        }
    }
}

#pragma mark - 网络请求相关

- (NSArray *)reqPanList
{
    // 查银行卡片集合。
    NSArray * panList;
    if(_selectedBkCard) {
        panList = @[_selectedBkCard.pan];
    }
    else {
        NSMutableArray * mCards = [NSMutableArray array];
        for(UPWCardModel * cardModel in _cardsListModel.bindRelations) {
            if(!UP_IS_NIL(cardModel.pan) && cardModel.supPay.boolValue) {
                [mCards addObject:cardModel.pan];
            }
        }
        
        panList = mCards;
    }
    
    return panList;
}

- (void)fetchCostRecordInSection:(NSInteger)section withPageIndex:(NSInteger)pageIndex
{
    if(section >= kMaxReqSections) {
        return;
    }
    
#if 0
    NSDictionary * sectionInfo = [self sectionInfoInInSection:section];
    if([sectionInfo[kIsMoreDataAvailable] boolValue]) {
        // 本section还没加载完
        if(pageIndex > [sectionInfo[kCurPageIndex] integerValue]) {
            // 正常，继续拉本section下一页数据
            // Pls go on ...
        }
        else {
            [self fetchCostRecordInSection:section withPageIndex:([sectionInfo[kCurPageIndex] integerValue] + 1)];
            return;
        }
    }
    else {
        // 本section已经加载过了并且加载完了。
        [self fetchCostRecordInSection:(section + 1) withPageIndex:kMessagePageReqStartIndex];
        return;
    }
#endif
    
    NSString * year;
    NSString * month;
    
    //date是自己造的数据，长度足够用，不用做长度校验
    NSString *date = [_sectionKeys objectAtIndex:section];
    if (date.length < 7) {
        NSDate *date = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSDateComponents *components = [calendar components:unitFlags fromDate:date];
        year = [NSNumber numberWithInteger:components.year].stringValue;
        month = [NSNumber numberWithInteger:components.month].stringValue;
        if (month.length != 2) {
            month = [NSString stringWithFormat:@"0%@", month];
        }
    }
    else {
        NSRange range = {0, 4};
        year = [date substringWithRange:range];
        range.location = 5;
        range.length = 2;
        month = [date substringWithRange:range];
        if ([month hasSuffix:@"月"]) {
            month = [NSString stringWithFormat:@"0%@", [month substringToIndex:1]];
        }
    }
    
    NSArray * panList = [self reqPanList];
    NSString * transType = _selectedCostType;
    UPDINFO(@"... request %@-%@-%@ (%@, %@)", year, month, [@(_currentPage) stringValue], panList, transType);
    
    NSDictionary *dict= [NSDictionary dictionaryWithObjectsAndKeys:panList, @"panList", transType, @"transType", year, @"year", month, @"month", [@(pageIndex) stringValue], @"currentPage", UP_STR(@"kStrPageSize"), @"pageSize", nil];
    
    UPWMessage* message = [UPWMessage messageCostRecordWithParams:dict];
    [self loadMoreDataWithMessage:message showLoadingView:(section == 0)];
    
    _curSection = section;
    _currentPage = pageIndex;
    
    _menuBar.buttonInteractionEnabled = NO;
}

- (void)didReceivedWithData:(NSDictionary *)responseJSON
{
    [super didReceivedWithData:responseJSON];
    
    _menuBar.buttonInteractionEnabled = YES;
    
    NSDictionary * params = [responseJSON objectForKey:kJSONParamsKey];
    NSArray * curPageTrans = [params objectForKey:@"trans"];
    
    NSString *incomeValue = [params objectForKey:@"incomeValue"];
    NSString *expenseValue = [params objectForKey:@"expenseValue"];
    if (!incomeValue || incomeValue.length == 0) {
        incomeValue = @"0";
    }
    if (!expenseValue || expenseValue.length == 0) {
        expenseValue = @"0";
    }
    
    NSArray * records = [self dataInSection:_curSection];
    if(records.count > 0) {
        NSMutableArray * newData = [NSMutableArray arrayWithArray:records];
        [newData addObjectsFromArray:curPageTrans];
        records = [newData copy];
    }
    else {
        records = curPageTrans;
        if(records == nil) {
            records = @[];
        }
    }
    
    NSDictionary * sectionInfo = @{@"month":_sectionKeys[_curSection], @"income":incomeValue, @"expense":expenseValue, kCurPageIndex:@(_currentPage), kCurSectionIndex:@(_curSection), kIsMoreDataAvailable:@(_isSectionLoadedDone)};
    
    [_dataHere setObject:@{@"section":sectionInfo, @"record":records} forKey:_sectionKeys[_curSection]];
    
    //如果当月的记录数为0，则默认收缩section
    if (curPageTrans.count == 0) {
        _isUnfoldArray[_curSection] = @(![_isUnfoldArray[_curSection] boolValue]);
    }
    
    _isPrevReqSuccess = YES;
    _isSectionLoadedDone = ([params[@"haveNext"] boolValue] == NO);
    _tempRecordNum += curPageTrans.count;
    
    [self setupTableView];
    [self setupTipMark];
    [self setupMenuBar];
    
    [_tableView reloadData];
    [_tableView.infiniteScrollingView stopAnimating];
    _tableView.showsInfiniteScrolling = [self isMoreDataAvailable];
    
    if((_tempRecordNum == 0) && (_tableView.showsInfiniteScrolling == NO)) {
        CGSize size = _tableView.frame.size;
        [self showNoContentView:CGPointMake(size.width / 2, size.height / 2)];
    }
    else if(_tempRecordNum < 15) {
        // 拉下一个月的数据争取占满屏幕
        [self loadTableListData];
    }
    
    // 进入花销分析页面。
    if(!_onceFlag) {
        [self setRightButtonWithImage:@"huaxiao_analysis" target:self action:@selector(openMyExpenseAnalysisPage:)];
        _onceFlag = YES;
    }
}

- (BOOL)isMoreDataAvailable
{
    if((_curSection == kMaxReqSections - 1) && _isSectionLoadedDone) {
        return NO;
    }
    
    return YES;
}

- (BOOL)didReceivedWithError:(NSError *)error
{
    BOOL ret = [super didReceivedWithError:error];
    // 父类如果没处理的话，让子类来处理
    if(!ret) {
        [_tableView.infiniteScrollingView stopAnimating];
        if(_curSection == kFirstSectionIndex) {
            [self showFlashInfo:[self msgWithError:error]];
            [self showNetworkFailed];
        }
    }
    
    _isPrevReqSuccess = NO;
    _menuBar.buttonInteractionEnabled = YES;
    
    return YES;
}

- (void)openMyExpenseAnalysisPage:(id)sender
{
    // 我的花销
    NSDictionary * params = @{@"pageUrl":@{@"uri":@"hybrid_v3/html/data/myexpense.html", @"params":@{}}, @"navBar":@{@"title":UP_STR(@"String_HuaXiao_Analysis"), @"showBill":@YES}};
    UPWWebData * webData = [[UPWWebData alloc] initWithLaunchType:ELaunchTypeUniversalWebDriven poiData:params];
    [self.navigationController pushViewController:[[UPWWebViewController alloc] initWithWebData:webData] animated:YES];
}

#pragma mark - UPWUnionMenuDelegate

- (NSInteger)unionMenuBar:(UPWUnionMenuBar *)unionMenuBar numberOfRowsAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.upIndex == 0) {
        // card list
        return (_cardsListModel.bindRelations.count + 1);
    }
    else {
        // types filters
        return _filters.count;
    }
}

- (id)unionMenuBar:(UPWUnionMenuBar *)unionMenuBar dataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.upIndex == 0) {
        // card list
        if(indexPath.upRow == 0) {
            return UP_STR(@"全部银行卡");
        }
        else {
            UPWCardModel * cardModel = _cardsListModel.bindRelations[indexPath.upRow - 1];
            NSString *bankNum = [UPWAppUtil trimBankNumber:cardModel.pan];
            return [UPWAppUtil formatBankNumberWithStar:bankNum];
        }
    }
    else {
        // types filters
        return self.filters[indexPath.upRow][@"value"];
    }
}

- (void)unionMenuBar:(UPWUnionMenuBar *)unionMenuBar didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.upIndex == 0) {
        // card list
        if(indexPath.upRow == 0) {
            // 选择全部银行卡，传nil
            _selectedBkCard = nil;
        }
        else {
            _selectedBkCard = _cardsListModel.bindRelations[indexPath.upRow - 1];
            
            if(_selectedBkCard.pan.length > kBKCardNormalLength/* && (kScreenWidth <= 320)*/ && _menuButton) {
                NSString *bankNum = [UPWAppUtil trimBankNumber:_selectedBkCard.pan];
                NSString * cardWithStar =[UPWAppUtil formatBankNumberWithStar:bankNum];
                cardWithStar = [cardWithStar stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                if(cardWithStar.length > kBKCardMaxLength) {
                    NSString * first = [cardWithStar substringToIndex:4];
                    NSString * last = [cardWithStar substringWithRange:NSMakeRange(cardWithStar.length - 5, 5)];
                    cardWithStar = [NSString stringWithFormat:@"%@**********%@", first, last];
                }
                
                [_menuButton setButtonTitle:cardWithStar showWordsLength:cardWithStar.length];
            }
        }
    }
    else {
        _selectedCostType = self.filters[indexPath.upRow][@"key"];
    }
    
    if(_selectedBkCard && _selectedBkCard.supPay.boolValue == NO) {
        [self setupRealAuthenPage];
    }
    else {
        _noContentView.hidden = YES;
        [_tableView removeFromSuperview];
        _tableView = nil;
        
        [self initialize];
        [self fetchCostRecordInSection:kFirstSectionIndex withPageIndex:kMessagePageReqStartIndex];
    }
}

// 此需求后面取消掉了

//- (NSString *)unionMenuBar:(UPWUnionMenuBar *)unionMenuBar leftImageUrlForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return self.filters[indexPath.upRow][@"icon"];
//}

- (void)didSelectUnionMenuButton:(UPWUnionMenuButton *)unionMenuButton
{
    [_contentView bringSubviewToFront:_menuBar];
}

#pragma mark -- 实名认证卡成功以后回调

- (void)bindCardSuccessHandlerWithCardPan:(NSString *)cardPan
{
    [super bindCardSuccessHandlerWithCardPan:cardPan];
    
    // 重新加载页面数据
    [self initialize];
    [self postCardList];
}

#pragma mark -
#pragma mark  点击重新加载

- (void)reloadData
{
    [self fetchCostRecordInSection:kFirstSectionIndex withPageIndex:kMessagePageReqStartIndex];
}

@end

