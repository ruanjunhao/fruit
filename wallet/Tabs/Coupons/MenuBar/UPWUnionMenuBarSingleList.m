//
//  UPUnionSingleListCHSP.m
//  ttttttestv
//
//  Created by TZ_JSKFZX_CAOQ on 13-11-11.
//  Copyright (c) 2013年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWUnionMenuBarSingleList.h"
#import "UPWConst.h"
#import "UPWBussUtil.h"
#import "UPWPathUtil.h"
#import "UIImageView+MKNetworkKitAdditions_johankool.h"

#define kSingleListCellHeight 44

@implementation UPWUnionMenuBarSingleListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = UP_COL_RGB(0x464646);
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.highlightedTextColor = UP_COL_RGB(0xea9c00);
        
        UIView* selectViewBg= [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kSingleListCellHeight)];
        selectViewBg.backgroundColor = [UIColor clearColor];//UP_COL_RGB(0xffffff);
        self.selectedBackgroundView =selectViewBg;
        self.backgroundColor = UP_COL_RGB(0xffffff);
        
        UIImageView* line = [[UIImageView alloc] initWithFrame:CGRectMake(0, kSingleListCellHeight-0.5, kScreenWidth, 0.5)];
        line.image = [[UIImage imageNamed:@"separator"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        [self addSubview:line];
    }
    return self;
}

@end

@interface UPWUnionMenuBarSingleList()<UITableViewDelegate,UITableViewDataSource>
{
    UIView* _tableViewWrapperView;
    UPWUnionMenuListTableView* _tableView;
}
@end

@implementation UPWUnionMenuBarSingleList

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _tableViewWrapperView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableViewWrapperView.backgroundColor = UP_COL_RGB(0xf4f4f4);//(0xf0f0f0);
        [self addSubview:_tableViewWrapperView];
        
        
        _tableView = [[UPWUnionMenuListTableView alloc] initWithFrame:CGRectZero];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UP_COL_RGB(0xf4f4f4);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableViewWrapperView addSubview:_tableView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.listDisplayRect;
//   固定高度
//    NSInteger totalHeight = [_tableView numberOfRowsInSection:0]*kSingleListCellHeight + kMenuBarHeight;
//    if (totalHeight < rect.size.height) {
//        rect.size.height = totalHeight;
//    }

    _tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0);
    _tableViewWrapperView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0);

    [UIView animateWithDuration:.5f animations:^{
        _tableViewWrapperView.frame = rect;
        //5像素下边距
//        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, 5, 0);
//        CGRect result = UIEdgeInsetsInsetRect(rect, contentInsets);
        _tableView.frame = rect;
    }];
}

- (void)reloadData
{
    [_tableView reloadData];
}

- (void)selectRowsByItems:(NSSet*)set
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:KSTR_FILTER_PREDICATE, self.button.index, 0];
    NSSet* filteredSet =[set filteredSetUsingPredicate:predicate];
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:[[filteredSet anyObject] upRow] inSection:0];
    [_tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kSingleListCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.button setButtonTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text showWordsLength:self.button.showWordsLength];
    NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inColumn:0 inIndex:self.button.index];
    [self.delegate unionMenuList:self didSelectItemAtIndexPath:path];
    [self willCloseMenuList];
    [self closeMenuList];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSIndexPath* path = [NSIndexPath indexPathForRow:0 inColumn:0 inIndex:self.button.index];
    return [self.delegate unionMenuList:self numberOfRowsAtIndexPath:path];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"UPWUnionMenuBarSingleList";
    UPWUnionMenuBarSingleListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (nil == cell)
	{
		cell = [[UPWUnionMenuBarSingleListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inColumn:0 inIndex:self.button.index];
    cell.textLabel.text = [self.delegate unionMenuList:self dataForItemAtIndexPath:path];
    
    if([self.delegate respondsToSelector:@selector(unionMenuList:leftImageUrlForItemAtIndexPath:)]) {
        NSString * iconPath = [self.delegate unionMenuList:self leftImageUrlForItemAtIndexPath:path];
        if([UPWBussUtil isWebFullUrl:iconPath]) {
            //这里要拼一个url
            NSURL* url = nil;
            if (!UP_IS_NIL(UP_SHDAT.sysInitModel.imgFolder)) {
                url = [UPWPathUtil urlWithFolder:UP_SHDAT.sysInitModel.imgFolder withURL:iconPath];
            }
            else{
                url = UP_URL(iconPath);
            }
            
            [cell.imageView mk_setImageAtURL:url forceReload:NO showActivityIndicator:YES loadingImage:nil fadeIn:YES notAvailableImage:nil];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:iconPath];
        }
    }
    
    return cell;
}

@end
