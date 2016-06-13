//
//  Location.h
//  getCoordinates(ios)
//
//  Created by M on 2016. 6. 8..
//  Copyright © 2016년 M. All rights reserved.
//

#ifndef Location_h
#define Location_h
//#import "GetCoordinates.h"
@class GetCoordinates;

// 위치 및 좌표 정보를 저장할 클래스


@interface Location : NSObject
{
    Location * lo1;
    Location * lo2;
    Location * lo3;
}


@property (strong,nonatomic) NSNumber * longitude;
@property (strong,nonatomic) NSNumber * latitude;
@property (strong,nonatomic) GetCoordinates * get_coordinates;
@property (strong,nonatomic) NSArray * user_cor_list;
@property (strong,nonatomic) NSArray * _final_coordinates;


- (id) _init_location;
- (NSArray *) set_coordinates;

@end


#endif /* Location_h */
