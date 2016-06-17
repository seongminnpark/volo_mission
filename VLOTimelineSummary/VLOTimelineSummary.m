//
//  VLOTimelineSummary.m
//  VLOTimelineSummary
//
//  Created by M on 2016. 6. 14..
//  Copyright © 2016년 M. All rights reserved.
//

#import "VLOTimelineSummary.h"

@interface VLOTimelineSummary()

@property (strong, nonatomic) NSArray *location_list;

@end

@implementation VLOTimelineSummary


- (id)initWithView:(UIView *)summaryView andLocationList:(NSArray *)location_list
{
    self = [super init];
    _gc = [[GetCoordinates alloc] init];
    //NSArray *marker_list=[_gc set_location:_location_list];
    //NSLog(@"%li",marker_list.count);
    NSMutableArray *marker_list = [[NSMutableArray alloc] init];
    Marker *m1 = [[Marker alloc] init];
    Marker *m2 = [[Marker alloc] init];
    Marker *m3 = [[Marker alloc] init];
    Marker *m4 = [[Marker alloc] init];
    Marker *m5 = [[Marker alloc] init];
    m1.x = 50; m1.y = 250; m1.name = @"Madrid";
    m2.x = 100; m2.y = 250; m2.name = @"Barcelona";
    m3.x = 150; m3.y = 250; m3.name = @"Seoul";
    m4.x = 200; m4.y = 250; m4.name = @"Gimpo";
    m5.x = 250; m5.y = 250; m5.name = @"Mallorca";
    [marker_list addObject:m1];
    [marker_list addObject:m2];
    [marker_list addObject:m3];
    [marker_list addObject:m4];
    [marker_list addObject:m5];
    _animationMaker = [[VLOPathAnimationMaker alloc] initWithView:summaryView andMarkerList:marker_list];
    return self;
    
}

- (void) animateSummary {
    [_animationMaker animatePath];
}

@end