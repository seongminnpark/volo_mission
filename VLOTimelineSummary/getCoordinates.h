//
//  getCoordinates.h
//  getCoordinates(ios)
//
//  Created by M on 2016. 6. 8..
//  Copyright © 2016년 M. All rights reserved.
//

#define getCoordinates_h
#import <CoreGraphics/CGBase.h>
#import "VLODevicemodel.h"

// 받아온 위치 정보를 기반으로 화면상의 좌표를 계산하는 클래스

//@class Location;
@class Marker;
@class VLOLocationCoordinate;
@class VLOPlace;

@interface GetCoordinates : NSObject
{
    NSInteger i;
    NSInteger j;
    
    
    CGFloat x_diff;
    CGFloat y_diff;
    
    NSInteger distance;
    
    VLOPlace * input_place1;
    VLOPlace * input_place2;
    VLOLocationCoordinate * input_location1;
    VLOLocationCoordinate * input_location2;
    Marker * final_location;
    
    
    
    
}

@property (strong,nonatomic) NSMutableArray * user_coordinates;
@property (nonatomic) NSInteger MAX;


- (id) init:(NSArray *)pl;
- (double)get_distance:(VLOLocationCoordinate *)location1 :(VLOLocationCoordinate *)location2;
- (NSMutableArray *)get_coordinates: (NSArray *)lo;
- (void)check_device_model;

@end
