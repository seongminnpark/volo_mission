//
//  VLOTimelineSummary.m
//  Volo
//
//  Created by Seongmin on 8/1/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import "VLOSummaryViewController.h"

@interface VLOSummaryViewController ()

@property (strong, nonatomic) NSArray *logList;
@property (strong, nonatomic) NSMutableArray *markers;
@property (strong, nonatomic) NSMutableArray *segments;
@property (strong, nonatomic) NSMutableArray *drawables;
@property (strong, nonatomic) UIView  *summaryView;

@property () CGFloat actualWidth;
@property () CGFloat summaryWidth;
@property () CGFloat summaryHeight;

@end

@implementation VLOSummaryViewController

- (id) initWithLogs:(NSArray *)logList andView:(UIView *)view {
    self = [super init];
    
    _logList   = logList;                // 타임라인 테이블뷰에게서 받은 로그 리스트.
    _markers   = [NSMutableArray array]; // 위치, 경로 정보에서 추출한 마커 리스트.
    _segments  = [NSMutableArray array]; // 마커 사이 선(세그먼트) 리스트.
    _drawables = [NSMutableArray array]; // 이미지 리소스 캐싱.
    _summaryView = view;
    _summaryWidth = _summaryView.bounds.size.width;
    _summaryHeight = _summaryView.bounds.size.height;
    _actualWidth = _summaryWidth - (SEGMENT_CONTENT_SIZE * 2);
    
    [self parseLogList:logList];
    
    return self;
}

- (void) parseLogList:(NSArray *)logList {
    NSMutableArray *placeList = [[NSMutableArray alloc] init];
    NSMutableArray *dayList = [[NSMutableArray alloc] init];
    NSMutableArray *transportList = [[NSMutableArray alloc] init];
    NSNumber *day = @(1);
    NSInteger line_cnt = 1;
    NSInteger st_marker_num = 0;
  
    for(NSInteger i = 0; i < logList.count; i++) {
        VLOLog *log = [logList objectAtIndex:i];
        
        if(log.type == VLOLogTypeDay) {
            VLODayLog *dayLog = (VLODayLog *)log;
            day = (NSNumber *)dayLog.day;
        }
        if(log.type == VLOLogTypeMap) {
            [placeList addObject:log.place];
            [transportList addObject:@"NO"];
            [dayList addObject:day];
        } else if(log.type == VLOLogTypeRoute) {
            for (VLORouteNode *node in ((VLORouteLog *)log).nodes) {
                [placeList addObject:node.place];
                NSString *transport_name = [VLORouteLog imageNameOf:node.transportType];
                [transportList addObject:transport_name];
                [dayList addObject:day];
            }
        }
    }
    
    if (placeList.count < 1) {
        return;
    }
    
    // 연속으로 중복되거나 불량한 인풋 정리
    NSArray *organized_placeList = [self sanitizeInput:placeList :dayList];
    
    NSInteger markerNum = organized_placeList.count;
    NSMutableArray *tmp_arr = [self getStandardXCoordinate:markerNum :line_cnt];
    
    CGFloat standartY = MARKER_CONTENT_SIZE / 2;
    CGFloat newY = standartY;
    UIColor *color = VOLO_COLOR;
    
    for (NSInteger i = 0; i < organized_placeList.count; i++) {
        
        VLOPlace *curPlace = [organized_placeList objectAtIndex:i];
        VLOSummaryMarker *newMarker = [[VLOSummaryMarker alloc] init];
        CGFloat xCoordinate = [[tmp_arr objectAtIndex:st_marker_num] floatValue];
        NSNumber *dayNum = [dayList objectAtIndex:i];
        
        if(i != 0 && i % LINE_MAX_MARKER == 0) {
            newY += (MARKER_CONTENT_SIZE + MARKER_LABEL + MARKER_FLAG_SIZE);
        }
        
        newMarker.x = xCoordinate;
        newMarker.y = newY;
        newMarker.name = curPlace.name;
        newMarker.country = curPlace.country;
        newMarker.day = dayNum;
        newMarker.color = color;
        
        [newMarker setMarkerImage:@"marker"];
        [newMarker setMarkerContentImage:@"markerContent" isFlag:NO];
        //[newMarker setMarkerContentImage:@"78_AF" isFlag:YES];

        [_markers addObject:newMarker];
        [_drawables addObject:[[_markers objectAtIndex:i] getDrawableView]];
        
        st_marker_num++;
        
        if(st_marker_num >= (2 * LINE_MAX_MARKER)) {
            st_marker_num = 0;
        }
    }
    
    line_cnt = 1;
    
    for(NSInteger i = 0; i < _markers.count - 1; i++) {
        VLOSummarySegment *segment = [[VLOSummarySegment alloc] initFrom:[_markers objectAtIndex:i] to:[_markers objectAtIndex:i+1]];
        NSString *transportType = [transportList objectAtIndex:i];
        
        if (i > 0 && i % LINE_MAX_MARKER == 0) {
            line_cnt++;
        }
        if(line_cnt % 2 == 0) { // 짝수줄.
            if(i % 3 == 2) { // 짝수줄에서 짝수줄로 내려가는 커브.
                segment.curved = YES;
                segment.leftToRight = YES;
                [segment setSegmentContentImage:@"segmentContentLeftToRight"];
            }
            else { // 짝수줄의 직선.
                segment.curved = NO;
                segment.leftToRight = NO;
                [segment setSegmentContentImage:@"segmentContentRightToLeft"];
            }
        }
        else { // 홀수줄.
            if(i % 3 == 2) { // 홀수줄에서 짝수줄로 내려가는 커브.
                segment.curved = YES;
                segment.leftToRight = NO;
                [segment setSegmentContentImage:@"segmentContentRightToLeft"];
            }
            else { // 짝수줄의 직선.
                segment.curved = NO;
                segment.leftToRight = YES;
                [segment setSegmentContentImage:@"segmentContentLeftToRight"];
            }
        }
        
//        if (![transportType isEqualToString:@"NO"]) {
//            [segment setSegmentContentImage:transportType];
//        }
//        else {
//            segment.hasSegmentContent = NO;
//        }
        
        segment.hasSegmentContent = YES;
        
        [segment setSegmentImageLong:@"longSegment"
                              middle:@"middleSegment"
                               shortt:@"shortSegment"
                               curve:@"curveSegment"];

        [_segments addObject:segment];
        [_drawables addObject:[[_segments objectAtIndex:i] getDrawableView]];
        
    }
    
    // 마지막 marker 추가
    [_drawables addObject:[[_markers objectAtIndex:_markers.count-1] getDrawableView]];
    
}

- (void) drawSummary {
    for (UIView *drawable in _drawables) {
        [_summaryView addSubview:drawable];
    }
}

- (NSArray *) sanitizeInput:(NSArray *)placeList :(NSMutableArray *)dayList {
    
    NSMutableIndexSet *indicesToRemove = [NSMutableIndexSet indexSet];
    NSMutableArray *newPlaceList = [[NSMutableArray alloc] initWithArray:placeList copyItems:YES];
    
    for (NSInteger i = 1; i < placeList.count; i++) {
        
        VLOPlace *prevPlace = [placeList objectAtIndex:i-1];
        VLOPlace *currPlace = [placeList objectAtIndex:i];
        
        BOOL sameLat = prevPlace.coordinates.latitude.floatValue == currPlace.coordinates.latitude.floatValue;
        BOOL sameLong = prevPlace.coordinates.longitude.floatValue == currPlace.coordinates.longitude.floatValue;
        
        // 중복되는 마커 검사. 중복되는 기준은 같은 coordinate.
        if (sameLat & sameLong) {
            [indicesToRemove addIndex:i];
        }
        
    }
    // 중복마커 제거
    [newPlaceList removeObjectsAtIndexes:indicesToRemove];
    [dayList removeObjectsAtIndexes:indicesToRemove];
    
    return newPlaceList;
}

- (CGFloat) distance:(VLOPlace *)from :(VLOPlace *)to {
    
    CGFloat latitudeDiff = [to.coordinates.latitude floatValue] - [from.coordinates.latitude floatValue];
    CGFloat longitudeDiff = [to.coordinates.longitude floatValue] - [from.coordinates.longitude floatValue];
    
    return sqrt(pow(latitudeDiff,2) + pow(longitudeDiff,2));
}

- (NSMutableArray *) getStandardXCoordinate:(NSInteger)markerNum :(NSInteger)lineNum {

    CGFloat standardX = _actualWidth / LINE_MAX_MARKER;
    CGFloat newX = (markerNum == 1) ? _summaryWidth / 2 :
    (markerNum == 2)? (_summaryWidth / 2) - (standardX / 2) :
                      (_summaryWidth / 2) - standardX - 10;
    NSMutableArray *standard_coordinates = [NSMutableArray array];
    
    for(NSInteger i = 0; i < (2 * LINE_MAX_MARKER); i++) {
        if (i > 0) {
            if (i % LINE_MAX_MARKER == 0) {
                lineNum++;
                
                if(lineNum % 2 == 0) {
                    newX += (MIDDLE_SEGMENT - SHORT_SEGMENT);
                }
                else {
                    newX -= (MIDDLE_SEGMENT - SHORT_SEGMENT);
                }
            }
            else {
                if (lineNum % 2 == 0) {
                    newX -= standardX;
                }
                else {
                    newX += standardX;
                }
            }
        }
        [standard_coordinates addObject:@(newX)];
    }
    
    return standard_coordinates;
    
}

@end
