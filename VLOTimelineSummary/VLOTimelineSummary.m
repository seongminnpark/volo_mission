//
//  VLOTimelineSummary.m
//  VLOTimelineSummary
//
//  Created by M on 2016. 6. 14..
//  Copyright © 2016년 M. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLOTimelineSummary.h"

@implementation VLOTimelineSummary


- (id)_init
{
    self=[super init];
    _gc=[[GetCoordinates alloc]init];
    _animationMaker = [[VLOPathAnimationMaker alloc] init];
    
    return self;

}

- (UIView *)MakeSummary:(NSArray *)location_list
{
    NSArray * coordinate_list=[_gc set_location];
    
    return [_animationMaker pathViewFromMarkers: coordinate_list];
}

@end