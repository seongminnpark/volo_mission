//
//  ViewController.m
//  VLOGetCoordinates
//
//  Created by M on 2016. 6. 13..
//  Copyright © 2016년 M. All rights reserved.
//

#import "ViewController.h"
#import "ViewController.h"
#import "Location.h"
#import "Marker.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize print_coordinates;

- (void)viewDidLoad {
    
    tv1=[[UITextView alloc]initWithFrame:CGRectMake(10, 10, 300, 100)];
    tv2=[[UITextView alloc]initWithFrame:CGRectMake(10, 100, 300, 100)];
    tv3=[[UITextView alloc]initWithFrame:CGRectMake(10, 200, 300, 100)];
    print_coordinates=[NSArray array];
    
    print_marker=[[Marker alloc]init];
    
    start_location=[[Location alloc]init];
    print_coordinates=[start_location set_coordinates];
    
    
    print_marker=[print_coordinates objectAtIndex:0];
    str=[NSString stringWithFormat:@"%ld, %ld",(long)print_marker.x,(long)print_marker.y];
    tv1.text=str;
    
    [self.view insertSubview:tv1 atIndex:0];
    
    print_marker=[print_coordinates objectAtIndex:1];
    str=[NSString stringWithFormat:@"%ld, %ld",(long)print_marker.x,(long)print_marker.y];
    tv2.text=str;
    
    [self.view insertSubview:tv2 atIndex:0];
    
    print_marker=[print_coordinates objectAtIndex:2];
    str=[NSString stringWithFormat:@"%ld, %ld",(long)print_marker.x,(long)print_marker.y];
    tv3.text=str;
    
    [self.view insertSubview:tv3 atIndex:0];
    
    
    
    
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
