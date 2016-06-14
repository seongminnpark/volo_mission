//
//  VLOLocationCoordinate.m
//  VLOTimelineSummary
//
//  Created by M on 2016. 6. 14..
//  Copyright © 2016년 M. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLOLocationCoordinate.h"


@implementation VLOLocationCoordinate

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude
{
    //self = [super init];
    if (self) {
        self.latitude = @(latitude);
        self.longitude = @(longitude);
    }
    return self;
}

- (CLLocationCoordinate2D)locationCoordinate2D
{
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

@end