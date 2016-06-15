//
//  VLOTimelineSummary.m
//  VLOTimelineSummary
//
//  Created by M on 2016. 6. 14..
//  Copyright © 2016년 M. All rights reserved.
//

#import "VLOTimelineSummary.h"

@implementation VLOTimelineSummary


- (id)init
{
    self=[super init];
    _gc=[[GetCoordinates alloc]init];
    
    return self;

}

- (void) summaryInView:(UIView *)view locations:(NSArray *)location_list
{
    NSArray *coordinate_list=[_gc set_location:location_list];
    _animationMaker = [[VLOPathAnimationMaker alloc] initWithView:view];
    _animationMaker.markerList = coordinate_list;
}

- (void) animate {
    [_animationMaker animatePath];
}

@end