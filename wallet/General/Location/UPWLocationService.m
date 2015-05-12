//
//  UPLocationService.m
//  UPWallet
//
//  Created by wxzhao on 14-6-16.
//  Copyright (c) 2014年 unionpay. All rights reserved.
//
//  jhyu在原有的框架上面改为了高德定位支持
//

#import "UPWLocationService.h"
#import "UPWMessage.h"
#import "UPWLocalStorage.h"
#import "UPWHttpMgr.h"
#import "UPWConst.h"
#import "UPXConstKey.h"
#import "UPWLocalStorage.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

/*
 从整合版本开始，我们的地图供应商已经转化成为了高德，使用高德地图SDK进行定位。
*/

static MAMapView * gMapView = nil;

@interface UPWLocationService () <MAMapViewDelegate, AMapSearchDelegate, CLLocationManagerDelegate> {
    MAMapView * _mapView;
    AMapSearchAPI * _mapSearchApi;
    BOOL _isLocateCityMode;
    
    CLLocationManager * _locMgr;
    BOOL _authApprovedAfterQuery;
}

@property(nonatomic, copy) lbs_success_block_t successBlock;
@property(nonatomic, copy) lbs_fail_block_t failBlock;

@property(nonatomic, readonly) BOOL isLocateCityMode;

@end

@implementation UPWLocationService

- (instancetype)init
{
    self = [super init];
    if (self) {
        if(!gMapView) {
            gMapView = [[MAMapView alloc] initWithFrame:CGRectZero];
        }
        
        _mapView = gMapView;
        
        [UP_NC addObserver:self selector:@selector(appResignActive) name:kNCResignActive object:nil];
        [UP_NC addObserver:self selector:@selector(appEnterForeground) name:kNCEnterForeground object:nil];
        
        _locMgr = [[CLLocationManager alloc] init];
        _locMgr.delegate = self;
    }
    
    return self;
}

- (void)dealloc
{
    [UP_NC removeObserver:self];
    _locMgr.delegate = nil;
    /*
     注释掉_mapView.delegate = nil; 因为gMapView是单例，如果dealloc有点慢的话，它会置掉新的实例的_mapView.delegate, unexpected !
     */
    //_mapView.delegate = nil;
}

#pragma mark - Public Methods

/*
 * 判断定位服务是否打开
 */
+ (BOOL)isLocationServiceEnable
{
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
            case kCLAuthorizationStatusRestricted:
            case kCLAuthorizationStatusDenied:
            {
                return NO;
            }
                break;
            default:
            {
                return YES;
            }
                break;
        }
    }
    return NO;
}

- (BOOL)updatingLocationWithSuccess:(lbs_success_block_t)successBlock fail:(lbs_fail_block_t)failBlock
{
    BOOL shouldLocateUser;
    if(_authApprovedAfterQuery) {
        shouldLocateUser = YES;
    }
    else {
        if(self.successBlock) {
            // 前面的定位服务正在处理, 占线！！！ 拒绝后面的请求。
            shouldLocateUser = NO;
        }
        else {
            shouldLocateUser = YES;
        }
    }
    
    _authApprovedAfterQuery = NO;
    
    if(shouldLocateUser) {
        self.successBlock = successBlock;
        self.failBlock = failBlock;
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
        
        self.retCityNm = YES; // default value
        _isLocateCityMode = NO;
        
        return YES;
    }
    else {
        // 前面的定位服务正在处理, 占线！！！ 拒绝后面的请求。
        if(failBlock) {
            failBlock([NSError errorWithDomain:@"UPClient" code:kLocationServiceBusyErrorCode userInfo:nil]);
        }
        else if(successBlock) {
            successBlock(nil, nil, nil);
        }
        
        return NO;
    }
}

- (BOOL)updatingCityWithSuccess:(lbs_success_block_t)successBlock fail:(lbs_fail_block_t)failBlock
{
    BOOL ret = [self updatingLocationWithSuccess:successBlock fail:failBlock];
    if(ret) {
        _isLocateCityMode = YES;
    }
    
    return ret;
}

- (void)stopUpdatingLocation
{
    self.successBlock = nil;
    self.failBlock = nil;
    _mapView.delegate = nil;
    _mapView.showsUserLocation = NO;
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if(!updatingLocation) {
        return;
    }
    
    CLLocationCoordinate2D coord = userLocation.location.coordinate;
    
    UPDINFO(@"didUpdateUserLocation: (%f, %f)", coord.latitude, coord.longitude);
    
    _mapView.showsUserLocation = NO;
    
    if(!self.isLocateCityMode && !self.retCityNm) {
        // 不需要去获取城市名
        if (self.successBlock) {
            self.successBlock([@(coord.longitude) stringValue], [@(coord.latitude) stringValue], nil);
        }
        
        [self stopUpdatingLocation];
    }
    else {
        if(!_mapSearchApi) {
            _mapSearchApi = [[AMapSearchAPI alloc] initWithSearchKey:MAP_API_KEY Delegate:self];
        }
        AMapReGeocodeSearchRequest * request = [[AMapReGeocodeSearchRequest alloc] init];
        request.searchType = AMapSearchType_ReGeocode;
        request.location = [AMapGeoPoint locationWithLatitude:coord.latitude longitude:coord.longitude];
        [_mapSearchApi AMapReGoecodeSearch:request];
    }
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    // 失败的CASE统统都走到如下如下失败处理函数。
    [self failedHandlerWithError:error];
}

#pragma mark - AMapSearchDelegate

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    AMapAddressComponent * addressComponent = response.regeocode.addressComponent;
    
    NSString * cityName = addressComponent.city;
    if(UP_IS_NIL(cityName)) {
        // 直辖市。
        cityName = addressComponent.province;
    }
    
    if (self.isLocateCityMode) {
        [self fetchCityInfo:cityName];
    }
    else {
        AMapGeoPoint * geoPoint = addressComponent.streetNumber.location;
        if(geoPoint) {
            [self regeocodeSuccessHandlerWithCityCd:nil cityName:cityName longitude:[@(geoPoint.longitude) stringValue] latitude:[@(geoPoint.latitude) stringValue]];
        }
    }
}

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    [self failedHandlerWithError:error];
}

#pragma mark - Helpers

- (void)regeocodeSuccessHandlerWithCityCd:(NSString *)cityCd cityName:(NSString *)cityName longitude:(NSString *)longitude latitude:(NSString *)latitude
{
    //定位成功后需要把经纬度存储，用于优惠券列表
    [[NSUserDefaults standardUserDefaults] setObject:longitude forKey:kUDKeyLongitude];
    [[NSUserDefaults standardUserDefaults] setObject:latitude forKey:kUDKeyLatitude];
    
    UPWCityModel* cityModel = [[UPWCityModel alloc] init];
    
    if (!UP_IS_NIL(cityName)) {
        cityModel.cityNm = cityName;
        if (!UP_IS_NIL(cityCd)) {
            cityModel.cityCd = cityCd;
        }

        if (self.successBlock) {
            self.successBlock(longitude,latitude,[cityModel toDictionary]);
        }
    }
    else {

        if (self.failBlock) {
            
            NSError* reqError = [NSError errorWithDomain:@"ErrorFromNetwork"
                code:kErrorLocationNoCityNameCode
                userInfo:@{NSLocalizedDescriptionKey:kErrorLocationNoCityName,
                           NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%ld",(long)kErrorLocationNoCityNameCode]}];
            self.failBlock(reqError);
        }
    }
}

- (void)failedHandlerWithError:(NSError *)error
{
    if (self.failBlock) {
        self.failBlock(error);
    }
    
    [self stopUpdatingLocation];
}

- (void)fetchCityInfo:(NSString*)cityNm
{
    __weak typeof(self) weakSelf = self;
    UPWMessage* message = [UPWMessage regionLocatePosition:cityNm];
    [[UPWHttpMgr instance] sendMessage:message success:^(NSDictionary *response) {
        [weakSelf fetchCityInfoSuccessHandlerWithResponse:response];
    } fail:^(NSError *error) {
        [weakSelf failedHandlerWithError:error];
    }];
}

- (void)fetchCityInfoSuccessHandlerWithResponse:(NSDictionary *)response
{
    NSDictionary* dict = response[kJSONParamsKey];
    NSError* err = nil;
    UPWCityModel* cityModel = [[UPWCityModel alloc] initWithDictionary:dict error:&err];
    if (err || !cityModel) {
        if (self.failBlock) {
            self.failBlock(err);
        }
    }
    else{
        if (self.successBlock) {
            self.successBlock(nil, nil, [cityModel toDictionary]);
        }
    }
    
    [self stopUpdatingLocation];
}

#pragma mark - Notifications

- (void)appResignActive
{
    _mapView.delegate = nil;
}

- (void)appEnterForeground
{
    _mapView.delegate = self;
    
    if(self.successBlock) {
        // 我们执行完service以后都会设置self.successBlock＝nil, 还没有执行完的话进入前台以后重新从头开始执行。
        if(_isLocateCityMode) {
            [self updatingCityWithSuccess:self.successBlock fail:self.failBlock];
        }
        else {
            [self updatingLocationWithSuccess:self.successBlock fail:self.failBlock];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status >= kCLAuthorizationStatusAuthorized) {
        // 设置标志。
        _authApprovedAfterQuery = YES;
        
        // 继续开始的定位以及后续流程。 
        [self appEnterForeground];
    }
}

@end

