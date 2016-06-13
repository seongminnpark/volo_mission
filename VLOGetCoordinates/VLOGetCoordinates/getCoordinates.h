//
//  getCoordinates.h
//  getCoordinates(ios)
//
//  Created by M on 2016. 6. 8..
//  Copyright © 2016년 M. All rights reserved.
//

#ifndef getCoordinates_h
#define getCoordinates_h

// 받아온 위치 정보를 기반으로 화면상의 좌표를 계산하는 클래스

@class Location;
@class Marker;

@interface GetCoordinates : NSObject
{
    NSInteger i;
    NSInteger x_diff;
    NSInteger y_diff;
    NSInteger sum_distance;
    NSInteger extra_distance;
    NSInteger distance;
    Location * tmp1;
    Location * tmp2;
    Marker * tmp_x;
    Marker * tmp;
    Marker * marker_tmp1;
    Marker * marker_tmp2;
    Marker * add_tmp;
   
    
}

@property (strong,nonatomic) NSNumber * x_y_coordinate;
@property (strong,nonatomic) NSNumber * longitude;
@property (strong,nonatomic) NSNumber * latitude;
@property (strong,nonatomic) NSMutableArray * user_coordinates;
@property (strong,nonatomic) Marker * x_y_increment;
- (id)_init;
- (NSInteger)get_distance:(Location *)location1 :(Location *)location2;
- (NSMutableArray *)get_coordinates: (NSArray *)lo;


@end

#endif /* getCoordinates_h */

