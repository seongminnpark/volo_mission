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
    _gc = [[GetCoordinates alloc]init];
    NSArray *marker_list=[_gc set_location:_location_list];
    
    _animationMaker = [[VLOPathAnimationMaker alloc] initWithView:summaryView andMarkerList:marker_list];
    return self;

}

- (void) animateSummary {
    [_animationMaker animatePath];
}

@end