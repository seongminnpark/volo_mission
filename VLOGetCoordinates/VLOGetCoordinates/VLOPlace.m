//
//  VLOPlace.m
//  Volo
//
//  Created by 1001246 on 2015. 1. 12..
//  Copyright (c) 2015년 SK Planet. All rights reserved.
//


// Library
#import <GoogleMaps/GoogleMaps.h>
@import Foundation;


@implementation VLOPlace

- (instancetype)initWithCLPlacemark:(CLPlacemark *)placemark api:(NSString *)api
{
    return [self initWithCLPlacemark:placemark
                          customName:placemark.name api:api];
}

- (instancetype)initWithCLPlacemark:(CLPlacemark *)placemark customName:(NSString *)name api:(NSString *)api
{
    self = [super init];
    
    if (self) {
        self.api = api;
        self.name = name;
        self.postalCode = placemark.postalCode;
        self.coordinates = [[VLOLocationCoordinate alloc] initWithLatitude:placemark.location.coordinate.latitude
                                                                 longitude:placemark.location.coordinate.longitude];
        
        self.country = [[VLOCountry alloc] initWithCode:placemark.ISOcountryCode
                                                country:placemark.country];
        self.administrativeArea = placemark.administrativeArea;
        self.subAdministrativeArea = placemark.subAdministrativeArea;
        self.locality = placemark.locality;
        self.subLocality = placemark.subLocality;
        self.thoroughfare = placemark.thoroughfare;
        self.subThoroughfare = placemark.subThoroughfare;
    }
    return self;
}

- (instancetype)initWithResponse:(NSDictionary *)response api:(NSString *)api
{
    return [self initWithResponse:response customName:response[@"name"] api:api];
}

- (instancetype)initWithResponse:(NSDictionary *)response customName:(NSString *)name api:(NSString *)api
{
    self = [super init];
    if (self) {
        CGFloat latitude = [response[@"geometry"][@"location"][@"lat"] floatValue];
        CGFloat longitude = [response[@"geometry"][@"location"][@"lng"] floatValue];
        
        self.api = api;
        self.name = name;
        self.fetchedAddress = response[@"vicinity"];
        
        self.coordinates = [[VLOLocationCoordinate alloc] initWithLatitude:latitude longitude:longitude];
    }
    return self;
}

- (void)setReverseGeocodingResult:(CLPlacemark *)placemark
{
    self.postalCode = placemark.postalCode;
    self.coordinates = [[VLOLocationCoordinate alloc] initWithLatitude:placemark.location.coordinate.latitude
                                                             longitude:placemark.location.coordinate.longitude];
    
    self.country = [[VLOCountry alloc] initWithCode:placemark.ISOcountryCode
                                            country:placemark.country];
    self.administrativeArea = placemark.administrativeArea;
    self.subAdministrativeArea = placemark.subAdministrativeArea;
    self.locality = placemark.locality;
    self.subLocality = placemark.subLocality;
    self.thoroughfare = placemark.thoroughfare;
    self.subThoroughfare = placemark.subThoroughfare;
}

- (NSDictionary *)dictionaryValue
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super dictionaryValue]];
    if (dictionary) {
        if (self.country) {
            [dictionary setObject:[self.country dictionaryValue] forKey:@"country"];
        }
        if (self.coordinates) {
            [dictionary setObject:[self.coordinates dictionaryValue] forKey:@"coordinates"];
        }
        return dictionary;
    }
    return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error
{
    if ([dictionaryValue isEqual:[NSNull null]]) {
        return nil;
    }
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryValue];
    
    self = [super initWithDictionary:mutableDictionary error:error];
    
    if (self) {
        id countryDictionary = [dictionaryValue objectForKey:@"country"];
        id coordinatesDictionary = [dictionaryValue objectForKey:@"coordinates"];
        
        if (countryDictionary && [countryDictionary isKindOfClass:[NSDictionary class]]) {
            _country = [[VLOCountry alloc] initWithDictionary:[dictionaryValue objectForKey:@"country"] error:error];
        }
        if (coordinatesDictionary && [coordinatesDictionary isKindOfClass:[NSDictionary class]]) {
            _coordinates = [[VLOLocationCoordinate alloc] initWithDictionary:[dictionaryValue objectForKey:@"coordinates"] error:error];
        }
    }
    return self;
}

@end
