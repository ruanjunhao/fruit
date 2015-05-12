//
//  UPWMineInfoViewController.m
//  wallet
//
//  Created by gcwang on 15/3/23.
//  Copyright (c) 2015年 China Unionpay Co.,Ltd. All rights reserved.
//

#import "UPWMineInfoViewController.h"
#import "UPWSelectDeliveryAddressViewController.h"
#import "UPWActionSheet.h"
#import "UPWAccountInfoModel.h"
#import "UPWNotificationName.h"
#import "UPWBussUtil.h"
#import "UPWPathUtil.h"
#import "UPWImageUtil.h"
#import "UPWFileUtil.h"
#import "UPWPathUtil.h"

#define kHeightHeaderImage 88
#define kHeightOtherCell 44
#define kHeightCellHeader 20

@interface UPWMineInfoViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    NSArray* _titleArray;//标题
    UIImageView* _faceImageView;//头像imageview
    UIImagePickerController * _imagePicker;
    UITapGestureRecognizer * _tapGR;//点击放大
    UITapGestureRecognizer * _tapGR1;//点击取消
    UIView * _blackView; //放大image的背景
    
//    UPWAccountInfoModel *_accountInfoModel;
}

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *titleArray;
@property (nonatomic, strong) UPXCommonTextField *passwordTextField;
@property (nonatomic, strong) UPXAlertView *openServiceAlert;

@end

@implementation UPWMineInfoViewController

- (void)dealloc
{
    [UP_NC removeObserver:self name:kNCEnterBackground object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [[ UIApplication sharedApplication ] setStatusBarStyle : UIStatusBarStyleLightContent ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _contentView.backgroundColor = [UIColor whiteColor];
    
    [self setNaviTitle:@"个人信息"];
    
    _titleArray = @[@[@"头像", @"我的手机号", @"我的地址"]];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _topOffset, _contentView.frame.size.width, _contentView.frame.size.height-_topOffset) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource =self;
    _tableView.backgroundColor =  UP_COL_RGB(0xefeff4);
    [_tableView setSeparatorColor:UP_COL_RGB(0xd4d4d4)];
    
    //去掉多余的分割线
    UIView*footer =[[UIView alloc] initWithFrame:CGRectZero];
    _tableView.tableFooterView = footer;
    [_contentView addSubview:_tableView];
    
    [UP_NC addObserver:self selector:@selector(dismissFaceImage:) name:kNCEnterBackground object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //状态栏字体保持白色
    [[ UIApplication sharedApplication ] setStatusBarStyle : UIStatusBarStyleLightContent ];
}

#pragma mark -
#pragma mark UITableViewDelegate & UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    return [_titleArray[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0&&indexPath.row == 0) {
        return kHeightHeaderImage;
    } else {
        return kHeightOtherCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeightCellHeader;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* indentifier = @"UPWSecurityRelativeViewController";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if(nil == cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:indentifier];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.font=[UIFont systemFontOfSize:16.0];
    cell.textLabel.textColor=UP_COL_RGB(0x333333);
    if(0 == indexPath.section){
        if(0 == indexPath.row)
        {
            _faceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-65-38, (kHeightHeaderImage-65)/2, 65, 65)];
            UIImage *image=[self readFaceImage];
            if (image) {
                [_faceImageView setImage:image];
            }else{
                [_faceImageView setImage:UP_GETIMG(@"head_image")];
            }
            [cell addSubview:_faceImageView];
            
            [_tapGR.view removeFromSuperview];
            _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editUserFace)];
            [_faceImageView setUserInteractionEnabled:YES];
            [_faceImageView addGestureRecognizer:_tapGR];
        } else if (1 == indexPath.row) {
            cell.detailTextLabel.textColor = UP_COL_RGB(0x666666);
            cell.detailTextLabel.font = [UIFont systemFontOfSize:kConstantFont14];
            cell.detailTextLabel.text = [UPWGlobalData sharedData].accountInfo.phoneNum;
        }
    }
    cell.textLabel.text = _titleArray[indexPath.section][indexPath.row];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
                //头像
                [self setUserFace];
                break;
            case 1:
                //不能设置我的手机号
                break;
            case 2:
                // 我的地址
            {
                UPWSelectDeliveryAddressViewController *selectDeliveryAddrVC = [[UPWSelectDeliveryAddressViewController alloc] initWithPageSource:EMineInfoPage];
                [self.navigationController pushViewController:selectDeliveryAddrVC animated:YES];
            }
                break;
            default:
                
                break;
        }
    }
}

#pragma mark 处理用户头像
- (void)editUserFace
{
    [self showFaceImage];
}

- (void)setUserFace
{
    UPWActionSheet *actionSheet = [[UPWActionSheet alloc]
                   initWithTitle:nil
                   delegate:self
                   cancelButtonTitle:UP_STR(@"kBtnCancel")
                   destructiveButtonTitle:nil
                   otherButtonTitles:UP_STR(@"String_TakePhoto"),UP_STR(@"String_FromAlbum") ,nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:_contentView];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            [self takePhotoWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }
        else
        {
            [self showFlashInfo:UP_STR(@"String_NoPhoto")];
        }
    }
    else if(buttonIndex == 1)
    {
        [self takePhotoWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)showFaceImage
{
    UIImage* image = [self readFaceImage];
    if (!image)
    {
        image = UP_GETIMG(@"head_image");
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    _blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _blackView.backgroundColor = [UIColor blackColor];
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake((width-image.size.width)/2, (height-image.size.height)/2, image.size.width, image.size.height)];
    imageView.image = image;
    [_blackView addSubview:imageView];
    _blackView.layer.opacity = 0.0f;
    [[UIApplication sharedApplication].keyWindow addSubview:_blackView];
    
    [UIView animateWithDuration:1 animations:^{
        _blackView.layer.opacity = 1.0f;
    } completion:^(BOOL finished) {
        _tapGR1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFaceImage:)];
        [_blackView addGestureRecognizer:_tapGR1];
    }];
}

- (void)dismissFaceImage:(UIGestureRecognizer*)gestureRecognizer
{
    [UIView animateWithDuration:1 animations:^{
        _tapGR1.view.layer.opacity = 0.0f;
    } completion:^(BOOL finished) {
        [_tapGR1.view removeFromSuperview];
        [_blackView removeFromSuperview];
    }];
}

- (void)takePhotoWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = sourceType;
    _imagePicker.delegate = self;
    _imagePicker.allowsEditing = YES;
    //ios7以上 进入照片库按取消按钮返回 navbar 变白  在这设了个背景图片 navbar上字体设置成白色
    //ios7以上 进入照片库按取消按钮返回 navbar 变白  在这设了个背景图片 navbar上字体设置成白色
    UIImage* image = [UP_GETIMG(@"bg_naviBar44") stretchableImageWithLeftCapWidth:0 topCapHeight:22];
    [_imagePicker.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    [_imagePicker.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor],UITextAttributeFont:[UIFont boldSystemFontOfSize:20]}];
    
    [self presentViewController:_imagePicker animated:YES completion:^{
        
    }];
}

- (NSString*)faceImageName
{
    NSString *path =  [UPWPathUtil userDirectoryPath:[UPWGlobalData sharedData].accountInfo.userId];
    NSString * imagePath = [path stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.jpg",[UPWGlobalData sharedData].accountInfo.userId]];
    
    return imagePath;
}

- (void)writeFaceImage:(UIImage*)image
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* imageName = [self faceImageName];
    if([fileManager fileExistsAtPath:imageName])
    {
        [fileManager removeItemAtPath:imageName error:nil];
    }
    
    UIImage* scaledImage = [UPWImageUtil scaleToSize:image size:CGSizeMake(_screenWidth,_screenWidth)];
    [UIImageJPEGRepresentation(scaledImage, 1.0f) writeToFile:imageName atomically:YES];
}

- (UIImage*)readFaceImage
{
    NSString* imageName = [self faceImageName];
    UIImage* image = [UIImage imageWithContentsOfFile:imageName];
    return image;
}

#pragma mark -
#pragma mark - pickerView
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self writeFaceImage:image];
    
    [_faceImageView setImage:[self readFaceImage]];
    
    //刷新个人中心数据
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshAccountInfo object:nil];
    
    [_imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/*
 个人信息页面不需要再次获取账户信息
#pragma mark -
#pragma mark - 获取账户信息
- (void)reloadData
{
    [self refreshAccountInfo];
}

#pragma mark -
#pragma mark 刷新AccountInfo
- (void)refreshAccountInfo
{
    __weak UPWMineInfoViewController* weakSelf = self;
    
    NSDictionary *params = @{@"userId":@"userId"};
    UPWMessage* message = [UPWMessage messageAccountInfoWithParams:params];
    [self addMessage:message];
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *responseJSON) {
        [weakSelf succeedAccountInfoWithResponseJSON:responseJSON];
    } fail:^(NSError *error) {
        [weakSelf failedAccountInfoWithError:error];
    }];
}

- (void)succeedAccountInfoWithResponseJSON:(NSDictionary*)responseJSON
{
    _accountInfoModel = [[UPWAccountInfoModel alloc] initWithDictionary:responseJSON error:nil];
    
    [UPWFileUtil writeContent:[_accountInfoModel toDictionary] path:[UPWPathUtil accountInfoPlistPath]];
    
    [UPWGlobalData sharedData].accountInfo = _accountInfoModel;
    
    [_tableView reloadData];
}

- (void)failedAccountInfoWithError:(NSError*)error
{
    _accountInfoModel = [[UPWAccountInfoModel alloc] initWithDictionary:[UPWFileUtil readContent:[UPWPathUtil accountInfoPlistPath]] error:nil];
    if (!_accountInfoModel) {
        [self showFlashInfo:[self stringWithError:error]];
    } else {
        [UPWFileUtil writeContent:[_accountInfoModel toDictionary] path:[UPWPathUtil accountInfoPlistPath]];
        
        [UPWGlobalData sharedData].accountInfo = _accountInfoModel;
    }
    
    //主要用于刷新头像
    [_tableView reloadData];
}
*/

@end
