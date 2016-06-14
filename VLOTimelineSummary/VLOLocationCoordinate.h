//
//  VLOLocationCoordinate.h
//  VLOTimelineSummary
//
//  Created by M on 2016. 6. 14..
//  Copyright © 2016년 M. All rights reserved.
//

#ifndef VLOLocationCoordinate_h
#define VLOLocationCoordinate_h

#import <MapKit/MapKit.h>

@interface VLOLocationCoordinate : NSObject

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude;
- (CLLocationCoordinate2D)locationCoordinate2D;


#endif /* VLOLocationCoordinate_h */
