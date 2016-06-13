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
//#import "VLOLocationCoordinate.h"
#import "getCoordinates.h"
#import "Marker.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize print_coordinates;

- (void)viewDidLoad {
    
    

    print_coordinates=[NSArray array];
    print_marker=[[Marker alloc]init];
    start_location=[[GetCoordinates alloc]init];
    
    print_coordinates=[start_location set_location];
    

    print_marker=[print_coordinates objectAtIndex:0];

    im1=[[UIImageView alloc]initWithFrame:CGRectMake(print_marker.x, print_marker.y, 30, 30)];
    im1.image=[UIImage imageNamed:@"location-placemark-gradient.png"];
    [self.view addSubview:im1];
    
    print_marker=[print_coordinates objectAtIndex:1];
    
    im2=[[UIImageView alloc]initWithFrame:CGRectMake(print_marker.x,print_marker.y, 30, 30)];
    im2.image=[UIImage imageNamed:@"location-placemark-gradient.png"];
    [self.view addSubview:im2];
    
    
    print_marker=[print_coordinates objectAtIndex:2];
    
    im3=[[UIImageView alloc]initWithFrame:CGRectMake(print_marker.x, print_marker.y, 30, 30)];
    im3.image=[UIImage imageNamed:@"location-placemark-gradient.png"];
    [self.view addSubview:im3];
    
    
    
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
