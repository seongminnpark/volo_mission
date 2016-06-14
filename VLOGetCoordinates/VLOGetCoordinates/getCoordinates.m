//
//  getCoordinates.m
//  getCoordinates(ios)
//
//  Created by M on 2016. 6. 8..
//  Copyright © 2016년 M. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "getCoordinates.h"
#import "Marker.h"
#import "VLOLocationCoordinate.h"
#import <CoreGraphics/CGBase.h>

@implementation GetCoordinates

@synthesize x_y_coordinate;
@synthesize user_coordinates;
@synthesize longitude;
@synthesize latitude;
@synthesize x_y_increment;
@synthesize user_cor_list;
@synthesize _final_coordinates;



-(id)_init
{
    self=[super init];
    
    user_coordinates=[NSMutableArray arrayWithCapacity:100]; //최종 좌표(x,y)를 담을 배열
    [user_coordinates addObject:@"0"]; //get_coordinates에서 insert하기 위해 임의의 값 설정
    
    
    return self;
    
}

// 두 지점 사이의 거리를 계산하는 함수

- (double)get_distance:(VLOLocationCoordinate *)location1 :(VLOLocationCoordinate *)location2
{
    distance=sqrt(([location1.latitude doubleValue]-[location2.latitude doubleValue])*([location1.latitude doubleValue]-[location2.latitude doubleValue])+([location1.longitude doubleValue]-[location2.longitude doubleValue])*([location1.longitude doubleValue]-[location2.longitude doubleValue]));
    
    
    
    return distance;
}

//총 경로의 길이가 한 화면을 넘어가는 경우 reset

- (void) reset_x_y_increment: (NSInteger)n
{
    NSInteger j;
    NSInteger max_location=0;
    double max;
    Marker * max_init;
    NSInteger cnt=[user_coordinates count];
    Marker * tmp_increment;
    Marker * final_increment=[[Marker alloc]init];
    
    
    max_init=[user_coordinates objectAtIndex:0];
    max=max_init.x;
    
    
    for(j=1;j<cnt-1;j++)
    {
        tmp_increment=[user_coordinates objectAtIndex:j];
        
        if(tmp_increment.x>max)
        {
            max=tmp_increment.x;
            max_location=j;
        }
        
    }
    
    final_increment.x=max-n;
    [user_coordinates replaceObjectAtIndex:max_location withObject:final_increment];
    
    [final_increment release];
    
    
    
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
        
        x_diff=[self get_distance:lo[i] :lo[i+1]]; //x좌표 증가량
        y_diff=([tmp1.latitude doubleValue]-[tmp2.latitude doubleValue])*10; //y좌표 증가량
        
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
    
    

    tmp=[[Marker alloc]init];

    if(sum_distance>270)
    {
        tmp.x=20;
        tmp.y=50;
        [user_coordinates insertObject:tmp atIndex:0];
        
        [self reset_x_y_increment:(sum_distance-270)];

    }
    else
    {
        
        extra_distance=(270-sum_distance)/2;
        tmp.x=extra_distance;
        tmp.y=50;
        [user_coordinates insertObject:tmp atIndex:0];
        
        
    }
    //양쪽 여백 계산
    
    [tmp release];
    
    
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
        else if(marker_tmp2.y<-20)
        {
            marker_tmp2.y=-20;
        }
        //y좌표의 경우 +-20이 가장 적당하기 때문에 증가값이 20이상인 경우 20으로 고정
        
        add_tmp.x=marker_tmp1.x+marker_tmp2.x;
        add_tmp.y=marker_tmp1.y+marker_tmp2.y;
        
        [user_coordinates replaceObjectAtIndex:i withObject:add_tmp];
        
        [add_tmp release];
        marker_tmp1=nil;
        marker_tmp2=nil;
    }

    
    return user_coordinates;
    
    
}



- (NSArray *) set_location
{
    lo1=[[VLOLocationCoordinate alloc]init];
    lo2=[[VLOLocationCoordinate alloc]init];
    lo3=[[VLOLocationCoordinate alloc]init];
    lo4=[[VLOLocationCoordinate alloc]init];
    lo5=[[VLOLocationCoordinate alloc]init];
    lo6=[[VLOLocationCoordinate alloc]init];
    lo7=[[VLOLocationCoordinate alloc]init];
    
    _final_coordinates=[NSArray array];

    
    
    lo1.latitude=[NSNumber numberWithDouble:37.460195];
    lo1.longitude=[NSNumber numberWithDouble:126.438507];
    lo2.latitude=[NSNumber numberWithDouble:1.3644256];
    lo2.longitude=[NSNumber numberWithDouble:103.9893421];
    lo3.latitude=[NSNumber numberWithDouble:1.2821166];
    lo3.longitude=[NSNumber numberWithDouble:103.8432716];
    lo4.latitude=[NSNumber numberWithDouble:1.2908879];
    lo4.longitude=[NSNumber numberWithDouble:103.8422545];
    lo5.latitude=[NSNumber numberWithDouble:1.2973126];
    lo5.longitude=[NSNumber numberWithDouble:103.8488728];
    lo6.latitude=[NSNumber numberWithDouble:1.3010655];
    lo6.longitude=[NSNumber numberWithDouble:103.8538013];
    lo7.latitude=[NSNumber numberWithDouble:1.2843235];
    lo7.longitude=[NSNumber numberWithDouble:103.8421236];
    
    
    user_cor_list=[[NSArray alloc] initWithObjects:lo1,lo2,lo3,lo4,lo5,lo6,lo7,nil];
    
    _final_coordinates=[self get_coordinates:user_cor_list];
    return _final_coordinates;
    
}




@end