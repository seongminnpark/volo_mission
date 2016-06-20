//
//  VLOPlace.h
//  Volo
//
//  Created by 1001246 on 2015. 1. 12..
//  Copyright (c) 2015년 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>


@class GMSPlace;
@class VLOCountry;
@class VLOLocationCoordinate;

@interface VLOPlace : NSObject

//@property (nonatomic, strong) NSString *api;

@property (nonatomic, strong) NSString *name;
//@property (nonatomic, strong) VLOCountry *country;
@property (nonatomic, strong) VLOLocationCoordinate *coordinates;
/*
@property (nonatomic, strong) NSString *postalCode;
@property (nonatomic, strong) NSString *administrativeArea;
@property (nonatomic, strong) NSString *subAdministrativeArea;
@property (nonatomic, strong) NSString *locality;
@property (nonatomic, strong) NSString *subLocality;
@property (nonatomic, strong) NSString *thoroughfare;
@property (nonatomic, strong) NSString *subThoroughfare;*/

/**
 *  서버로 부터 받은 보여주기용 주소입니다.
 */
//@property (nonatomic, strong) NSString *fetchedAddress;

/*- (instancetype)initWithCLPlacemark:(CLPlacemark *)placemark api:(NSString *)api;
- (instancetype)initWithCLPlacemark:(CLPlacemark *)placemark customName:(NSString *)name api:(NSString *)api;

- (instancetype)initWithResponse:(NSDictionary *)response api:(NSString *)api;
- (instancetype)initWithResponse:(NSDictionary *)response customName:(NSString *)name api:(NSString *)api;

- (void)setReverseGeocodingResult:(CLPlacemark *)placemark;

- (NSDictionary *)dictionaryValue; */

@end