//
//  VLOSummaryTheme.m
//  Volo
//
//  Created by Seongmin on 8/17/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import "VLOSummaryTheme.h"

@interface VLOSummaryTheme ()

@property () NSMutableArray *shuffledLong;
@property () NSMutableArray *shuffledMedium;
@property () NSMutableArray *shuffledShort;
@property () NSMutableArray *shuffledCurve;

@property () NSInteger randomSeed;

@end

@implementation VLOSummaryTheme

- (id) init {
    self = [super init];
    
    _backgroundImage = @"img_bg_01";
    _markerImage = @"icon_poi_marker";
    
    
    _longSegments   = @[@"line_a_01", @"line_a_02", @"line_a_03", @"line_a_04"];
    _mediumSegments = @[@"line_b_01", @"line_b_02", @"line_b_03"];
    _shortSegments  = @[@"line_c_01", @"line_c_02", @"line_c_03"];
    _curveSegments  = @[@"line_round_left_01", @"line_round_left_02", @"line_round_left_03"];
    
    _randomSeed = _longSegments.count + _mediumSegments.count +
                  _shortSegments.count + _curveSegments.count;
    
    _shuffledLong   = [NSMutableArray array];
    _shuffledMedium = [NSMutableArray array];
    _shuffledShort  = [NSMutableArray array];
    _shuffledCurve  = [NSMutableArray array];
    
    return self;
}

- (void) shuffleIndex:(NSInteger)segmentCount {
    
    // 난수화 해야함!!!!!!! _segments의 길이가 0인 경우는 생각 안 함. (추후에 예외처리)
    
    for (NSInteger i = 0; i < segmentCount; i ++) {
        [_shuffledLong addObject:@((_longSegments.count == 1) ? 0 : i % (_longSegments.count - 1))];
        [_shuffledMedium addObject:@((_mediumSegments.count == 1) ? 0 : i % (_mediumSegments.count - 1))];
        [_shuffledShort addObject:@((_shortSegments.count == 1) ? 0 : i % (_shortSegments.count - 1))];
        [_shuffledCurve addObject:@((_curveSegments.count == 1) ? 0 : i % (_curveSegments.count - 1))];
    }
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
