//
//  UPHistoryView.m
//  UPWallet
//
//  Created by wxzhao on 14-7-12.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//

#import "UPWHistoryView.h"
#import "UPWLocalStorage.h"
#import "UPWConst.h"


@implementation UPWTabelViewSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.frame.size.height - 0.5, kScreenWidth-10, 0.5)];
        imageView.image = [UIImage imageNamed:@"separator"];
        [self addSubview:imageView];
    }
 
    return self;
}
@end


@interface UPWHistoryView()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView* _tableView;
    NSMutableArray* _historyArray;
    
    UITableView* _filterTableView;
    NSMutableArray* _filterArray;
}

@end

@implementation UPWHistoryView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray* histroyArray = (NSArray*)[UPWLocalStorage searchHistory];
        _historyArray = [[NSMutableArray alloc] initWithArray:histroyArray];
        _filterArray = [[NSMutableArray alloc] init];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
        
        // 过滤
        _filterTableView = [[UITableView alloc] initWithFrame:_tableView.frame style:UITableViewStylePlain];
        _filterTableView.dataSource = self;
        _filterTableView.delegate = self;
        _filterTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _filterTableView.hidden = YES;
        [self addSubview:_filterTableView];
        
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_filterTableView == tableView) {
        return [_filterArray count];
    }
    
    NSInteger count = [_historyArray count];
    if (0 == count) {
        return count;
    } else {
        return count + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_filterTableView == tableView) {
        static NSString *CellIdentifier = @"FilterCellIdentifier";
        
        UPWTabelViewSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
        {
            cell = [[UPWTabelViewSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = [_filterArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.textColor = UP_COL_RGB(0x464646);
        
        return cell;;
    }
    
    static NSString* identifier = @"HistoryCellIdentifier";
    UPWTabelViewSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell)
	{
		cell = [[UPWTabelViewSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    if (indexPath.row == [_historyArray count]) {
        cell.textLabel.text = UP_STR(@"kStrClearSearchHistory");
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = UP_COL_RGB(0x007aff);
    }
    else {
        cell.textLabel.text = [_historyArray objectAtIndex:indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.textColor = UP_COL_RGB(0x464646);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_filterTableView == tableView || 0 == [_historyArray count]) {
        return 0;
    }
    
    return 29;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_filterTableView == tableView || 0 == [_historyArray count]) {
        return nil;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 29)];
    headerView.backgroundColor = UP_COL_RGB(0xffffff);
//    headerView.layer.borderWidth = 0.5;
//    headerView.layer.borderColor = UP_COL_RGB(0xd4d4d4).CGColor;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, CGRectGetWidth(headerView.frame)-16, CGRectGetHeight(headerView.frame))];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = UP_COL_RGB(0x333333);
    headerLabel.textAlignment = NSTextAlignmentLeft;
    headerLabel.font = [UIFont systemFontOfSize:12];
    headerLabel.text = UP_STR(@"StrNearestSearchingHistory");
    [headerView addSubview:headerLabel];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame) - 0.5, CGRectGetWidth(headerView.frame), 0.5)];
    imageView.image = [UIImage imageNamed:@"separator"];
    [headerView addSubview:imageView];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
 
    if (_filterTableView == tableView) {
        [self.delegate didSelectString:[_filterArray objectAtIndex:indexPath.row]];
    } else {
        if (indexPath.row == [_historyArray count]) {
            // 清除搜索记录
            [_historyArray removeAllObjects];
            [_tableView reloadData];
            [UPWLocalStorage insertSearchHistory:nil];
        }
        else{
            [self.delegate didSelectString:[_historyArray objectAtIndex:indexPath.row]];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.delegate historyViewWillBeginDragging:self];
}

#pragma mark -
#pragma mark - 保存记录
- (void)saveSearchString:(NSString *)searchString
{
    // 删除重复的历史记录
    for (NSString* item in _historyArray) {
        if ([item isEqualToString:searchString]) {
            [_historyArray removeObject:item];
            break;
        }
    }
    
    [_historyArray insertObject:searchString atIndex:0];
    [_tableView reloadData];
    [UPWLocalStorage insertSearchHistory:_historyArray];
}

#pragma mark -
#pragma mark - 显示不同的view
- (void)showHistoryView:(BOOL)show
{
    if (_tableView) {
        _tableView.hidden = !show;
        if (show) {
            [self bringSubviewToFront:_tableView];
        }
    }
}

- (void)showFilterView:(BOOL)show
{
    if (_filterTableView) {
        _filterTableView.hidden = !show;
        if (show) {
            [self bringSubviewToFront:_filterTableView];
        }
    }
}

#pragma mark -
#pragma mark - 过滤fuction
- (void)filterKeyword:(NSString*)keyword
{
    NSString * searchString = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([searchString length] <= 0)
        return;
    
    [_filterArray removeAllObjects];
    [_historyArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        NSString * cityEnNm = [obj lowercaseString];
        if([cityEnNm hasPrefix:[searchString lowercaseString]]) {
            [_filterArray addObject:obj];
        }
    }];
    
    if([_filterArray count] == 0) {
        [_historyArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             // 汉字
             NSRange textRange = [obj rangeOfString:searchString options:NSCaseInsensitiveSearch];
             if(textRange.location != NSNotFound) {
                 // find sub-string.
                 [_filterArray addObject:obj];
             }
         }];
    }
    
    [self showHistoryView:NO];
    [self showFilterView:YES];
    [_filterTableView reloadData];
}

@end
