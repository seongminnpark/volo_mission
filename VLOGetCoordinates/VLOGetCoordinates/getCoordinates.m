//
//  getCoordinates.m
//  getCoordinates(ios)
//
//  Created by M on 2016. 6. 8..
//  Copyright © 2016년 M. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "getCoordinates.h"
#import "Location.h"
#import "Marker.h"

@implementation GetCoordinates
@synthesize x_y_coordinate;
@synthesize user_coordinates;
@synthesize longitude;
@synthesize latitude;
@synthesize x_y_increment;


-(id)_init
{
    self=[super init];
    
    user_coordinates=[NSMutableArray arrayWithCapacity:100]; //최종 좌표(x,y)를 담을 배열
    [user_coordinates addObject:@"0"]; //get_coordinates에서 insert하기 위해 임의의 값 설정
    
    
    return self;
    
}

// 두 지점 사이의 거리를 계산하는 함수

- (NSInteger)get_distance:(Location *)location1 :(Location *)location2
{
    
    
    distance=round(sqrt(([location1.latitude doubleValue]-[location2.latitude doubleValue])*([location1.latitude doubleValue]-[location2.latitude doubleValue])+([location1.longitude doubleValue]-[location2.longitude doubleValue])*([location1.longitude doubleValue]-[location2.longitude doubleValue])));
    
    return (NSInteger)distance;
}



// 화면상의 좌표 구하는 함수

- (NSMutableArray *) get_coordinates: (NSArray *)lo
{
    [self _init];
    
    NSInteger n=[lo count];
    NSInteger n2;
    
    
    
    for(i=0;i<n;i++)
    {
        if(i==n-1)
        {
            break;
        }
        
        tmp1=lo[i];
        tmp2=lo[i+1];
        
        x_diff=[self get_distance:lo[i] :lo[i+1]]; //x좌표 증가량 구함
        y_diff=round(([tmp1.latitude doubleValue]-[tmp2.latitude doubleValue])*10); //y좌표 증가량 구함
        
        x_y_increment=[[Marker alloc]init];
        
        x_y_increment.x=30+x_diff;
        x_y_increment.y=5+y_diff;
        //생성된 x,y 증가량을 marker 클래스에 대입
        
        [user_coordinates insertObject:x_y_increment atIndex:i];
        
        
        tmp_x=[user_coordinates objectAtIndex:i];
        sum_distance+=tmp_x.x;
        //표시할 전체 경로의 길이 구함
        
        [x_y_increment release];
        
    }
    if(sum_distance>300)
    {
        extra_distance=(sum_distance-300)/2;
    }
    else
    {
        extra_distance=(300-sum_distance)/2;
    }
    //양쪽 여백 계산
    
    tmp=[[Marker alloc]init];
    tmp.x=extra_distance;
    tmp.y=50;
    [user_coordinates insertObject:tmp atIndex:0];
    //첫 위치의 좌표 설정 후 user_coordinates[0]에 대입
    
    [tmp release];
    
    //이전 위치의 x,y값에 증가량 더함
    n2=[user_coordinates count];
    
    for(i=1;i<n2-1;i++)
    {
        add_tmp=[[Marker alloc]init];
        
        marker_tmp1=[user_coordinates objectAtIndex:i-1];
        marker_tmp2=[user_coordinates objectAtIndex:i];
        
        if(marker_tmp2.y>20)
        {
            marker_tmp2.y=20;
        }
        //y좌표의 경우 +-20이 가장 적당하기 때문에 증가값이 20이상인 경우 20으로 고정
        
        add_tmp.x=marker_tmp1.x+marker_tmp2.x;
        add_tmp.y=marker_tmp1.y+marker_tmp2.y;
        
   /*     if(add_tmp.x>300)
        {
            add_tmp.x=add_tmp.x-300;
        } */
        // x좌표가 300이상일 경우 다음줄로 넘어가게 하기 위한 if문 (고민필요)
        
        [user_coordinates replaceObjectAtIndex:i withObject:add_tmp];
        
        [add_tmp release];
        marker_tmp1=nil;
        marker_tmp2=nil;
        
        
    }
    
    return user_coordinates;
    
    
}





@end
