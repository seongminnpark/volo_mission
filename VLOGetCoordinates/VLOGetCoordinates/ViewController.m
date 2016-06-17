//
//  ViewController.m
//  VLOGetCoordinates
//
//  Created by M on 2016. 6. 13..
//  Copyright © 2016년 M. All rights reserved.
//

#import "ViewController.h"
#import "ViewController.h"
//#import "Location.h"
#import "VLOLocationCoordinate.h"
#import "getCoordinates.h"
#import "Marker.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize print_coordinates;

- (void)viewDidLoad {
    
    NSInteger cnt;
    NSInteger i;
    
    VLOLocationCoordinate * vc1=[[VLOLocationCoordinate alloc]init];
    VLOLocationCoordinate * vc2=[[VLOLocationCoordinate alloc]init];
    VLOLocationCoordinate * vc3=[[VLOLocationCoordinate alloc]init];
    
    [vc1 setLatitude:[NSNumber numberWithDouble:37.460195]];
    [vc1 setLongitude:[NSNumber numberWithDouble:126.438507]];
    
    [vc2 setLatitude:[NSNumber numberWithDouble:51.504847]];
    [vc2 setLongitude:[NSNumber numberWithDouble:0.0473293]];
    
    [vc3 setLatitude:[NSNumber numberWithDouble:52.9541053]];
    [vc3 setLongitude:[NSNumber numberWithDouble:-1.2401013]];
    
    NSMutableArray * location_list=[NSMutableArray array];
    [location_list addObject:vc1];
    [location_list addObject:vc2];
    [location_list addObject:vc3];
    
    
    
    
    print_marker=[[Marker alloc]init];
    start_location=[[GetCoordinates alloc]init];
    
    print_coordinates=[start_location get_coordinates:location_list];
    
    cnt=[print_coordinates count];
    
    for(i=0;i<cnt;i++)
    {
        print_marker=[print_coordinates objectAtIndex:i];
        UIImageView *iv=[[UIImageView alloc]initWithFrame:CGRectMake(print_marker.x, print_marker.y, 15, 20)];
        iv.image=[UIImage imageNamed:@"location-placemark-gradient.png"];
        [self.view addSubview:iv];
    }
    
    
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
