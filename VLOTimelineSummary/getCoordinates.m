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
#import "VLODevicemodel.h"

@implementation GetCoordinates

@synthesize user_coordinates;


-(id) init
{
    self=[super init];
    final_location=[[Marker alloc]init];
    user_coordinates=[NSMutableArray arrayWithCapacity:100]; //최종 좌표(x,y)를 담을 배열
    
    // 첫 위치의 좌표는 무조건 (10,100)으로 지정
    final_location.x=10;
    final_location.y=100;
    
    [user_coordinates addObject:final_location];
    
    //final_location은 get_coordinats함수에서 다시 사용할건데, release해주지 않으면 이전값을 그대로 적용하기때문에 release
    return self;
    
}

// 두 지점 사이의 거리를 계산하는 함수

- (double)get_distance:(VLOLocationCoordinate *)location1 :(VLOLocationCoordinate *)location2
{
    distance=sqrt(([location1.latitude doubleValue]-[location2.latitude doubleValue])*([location1.latitude doubleValue]-[location2.latitude doubleValue])+([location1.longitude doubleValue]-[location2.longitude doubleValue])*([location1.longitude doubleValue]-[location2.longitude doubleValue]));
    
    
    
    return distance;
}


// 핸드폰 기종을 확인하는 함수
- (void) check_device_model
{
    VLODevicemodel * vd=[[VLODevicemodel alloc]init];
    NSString * device_model=[vd Get_Device_model];
    
    
    if([device_model isEqualToString:@"iPhone 4"]||[device_model isEqualToString:@"iPhone 4S"]||[device_model isEqualToString:@"iPhone 5"]||[device_model isEqualToString:@"iPhone 5c"]||[device_model isEqualToString:@"iPhone 5s"])
    {
        _MAX=270;
    }
    else if([device_model isEqualToString:@"iPhone 6"]||[device_model isEqualToString:@"iPhone 6S"])
    {
        _MAX=330;
    }
    else if([device_model isEqualToString:@"iPhone 6 Plus"]||[device_model isEqualToString:@"iPhone 6S Plus"])
    {
        _MAX=360;
    }
    else if([device_model isEqualToString:@"iPad"]||[device_model isEqualToString:@"iPad 2"]||[device_model isEqualToString:@"iPad Mini"])
    {
        _MAX=720;
    }
}


// 화면상의 좌표 구하는 함수

- (NSMutableArray *) get_coordinates: (NSArray *)lo
{
    
    NSInteger n=[lo count];
    double start_end_distance;
    
    [self check_device_model];
    
    
    //첫 위치와 마지막 위치 사이의 거리 구함
    VLOLocationCoordinate * start_location=lo[0];
    VLOLocationCoordinate * end_location=lo[n-1];
    start_end_distance=[self get_distance:start_location :end_location];
    
    
    for(i=0;i<n-1;i++)
    {
        input_location1=lo[i];
        input_location2=lo[i+1];
        
        // x좌표의 최대값인 MAX에 맞추기 위하여 전체 이동길이가 MAX보다 큰 경우, 작은 경우로 나눠서 계산
        if(_MAX>start_end_distance)
        {
            final_location=[[Marker alloc]init];
            
            x_diff=[self get_distance:input_location1 :input_location2];
            x_diff=x_diff+((_MAX-start_end_distance)/n);
            y_diff=([input_location1.latitude doubleValue]-[input_location2.latitude doubleValue])*10; //y좌표 증가량
            
            
            // y좌푱의 증가/감소값은 20이 적당하므로 20보다 크거나 -20보다 작은경우 임의로 y 변화값 지정
            if(y_diff>20)
            {
                y_diff=20;
            }
            else if(y_diff<-20)
            {
                y_diff=-20;
            }
            
            // 여기까지는 x,y좌표의 변화값에 대해 구함
            
            
            // 여기서부터 이전 좌표값을 가져와 변화값에 따라 증가 혹은 감소
            NSInteger n2=[user_coordinates count];
            Marker * tmp=[user_coordinates objectAtIndex:n2-1];
            
            final_location.x=tmp.x+x_diff;
            final_location.y=tmp.y+y_diff;
            
            [user_coordinates addObject:final_location];
            
        }
        else if(_MAX<start_end_distance)
        {
            final_location=[[Marker alloc]init];
            
            x_diff=[self get_distance:input_location1 :input_location2];
            x_diff=x_diff-((start_end_distance-_MAX)/n);
            y_diff=([input_location1.latitude doubleValue]-[input_location2.latitude doubleValue])*10;
            
            if(y_diff>0)
            {
                final_location.y=5+y_diff;
            }
            else
            {
                final_location.y=-5+y_diff;
            }
            
            NSInteger n2=[user_coordinates count];
            Marker * tmp=[user_coordinates objectAtIndex:n2-1];
            
            final_location.x=tmp.x+x_diff;
            final_location.y=tmp.y+y_diff;
            
            
            
            [user_coordinates addObject:final_location];
        }
        
    }
    
    
    return user_coordinates;
    
    
}

@end