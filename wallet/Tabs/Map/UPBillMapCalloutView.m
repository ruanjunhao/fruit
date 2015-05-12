//
//  UpMapCalloutView.m
//  newStyleMap
//
//  Created by jhyu on 13-11-20.
//  Copyright (c) 2013年 cup. All rights reserved.
//

#import "UPBillMapCalloutView.h"
#import "UPMKPinAnnotationView.h"

#import "UPWMyFPModel.h"
#import "UPUtils.h"

#define PageCtrlHeight 39.0f

//******************** UPBillMapCalloutView **********************

@protocol UpPrevNextControlDelegate <NSObject>
@optional
- (void)curIndexDidChanged;
@end

@interface UPPrevNextControl : UIView {
    UIButton*   _infoBtn;
    UIButton*   _prevBtn;
    UIButton*   _nextBtn;
}

@property (nonatomic, strong) NSArray * dataArray;
@property (nonatomic) NSInteger curIndex;
@property (nonatomic, weak) id<UpPrevNextControlDelegate> delegate;
@end

@interface UPBillMapCalloutView () <UpPrevNextControlDelegate> {
    UPPrevNextControl*  _pnCtrl;
    NSArray*            _dataArray;
    
    __weak MKAnnotationView*   _annotationView;
    
    UILabel*  _nameLabel;
    UILabel*  _addrLabel;
    UILabel*  _timeLabel;
    UILabel*  _valueLabel;
}

@end

@implementation UPBillMapCalloutView

#pragma mark - System methods

- (id)initWithAnnotationView:(MKAnnotationView *)annotationView
{
    self = [super initWithFrame:CGRectMake(0, 0, 215, 103)];
    if(self) {
        _annotationView = annotationView;
        if([annotationView.annotation isKindOfClass:[UPWAnnotation class]]) {
            _dataArray = [(UPWAnnotation *)annotationView.annotation bills];
        }
        
        [self loadComponents];
    }
    
    return self;
}

#pragma mark - Helpers

- (void)loadComponents
{
    // 商户名
    CGRect rc = CGRectMake(14, 6, 201, 36);
    _nameLabel = [[UILabel alloc] initWithFrame:rc];
    _nameLabel.textColor = [UIColor colorWithKeyName:UP_COLOR_DARK_GREY];
    _nameLabel.font = [UIFont systemFontOfSize:17.0f];
    [self addSubview:_nameLabel];

    // 商户地址
    _addrLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 30, 201, 33)];
    _addrLabel.textColor = [UIColor colorWithKeyName:UP_COLOR_LIGHT_GREY];
    _addrLabel.font = [UIFont systemFontOfSize:12.0f];
    [self addSubview:_addrLabel];
    
    // 消费时间
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 55, 201, 21)];
    _timeLabel.textColor = [UIColor colorWithKeyName:UP_COLOR_LIGHT_GREY];
    _timeLabel.font = [UIFont systemFontOfSize:13.0f];;
    [self addSubview:_timeLabel];
    
    // 交易金额
    _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 71, 201, 21)];
    _valueLabel.textColor = [UIColor colorWithKeyName:UP_COLOR_DARK_GREY];
    _valueLabel.font = [UIFont systemFontOfSize:17.0f];;
    [self addSubview:_valueLabel];
    
    // 多个BILL，用翻页模式显示。
    if([self isPageViewMode]) {
        const NSUInteger pnCtlHeight = 30;
        
        if(!_pnCtrl) {
            CGRect rc = self.bounds;
            rc.size.height = pnCtlHeight;
            rc.origin.y = self.bounds.size.height - 8.0f; //arrowCtlHeight;
            _pnCtrl = [[UPPrevNextControl alloc] initWithFrame:rc];
            _pnCtrl.delegate = self;
        }
        
        _pnCtrl.dataArray = _dataArray;
        _pnCtrl.curIndex = 0;
        
        CGRect newRC = self.frame;
        newRC.size.height += pnCtlHeight;
        self.frame = newRC;
        
        [self addSubview:_pnCtrl];
    }
    else {
        // single bill mode.
        [self refreshViewWithDataArray:_dataArray atIndex:0];
    }
    
    // 白色背景，边角阴影背景框
    CGRect coFrame = self.frame;
    CGPoint calloutOffset = _annotationView.centerOffset;
    CGFloat topOffset = _annotationView.calloutOffset.y;
    
    calloutOffset.y -= coFrame.size.height + topOffset; // 22 is UI desgin.
    calloutOffset.x -= coFrame.size.width / 2;
    coFrame.origin = calloutOffset;
    self.frame = coFrame;
    
    CGRect rect = coFrame;
    UIImage * calloutBgImage;
    UIImage * arrowImage;
    if([self isPageViewMode]) {
        calloutBgImage = [UIImage imageNamed:@"map_pop_page_body"];
        calloutBgImage = [calloutBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 25, 47, 25)];
        arrowImage = [UIImage imageNamed:@"map_pop_page_arrow"];
    }
    else {
        calloutBgImage = [UIImage imageNamed:@"map_pop_body"];
        calloutBgImage = [calloutBgImage stretchableImageWithLeftCapWidth:calloutBgImage.size.width/2 topCapHeight:calloutBgImage.size.height/2];
        arrowImage = [UIImage imageNamed:@"map_pop_arrow"];
    }
    
    CGRect rcArrow = CGRectZero;
    rcArrow.size = arrowImage.size;
    
    CGRect rcBgImage = rect;
    rcBgImage.origin.x = 0;
    rcBgImage.origin.y = 0;
    rcBgImage.size.height -= rcArrow.size.height;
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:rcBgImage];
    imageView.image = calloutBgImage;
    [self insertSubview:imageView atIndex:0];
    
    // 剪头图标
    CGPoint point;
    point.y = rcBgImage.origin.y + rcBgImage.size.height;
    point.y -= 2.0f; // 剪头位置调整。
    point.x = (rcBgImage.size.width - arrowImage.size.width) / 2;
    rcArrow.origin = point;
    UIImageView * arrowImageView = [[UIImageView alloc] initWithFrame:rcArrow];
    arrowImageView.image = arrowImage;
    [self addSubview:arrowImageView];
    
    [UPUtils setAllLabelsClearColorByContainerView:self];
}

- (BOOL)isPageViewMode
{
    return (_dataArray.count > 1);
}

- (void)updateModelData
{
    if([_annotationView.annotation isKindOfClass:[UPWAnnotation class]]) {
        _dataArray = [(UPWAnnotation *)_annotationView.annotation bills];
    }

    if([self isPageViewMode]) {
        _pnCtrl.dataArray = _dataArray;
        _pnCtrl.curIndex = 0;
    }
    else {
        // single bill mode.
        [self refreshViewWithDataArray:_dataArray atIndex:0];
    }
}

#pragma mark -- UpPrevNextControlDelegate

- (void)curIndexDidChanged
{
    NSAssert(_pnCtrl.curIndex < _pnCtrl.dataArray.count, @"");
    [self refreshViewWithDataArray:_pnCtrl.dataArray atIndex:_pnCtrl.curIndex];
}

- (void)refreshViewWithDataArray:(NSArray *)dataArray atIndex:(NSInteger)index
{
    UPWMyFPCellModel * model = (UPWMyFPCellModel *)dataArray[index];
    _nameLabel.text = model.bizName;
    _addrLabel.text = model.bizAddr;
    _timeLabel.text = [NSString stringWithFormat:@"%@ %@", model.transDt, model.transTm];
    _valueLabel.text = [NSString stringWithFormat:@"%.2f%@", model.transValue / 100.0f, kStrUnitYuan];
}

@end



//**************************** Class  UPPrevNextControl ***********************************

#pragma mark - UPPrevNextControl

@implementation UPPrevNextControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubControls];
    }
    return self;
}

- (void)setCurIndex:(NSInteger)curIndex
{
    NSAssert(curIndex >= 0, @"");
    
    _curIndex = curIndex;
    
    _prevBtn.enabled = YES;
    _nextBtn.enabled = YES;
    if(_curIndex == 0) {
        _prevBtn.enabled = NO;
    }
    else if(_curIndex == _dataArray.count - 1) {
        _nextBtn.enabled = NO;
    }

    [_infoBtn setTitle:[self textInfo] forState:UIControlStateNormal];
    
    if([_delegate respondsToSelector:@selector(curIndexDidChanged)]) {
        [_delegate curIndexDidChanged];
    }
}

- (void)addSubControls
{
    self.backgroundColor = [UIColor clearColor];
    // 使用UIButton而非UILabel是因为我们希望这一区域的点击事件是能够被捕获的，而不会把Annotation消掉。
    _infoBtn = [[UIButton alloc] initWithFrame:self.bounds];
    _infoBtn.backgroundColor = [UIColor clearColor];
    [_infoBtn setTitle:[self textInfo] forState:UIControlStateNormal];
    [_infoBtn setTitleColor:[UIColor colorWithHexValue:@"fe7e2d"] forState:UIControlStateNormal];
    _infoBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [self addSubview:_infoBtn];
    
    _prevBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * prevImage = [UIImage imageNamed:@"pt_annotation_left"];
    CGRect rc = self.bounds;
    rc.size.width /= 3;
    [_prevBtn setImage:prevImage forState:UIControlStateNormal];
    _prevBtn.frame = rc;
    [_prevBtn addTarget:self action:@selector(prevBtnClckAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_prevBtn];
    
    CGRect rcR = rc;
    rcR.origin.x = self.bounds.size.width - rcR.size.width;
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * nextImage = [UIImage imageNamed:@"pt_annotation_right"];
    [_nextBtn setImage:nextImage forState:UIControlStateNormal];
    _nextBtn.frame = rcR;
    [_nextBtn addTarget:self action:@selector(nextBtnClckAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_nextBtn];
}

- (NSString *)textInfo
{
    return [NSString stringWithFormat:kStrMapCostRecord, _curIndex + 1, self.dataArray.count];
}

- (void)prevBtnClckAction:(id)sender
{
    if(self.curIndex > 0) {
        --self.curIndex;
    }
}

- (void)nextBtnClckAction:(id)sender
{
    if(self.curIndex < self.dataArray.count - 1) {
        ++self.curIndex;
    }
}

@end

