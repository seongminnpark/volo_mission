//
//  VLOLocationCoordinate.m
//  Volo
//
//  Created by 1001246 on 2015. 1. 26..
//  Copyright (c) 2015년 SK Planet. All rights reserved.
//

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