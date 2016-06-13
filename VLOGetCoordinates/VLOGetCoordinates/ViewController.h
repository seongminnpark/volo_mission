//
//  ViewController.h
//  VLOGetCoordinates
//
//  Created by M on 2016. 6. 13..
//  Copyright © 2016년 M. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Location;
@class Marker;
@interface ViewController : UIViewController
{
    UITextView * tv1;
    UITextView * tv2;
    UITextView * tv3;
    Location * start_location;
    
    Marker * print_marker;
    NSString * str;
}

@property (strong,nonatomic) NSArray * print_coordinates;

@end

