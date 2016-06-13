//
//  VLOLocationCoordinate.h
//  Volo
//
//  Created by 1001246 on 2015. 1. 26..
//  Copyright (c) 2015년 SK Planet. All rights reserved.
//

//#import <Mantle/Mantle.h>
#import <MapKit/MapKit.h>

@interface VLOLocationCoordinate : NSObject

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude;
- (CLLocationCoordinate2D)locationCoordinate2D;

@end
