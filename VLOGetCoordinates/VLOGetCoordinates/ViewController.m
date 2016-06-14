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
    
    NSInteger cnt;
    NSInteger i;

    print_marker=[[Marker alloc]init];
    start_location=[[GetCoordinates alloc]init];
    
    print_coordinates=[start_location set_location];
    
    cnt=[print_coordinates count];
    
    for(i=0;i<cnt-1;i++)
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
