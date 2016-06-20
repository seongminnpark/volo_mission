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
#import "VLOPlace.h"

@implementation GetCoordinates

@synthesize user_coordinates;


-(id)init:(NSArray *)pl
{
    self=[super init];
    final_location=[[Marker alloc]init];
    Marker * tmp_marker=pl[0];
    user_coordinates=[NSMutableArray arrayWithCapacity:100]; //최종 좌표(x,y)를 담을 배열
    
    final_location.x=10;
    final_location.y=100;
    final_location.name=tmp_marker.name;
    
    [user_coordinates addObject:final_location];

//    [final_location release];
    
    return self;
    
}

// 두 지점 사이의 거리를 계산하는 함수

- (double)get_distance:(VLOLocationCoordinate *)location1 :(VLOLocationCoordinate *)location2
{
    distance=sqrt(([location1.latitude doubleValue]-[location2.latitude doubleValue])*([location1.latitude doubleValue]-[location2.latitude doubleValue])+([location1.longitude doubleValue]-[location2.longitude doubleValue])*([location1.longitude doubleValue]-[location2.longitude doubleValue]));
    
    
    
    return distance;
}



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
    
    VLOPlace * start_place=lo[0];
    VLOPlace * end_place=lo[n-1];
    
    VLOLocationCoordinate * start_location=start_place.coordinates;
    VLOLocationCoordinate * end_location=end_place.coordinates;
    start_end_distance=[self get_distance:start_location :end_location];
    
    
    for(i=0;i<n-1;i++)
    {
        input_place1=lo[i];
        input_place2=lo[i+1];
        
        input_location1=input_place1.coordinates;
        input_location2=input_place2.coordinates;
        
        if(_MAX>start_end_distance)
        {
            final_location=[[Marker alloc]init];

            x_diff=[self get_distance:input_location1 :input_location2];
            x_diff=x_diff+((_MAX-start_end_distance)/n);
            y_diff=([input_location1.latitude doubleValue]-[input_location2.latitude doubleValue])*10; //y좌표 증가량
      
            
            if(y_diff>20)
            {
                y_diff=20;
            }
            else if(y_diff<-20)
            {
                y_diff=-20;
            }
            
            NSInteger n2=[user_coordinates count];
            Marker * tmp=[user_coordinates objectAtIndex:n2-1];
            
            final_location.x=tmp.x+x_diff;
            final_location.y=tmp.y+y_diff;
            final_location.name=input_place2.name;
            
            [user_coordinates addObject:final_location];
           // [final_location release];
            
        }
        else if(_MAX<start_end_distance+10)
        {
            final_location=[[Marker alloc]init];

            x_diff=[self get_distance:input_location1 :input_location2];
            x_diff=x_diff-((start_end_distance-_MAX)/n);
            y_diff=([input_location1.latitude doubleValue]-[input_location2.latitude doubleValue])*10;
            
            if(y_diff>20)
            {
                y_diff=20;
            }
            else if(y_diff<-20)
            {
                y_diff=-20;
            }
            
            NSInteger n2=[user_coordinates count];
            Marker * tmp=[user_coordinates objectAtIndex:n2-1];
            
            final_location.x=tmp.x+x_diff;
            final_location.y=tmp.y+y_diff;
            final_location.name=input_place2.name;
            
            
            if(final_location.x<10)
            {
                final_location.x=10;
            }
            if(final_location.y<0)
            {
                final_location.y=0;
            }
            
            [user_coordinates addObject:final_location];
        //    [final_location release];
        }
        
    }
    
    
    return user_coordinates;
    
    
}


@end