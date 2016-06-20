//
//  VLOTimelineSummary.m
//  VLOTimelineSummary
//
//  Created by M on 2016. 6. 14..
//  Copyright © 2016년 M. All rights reserved.
//

#import "VLOTimelineSummary.h"

@interface VLOTimelineSummary()

@end

@implementation VLOTimelineSummary


- (id)initWithView:(UIView *)summaryView andLocationList:(NSArray *)location_list
{
    self = [super init];
    _gc = [[GetCoordinates alloc] initWithLocation:location_list];
    NSArray *marker_list=[_gc get_coordinates:location_list];
    
//    NSMutableArray *marker_list=[NSMutableArray array];
//    Marker * m1 = [[Marker alloc] init];
//    Marker * m2 = [[Marker alloc] init];
//    Marker * m3 = [[Marker alloc] init];
//    Marker * m4 = [[Marker alloc] init];
//    Marker * m5 = [[Marker alloc] init];
//    
//    m1.x = 50; m1.y = 55; m1.name = @"부평";
//    m2.x = 100; m2.y = 51; m2.name = @"김포";
//    m3.x = 150; m3.y = 80; m3.name = @"마드리드";
//    m4.x = 220; m4.y = 65; m4.name = @"Mallorca";
//    m5.x = 270; m5.y = 60; m5.name = @"인천";
//    
//    [marker_list addObject:m1];
//    [marker_list addObject:m2];
//    [marker_list addObject:m3];
//    [marker_list addObject:m4];
//    [marker_list addObject:m5];

    _animationMaker = [[VLOPathAnimationMaker alloc] initWithView:summaryView andMarkerList:marker_list];
    return self;
    
}

- (void) animateSummary {
    [_animationMaker animatePath];
}

@end