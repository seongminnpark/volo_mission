//
//  Location.m
//  getCoordinates(ios)
//
//  Created by M on 2016. 6. 8..
//  Copyright © 2016년 M. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "GetCoordinates.h"

@implementation Location

@synthesize longitude;
@synthesize latitude;
@synthesize get_coordinates;
@synthesize user_cor_list;
@synthesize _final_coordinates;

- (id) _init_location
{
    self=[super init];
    
    return self;
}

- (NSArray *) set_coordinates
{
    lo1=[[Location alloc]init];
    lo2=[[Location alloc]init];
    lo3=[[Location alloc]init];
    
    self->get_coordinates=[[GetCoordinates alloc]init];
    _final_coordinates=[NSArray array];
    
    
    lo1.latitude=[NSNumber numberWithDouble:37.460195];
    lo1.longitude=[NSNumber numberWithDouble:126.438507];
    lo2.latitude=[NSNumber numberWithDouble:33.9415933];
    lo2.longitude=[NSNumber numberWithDouble:-118.4107187];
    lo3.latitude=[NSNumber numberWithDouble:37.8199328];
    lo3.longitude=[NSNumber numberWithDouble:-122.4804438];
    
    user_cor_list=[[NSArray alloc] initWithObjects:lo1,lo2,lo3, nil];
    
    
    
    
    
    _final_coordinates=[get_coordinates get_coordinates:user_cor_list];
    
    return _final_coordinates;
    
}
// lo1,lo2,lo3는 테스트하기 위해서 임의로 만든 변수
// 추후엔 받아온 위도,경도값을 location클래스로 관리

@end