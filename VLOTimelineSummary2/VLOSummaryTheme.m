//
//  VLOSummaryTheme.m
//  Volo
//
//  Created by Seongmin on 8/17/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import "VLOSummaryTheme.h"

@interface VLOSummaryTheme ()

@property () NSArray *shuffledLong;
@property () NSArray *shuffledMedium;
@property () NSArray *shuffledShort;
@property () NSArray *shuffledCurve;

@end

@implementation VLOSummaryTheme

- (id) init {
    self = [super init];
    
    _longSegments = [NSMutableArray array];
    _mediumSegments = [NSMutableArray array];
    _shortSegments = [NSMutableArray array];
    _curveSegments = [NSMutableArray array];
    
    _backgroundImage = @"img_bg_01";
    _markerImage = @"icon_poi_marker";
    
    
    _longSegments   = @[@"line_a_01", @"line_a_02", @"line_a_03", @"line_a_04"];
    _mediumSegments = @[@"line_b_01", @"line_b_02", @"line_b_03"];
    _shortSegments  = @[@"line_c_01", @"line_c_02", @"line_c_03"];
    _curveSegments  = @[@"line_round_left_01", @"line_round_left_02", @"line_round_left_03"];
    
    return self;
}

- (void) shuffleIndex:(NSInteger)segmentCount {
    _shuffledLong = @[@(0),@(1),@(3),@(2),@(3),@(1),@(0),@(3),@(2),@(1),@(0),@(2),@(1),@(0),@(3),@(1),@(2),@(0),@(1),@(2)];
    _shuffledMedium = @[@(2),@(1),@(2),@(1),@(2),@(1),@(0),@(1),@(2),@(1),@(0),@(2),@(1),@(0),@(0),@(1),@(2),@(0),@(1), @(2)];
    _shuffledShort =  @[@(2),@(1),@(2),@(1),@(2),@(1),@(0),@(1),@(2),@(1),@(0),@(2),@(1),@(0),@(0),@(1),@(2),@(0),@(1), @(0)];
    _shuffledCurve = @[@(0),@(2),@(1),@(0),@(2),@(0),@(1),@(0),@(2),@(0),@(2),@(1),@(2),@(0),@(1),@(0),@(1),@(2),@(0),@(1)];
}

- (NSString *)getLongSeg:(NSInteger)index {
    return [_longSegments objectAtIndex:[[_shuffledLong objectAtIndex:index] intValue]];
}

- (NSString *)getMedSeg:(NSInteger)index {
    return [_mediumSegments objectAtIndex:[[_shuffledMedium objectAtIndex:index] intValue]];
}

- (NSString *)getShortSeg:(NSInteger)index {
    return [_shortSegments objectAtIndex:[[_shuffledShort objectAtIndex:index] intValue]];
}

- (NSString *)getCurveSeg:(NSInteger)index {
    return [_curveSegments objectAtIndex:[[_shuffledCurve objectAtIndex:index] intValue]];
}

@end
