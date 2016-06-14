//
//  ViewController.h
//  VLOGetCoordinates
//
//  Created by M on 2016. 6. 13..
//  Copyright © 2016년 M. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class Location;
//@class VLOLocationCoordinate;
@class Marker;
@class GetCoordinates;

@interface ViewController : UIViewController
{
    UIImageView * im1;
    UIImageView * im2;
    UIImageView * im3;
    UIImageView * im4;
    UIImageView * im5;
    UIImageView * im6;
    UIImageView * im7;
    
    
    
    
    GetCoordinates * start_location;
    
    Marker * print_marker;
    NSString * str;
}

@property (strong,nonatomic) NSArray * print_coordinates;

@end

