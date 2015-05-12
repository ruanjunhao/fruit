//
//  UPUnionDoubleListCHSP.m
//  ttttttestv
//
//  Created by TZ_JSKFZX_CAOQ on 13-11-11.
//  Copyright (c) 2013年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWUnionDoubleListCHSP.h"
#import "UPWConst.h"

#define kDoubleListCellHeight 43
#define kDoubleLeftListWidth 108

@implementation UPWUnionLeftListCHSPCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = UP_COL_RGB(0x333333);
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.highlightedTextColor = UP_COL_RGB(0xea9c00);
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        
        UIImageView* selectViewBg= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kDoubleListCellHeight)];
        selectViewBg.image = [[UIImage imageNamed:@"leftlist_selected_bg"] stretchableImageWithLeftCapWidth:1 topCapHeight:1];
        selectViewBg.backgroundColor = UP_COL_RGB(0xffffff);
        self.selectedBackgroundView = selectViewBg;
        self.backgroundColor = UP_COL_RGB(0xffffff);
        
        if (!UP_iOSgt7) {
            UIImageView* v = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kDoubleListCellHeight)];
            v.image = [[UIImage imageNamed:@"leftlist_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 1, 1)];
            v.backgroundColor = UP_COL_RGB(0xf7f7f7);
            self.backgroundView = v;
            
            UIImage* line = [[UIImage imageNamed:@"separator"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
            UIImageView* buttomLine = [[UIImageView alloc]
                                       initWithFrame:CGRectMake(0, kDoubleListCellHeight+0.5, CGRectGetWidth(self.frame), 0.5)];
            buttomLine.image = line;
            [self.contentView addSubview:buttomLine];
        } else {
            UIImageView* v = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kDoubleListCellHeight)];
            v.image = [[UIImage imageNamed:@"leftlist_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 1, 1)];
            v.backgroundColor = UP_COL_RGB(0xf7f7f7);
            self.backgroundView = v;
        }
    }
    return self;
}

- (void)setMenuImage:(UIView *)menuImage
{
    if (_menuImage != menuImage) {
        [_menuImage removeFromSuperview];
        _menuImage = menuImage;
        [self.contentView addSubview:_menuImage];
    }
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    CGFloat cellWidth = self.frame.size.width;
    CGFloat cellHeight = self.frame.size.height;
    CGFloat x = CGRectGetMaxX(_menuImage.frame) + 16;
    self.textLabel.frame = CGRectMake(x, 0, cellWidth - x -4, cellHeight);
}

@end
@implementation UPWUnionRightListCHSPCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = UP_COL_RGB(0x333333);
        self.textLabel.font = [UIFont systemFontOfSize:14];
        self.textLabel.highlightedTextColor = UP_COL_RGB(0xea9c00);
        
        UIView* selectViewBg= [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), kDoubleListCellHeight+1)];
        selectViewBg.backgroundColor = [UIColor clearColor];//UP_COL_RGB(0xffffff);
        self.selectedBackgroundView = selectViewBg;
        self.backgroundColor = UP_COL_RGB(0xffffff);
        
        UIImageView* line = [[UIImageView alloc] initWithFrame:CGRectMake(22, kDoubleListCellHeight+0.5, CGRectGetWidth(self.frame), 0.5)];
        line.image = [[UIImage imageNamed:@"separator"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        [self.contentView addSubview:line];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGFloat cellWidth = self.frame.size.width;
    CGFloat cellHeight = self.frame.size.height;
    self.textLabel.frame = CGRectMake(22, 0, cellWidth-22, cellHeight);
}

@end
@interface UPWUnionDoubleListCHSP()<UITableViewDelegate,UITableViewDataSource>
{
    UIView *_leftWrapperView;
    UIView *_rightWrapperView;
    UIImageView *_lineWrapperView;
    UIView *_tableViewWrapperView;
    UPWUnionMenuListTableView *_leftTableView;
    UPWUnionMenuListTableView *_rightTableView;
    NSInteger _leftSelectIndexCache;//如果不点击右侧的list, 那么不认为是一次需要记住的select, 需要cache住之前左侧列表选中的项,在收起时恢复
}
@end

@implementation UPWUnionDoubleListCHSP

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _leftSelectIndexCache = -1;
        
        _tableViewWrapperView = [[UIView alloc] initWithFrame:CGRectZero];
        
        _leftWrapperView = [[UIView alloc] initWithFrame:CGRectZero];
        _leftWrapperView.backgroundColor = UP_COL_RGB(0xf7f7f7);
        [_tableViewWrapperView addSubview:_leftWrapperView];
        
        _rightWrapperView = [[UIView alloc] initWithFrame:CGRectZero];
        _rightWrapperView.backgroundColor = UP_COL_RGB(0xf7f7f7);
        [_tableViewWrapperView addSubview:_rightWrapperView];
        
        _lineWrapperView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _lineWrapperView.image = [[UIImage imageNamed:@"separator"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        [_tableViewWrapperView addSubview:_lineWrapperView];
        
        [self addSubview:_tableViewWrapperView];
        
        _leftTableView = [[UPWUnionMenuListTableView alloc] initWithFrame:CGRectZero];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        _leftTableView.backgroundColor = UP_COL_RGB(0xf7f7f7);
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableViewWrapperView addSubview:_leftTableView];
        
        _rightTableView = [[UPWUnionMenuListTableView alloc] initWithFrame:CGRectZero];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        _rightTableView.backgroundColor = UP_COL_RGB(0xffffff);
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableViewWrapperView addSubview:_rightTableView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect rect = self.listDisplayRect;
//    固定高度
//    NSInteger totalHeight = [_leftTableView numberOfRowsInSection:0]*kDoubleListCellHeight + kMenuBarHeight;
//    if (totalHeight < rect.size.height) {
//        rect.size.height = totalHeight;
//    }
    
    _tableViewWrapperView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0);
    
    CGFloat tableViewHeight = rect.size.height;

    CGRect rectLeft = CGRectMake(0, 0, kDoubleLeftListWidth, tableViewHeight);

    _leftTableView.frame = CGRectMake(0, 0, kDoubleLeftListWidth, 0);
    
    CGRect rectRight = CGRectMake(kDoubleLeftListWidth, 0, self.frame.size.width - kDoubleLeftListWidth,tableViewHeight);
    _rightTableView.frame = CGRectMake(kDoubleLeftListWidth, 0, self.frame.size.width - kDoubleLeftListWidth, 0);
    
    _leftWrapperView.frame = CGRectMake(0, 0, kDoubleLeftListWidth, 0);
    _rightWrapperView.frame = CGRectMake(kDoubleLeftListWidth, 0, self.frame.size.width - kDoubleLeftListWidth, 0);
    _lineWrapperView.frame = CGRectMake(kDoubleLeftListWidth-0.5,0, 0.5, 0);
    
    [ UIView animateWithDuration:.5f animations:^{
        _tableViewWrapperView.frame = rect;
        _leftTableView.frame = rectLeft;
        _rightTableView.frame = rectRight;
        _leftWrapperView.frame = CGRectMake(0, tableViewHeight, kDoubleLeftListWidth, 0);
        _rightWrapperView.frame = CGRectMake(kDoubleLeftListWidth, tableViewHeight, self.frame.size.width - kDoubleLeftListWidth, 0);
        _lineWrapperView.frame = CGRectMake(kDoubleLeftListWidth-0.5, 0, 0.5, tableViewHeight);
    }];
}

- (void)reloadData
{
    [_leftTableView reloadData];
    [_rightTableView reloadData];
    
}

- (void)selectRowsByItems:(NSSet*)set
{
    //left table
    NSPredicate *predicate = [NSPredicate predicateWithFormat:KSTR_FILTER_PREDICATE, self.button.index, 1];
    NSSet* filteredSet =[set filteredSetUsingPredicate:predicate];
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:[[filteredSet anyObject] upRow] inSection:0];
    [_leftTableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    //right table
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:KSTR_FILTER_PREDICATE, self.button.index, 2];
    NSSet* filteredSet2 =[set filteredSetUsingPredicate:predicate2];
    
    NSIndexPath* path2 = [NSIndexPath indexPathForRow:[[filteredSet2 anyObject] upRow] inSection:0];
    [_rightTableView selectRowAtIndexPath:path2 animated:YES scrollPosition:UITableViewScrollPositionNone];
}


- (void)willCloseMenuList
{
    //恢复_leftSelectIndexCache
    if (_leftSelectIndexCache != -1) {
        NSIndexPath* path = [NSIndexPath indexPathForRow:_leftSelectIndexCache inColumn:1 inIndex:self.button.index];
        [self.delegate unionMenuList:self didSelectItemAtIndexPath:path];
        _leftSelectIndexCache = -1;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((_leftSelectIndexCache == -1) && (tableView == _leftTableView)) {
        _leftSelectIndexCache = [_leftTableView indexPathForSelectedRow].row;
    }
    if (tableView == _rightTableView) {
        _leftSelectIndexCache = -1;
    }
    return indexPath;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger column = (tableView == _leftTableView) ? 1 : 2;

    NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inColumn:column inIndex:self.button.index];
    [self.delegate unionMenuList:self didSelectItemAtIndexPath:path];
    
    if (tableView == _leftTableView) {
        [_rightTableView reloadData];
    }
    else{
        [self.button setButtonTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text showWordsLength:self.button.showWordsLength];
        [self willCloseMenuList];
        [self closeMenuList];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger column = (tableView == _leftTableView) ? 1 : 2;
    NSIndexPath* path = [NSIndexPath indexPathForRow:0 inColumn:column inIndex:self.button.index];
    return [self.delegate unionMenuList:self numberOfRowsAtIndexPath:path];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _rightTableView) {
        static NSString* identifier = @"UPUnionMenuBarDoubleRightListCHSP";
        UPWUnionRightListCHSPCell *rightCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (rightCell == nil)
        {
            rightCell = [[UPWUnionRightListCHSPCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        NSIndexPath* path = [NSIndexPath indexPathForRow:indexPath.row inColumn:2 inIndex:self.button.index];
        rightCell.textLabel.text = [self.delegate unionMenuList:self dataForItemAtIndexPath:path];
        return rightCell;
    }
    else if (tableView == _leftTableView) {
        static NSString* identifier = @"UPUnionMenuBarDoubleLeftListCHSP";
        UPWUnionLeftListCHSPCell *leftCell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == leftCell)
        {
            leftCell = [[UPWUnionLeftListCHSPCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        NSIndexPath* titlePath = [NSIndexPath indexPathForRow:indexPath.row inColumn:1 inIndex:self.button.index];
        leftCell.textLabel.text = [self.delegate unionMenuList:self dataForItemAtIndexPath:titlePath];
//        NSIndexPath* imgPath = [NSIndexPath indexPathForRow:indexPath.row inColumn:0 inIndex:self.button.index];
//        UIView* view = [self.delegate unionMenuList:self dataForItemAtIndexPath:imgPath];
//        view.frame = CGRectMake(12, 12, 20, 20);
        leftCell.menuImage = nil;
        return leftCell;
    }
    else{
        return nil;
    }
}


@end
