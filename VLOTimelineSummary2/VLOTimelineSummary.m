//
//  VLOTimelineSummary.m
//  Volo
//
//  Created by Seongmin on 8/1/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import "VLOTimelineSummary.h"

@interface VLOTimelineSummary ()

@property (strong, nonatomic) NSArray *logList;
@property (strong, nonatomic) NSMutableArray *markers;
@property (strong, nonatomic) NSMutableArray *segments;
@property (strong, nonatomic) NSMutableArray *elements; // Markers + Segments.
@property (strong, nonatomic) NSMutableArray *drawables;

@property (strong, nonatomic) UIView  *summaryView;

@end

@implementation VLOTimelineSummary

- (id) initWithLogs:(NSArray *)logList andView:(UIView *)view {
    self = [super init];
    
    _logList   = logList;                // 타임라인 테이블뷰에게서 받은 로그 리스트.
    _markers   = [NSMutableArray array]; // 위치, 경로 정보에서 추출한 마커 리스트.
    _segments  = [NSMutableArray array]; // 마커 사이 선(세그먼트) 리스트.
    _elements  = [NSMutableArray array]; // 마커리스트 + 세그먼트 리스트.
    _drawables = [NSMutableArray array]; // 이미지 리소스 캐싱.
    
    _summaryView = view;
    
    _summaryWidth = _summaryView.bounds.size.width;
    _summaryHeight = _summaryView.bounds.size.height;
    _actualWidth = _summaryWidth - (MARKER_CONTENT_SIZE * 2);
    
    
    [self parseLogList:logList];
    
    return self;
}

- (void) parseLogList:(NSArray *)logList {
    

    NSMutableArray *placeList = [[NSMutableArray alloc] init];
    NSMutableArray *dayList = [[NSMutableArray alloc] init];
    NSMutableArray *transportList = [[NSMutableArray alloc] init];
    NSNumber *day = @(1);
    NSInteger line_cnt = 1;
    
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
    
    // 연속으로 중복되거나 불량한 인풋, 군집된 로케이션 정리
    NSArray *organized_placeList = [self sanitizeInput:placeList :dayList];
    
    // 각 마커의 x 좌표를 설정하기 위해 경도 분포를 확인합니다.
    [self initDistanceList:organized_placeList];
    
    NSInteger markerNum = organized_placeList.count;
    NSInteger lineNum = (markerNum % LINE_MAX_MARKER == 0) ? markerNum / LINE_MAX_MARKER : (markerNum / LINE_MAX_MARKER) + 1;
    
    // 첫 VLOMarker의 좌표.
    CGFloat leftover = _actualWidth - (@(MARKER_CONTENT_SIZE).intValue * LINE_MAX_MARKER);
    if (leftover < 0) {
        leftover = 0;
    }
    
    CGFloat standardX = _actualWidth / LINE_MAX_MARKER;
    CGFloat standartY = MARKER_CONTENT_SIZE;
    CGFloat newX = (markerNum == 1) ? [VLOUtilities screenWidth] / 2 : (markerNum == 2)? ([VLOUtilities screenWidth] / 2) - (standardX / 2) : (_summaryWidth / 2) - standardX;
    CGFloat newY = standartY;
    UIColor *color = VOLO_COLOR;
    
    for (NSInteger i = 0; i < organized_placeList.count; i++) {
        
        VLOPlace *curPlace = [organized_placeList objectAtIndex:i];
        VLOSummaryMarker *newMarker = [[VLOSummaryMarker alloc] init];
        NSNumber *dayNum = [dayList objectAtIndex:i];
        
        if (i > 0) {
            if (i % LINE_MAX_MARKER == 0) {
                line_cnt++;
                newY += (standartY * LINE_MAX_MARKER);
                
                if(line_cnt % 2 == 0) {
                    newX -= MARKER_SIZE;
                }
                else {
                    newX += MARKER_SIZE;
                }
            }
            else {
                if (line_cnt % 2 == 0) {
                    newX -= standardX;
                }
                else {
                    newX += standardX;
                }
            }
        }
        newMarker.x = newX;
        newMarker.y = newY;
        newMarker.name = curPlace.name;
        newMarker.country = curPlace.country;
        newMarker.day = dayNum;
        newMarker.color = color;
        
        [_markers addObject:newMarker];
    }
    
    line_cnt = 1;
    
    for(NSInteger i = 0; i < _markers.count - 1; i++) {
        VLOSummarySegment *segment = [[VLOSummarySegment alloc] initFrom:[_markers objectAtIndex:i] to:[_markers objectAtIndex:i+1]];
        NSString *transportType = [transportList objectAtIndex:i];
        
        if (i > 0 && i % LINE_MAX_MARKER == 0) {
            line_cnt++;
        }
        if(line_cnt % 2 == 0) {
            if(i % 3 == 2) {
                segment.curved = YES;
                segment.leftToRight = YES;
            }
            else {
                segment.curved = NO;
                segment.leftToRight = NO;
            }
        }
        else {
            if(i % 3 == 2) {
                segment.curved = YES;
                segment.leftToRight = NO;
            }
            else {
                segment.curved = NO;
                segment.leftToRight = YES;
            }
        }
        
        if (![transportType isEqualToString:@"NO"]) {
            [segment setSegmentContentImage:transportType];
        }
        else {
            segment.hasSegmentContent = NO;
        }
        
        [_segments addObject:segment];
        
    }
    
    for(NSInteger i = 0; i < _segments.count; i++) {
        [_drawables addObject:[[_segments objectAtIndex:i] getDrawableView]];
    }
    for(NSInteger i = 0; i < _markers.count; i++) {
        [_drawables addObject:[[_markers objectAtIndex:i] getDrawableView]];
    }
   
    
}

- (void) drawSummary {
    for (UIView *drawable in _drawables) {
        [_summaryView addSubview:drawable];
    }
}

- (NSArray *) sanitizeInput:(NSArray *)placeList :(NSMutableArray *)dayList {
    
    NSMutableIndexSet *indicesToRemove = [NSMutableIndexSet indexSet];
    NSMutableArray *newPlaceList = [[NSMutableArray alloc] initWithArray:placeList copyItems:YES];
    NSInteger overlap_cnt = 0;
    
    for (NSInteger i = 1; i < placeList.count; i++) {
        
        VLOPlace *prevPlace = [placeList objectAtIndex:i-1];
        VLOPlace *currPlace = [placeList objectAtIndex:i];
        
        BOOL sameLat = prevPlace.coordinates.latitude.floatValue == currPlace.coordinates.latitude.floatValue;
        BOOL sameLong = prevPlace.coordinates.longitude.floatValue == currPlace.coordinates.longitude.floatValue;
        
        // 중복되는 마커 검사. 중복되는 기준은 같은 coordinate.
        if (sameLat & sameLong) {
            overlap_cnt ++;
            [indicesToRemove addIndex:i];
        }
        
    }
    
    // 중복마커 제거
    [newPlaceList removeObjectsAtIndexes:indicesToRemove];
    [dayList removeObjectsAtIndexes:indicesToRemove];
    
    return newPlaceList;
}

- (void) initDistanceList:(NSArray *)placeList{
    _distanceList = [[NSMutableArray alloc] initWithCapacity:placeList.count-1];
    _distanceSum = 0;
    
    for (NSInteger i = 1; i < placeList.count; i++) {
        
        VLOPlace *prevPlace = [placeList objectAtIndex:i-1];
        VLOPlace *currPlace = [placeList objectAtIndex:i];
        CGFloat distance = [self distance:prevPlace:currPlace];
        _distanceSum += distance;
        [_distanceList addObject: @(distance)];
    }
    
}

- (CGFloat) distance:(VLOPlace *)from :(VLOPlace *)to {
    
    CGFloat latitudeDiff = [to.coordinates.latitude floatValue] - [from.coordinates.latitude floatValue];
    CGFloat longitudeDiff = [to.coordinates.longitude floatValue] - [from.coordinates.longitude floatValue];
    
    return sqrt(pow(latitudeDiff,2) + pow(longitudeDiff,2));
}

@end
