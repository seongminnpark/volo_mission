//
//  getCoordinates.h
//  getCoordinates(ios)
//
//  Created by M on 2016. 6. 8..
//  Copyright © 2016년 M. All rights reserved.
//

#ifndef getCoordinates_h
#define getCoordinates_h
#import <CoreGraphics/CGBase.h>


// 받아온 위치 정보를 기반으로 화면상의 좌표를 계산하는 클래스

//@class Location;
@class Marker;
@class VLOLocationCoordinate;

@interface GetCoordinates : NSObject
{
    NSInteger i;
    
    
    CGFloat x_diff;
    CGFloat y_diff;
    
    NSInteger sum_distance;
    NSInteger extra_distance;
    NSInteger distance;
    
    
    VLOLocationCoordinate * tmp1;
    VLOLocationCoordinate * tmp2;
    
    Marker * tmp_x;
    Marker * tmp;
    Marker * marker_tmp1;
    Marker * marker_tmp2;
    Marker * add_tmp;
    
    //임시변수
    VLOLocationCoordinate * lo1;
    VLOLocationCoordinate * lo2;
    VLOLocationCoordinate * lo3;
    VLOLocationCoordinate * lo4;
    VLOLocationCoordinate * lo5;
    VLOLocationCoordinate * lo6;
    VLOLocationCoordinate * lo7;
    
    
}

@property (strong,nonatomic) NSNumber * x_y_coordinate;
@property (strong,nonatomic) NSNumber * longitude;
@property (strong,nonatomic) NSNumber * latitude;
@property (strong,nonatomic) NSMutableArray * user_coordinates;
@property (strong,nonatomic) Marker * x_y_increment;
@property (strong,nonatomic) NSArray * user_cor_list;
@property (strong,nonatomic) NSArray * _final_coordinates;
@property (nonatomic) NSInteger MAX;


- (id)_init;
- (double)get_distance:(VLOLocationCoordinate *)location1 :(VLOLocationCoordinate *)location2;
- (NSMutableArray *)get_coordinates: (NSArray *)lo;
- (NSArray *) set_location: (NSArray *)location_list;
- (void) reset_x_y_increment: (NSInteger)n;


@end

#endif /* getCoordinates_h */