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
    _actualWidth = _summaryWidth - (SEGMENT_ICON_SIZE * 2);
    
    [self parseLogList:logList];
    
    return self;
}

- (void) parseLogList:(NSArray *)logList {
    NSMutableArray *placeList = [NSMutableArray array];
    NSMutableArray *dayList = [NSMutableArray array];

    NSNumber *day = @(1);
  
    // 로그 리스트에서 VLOPlace를 추출.
    for(NSInteger i = 0; i < logList.count; i++) {
        VLOLog *log = [logList objectAtIndex:i];
        
        if(log.type == VLOLogTypeDay) {
            VLODayLog *dayLog = (VLODayLog *)log;
            day = (NSNumber *)dayLog.day;
        } else if(log.type == VLOLogTypeMap) {
            [placeList addObject:log.place];
            [dayList addObject:day];
        } else if(log.type == VLOLogTypeRoute) {
            for (VLORouteNode *node in ((VLORouteLog *)log).nodes) {
                [placeList addObject:node.place];
                [dayList addObject:day];
            }
        }
    }
    
    if (placeList.count < 1) {
        return;
    }
    
    // 연속으로 중복되거나 불량한 인풋 정리
    NSArray *new_placeList = [self sanitizeInput:placeList:dayList];
    
    // 마커와 세그먼트 생성.
    [self initializeBackgroundView];
    [self initializeMarkerList:new_placeList:dayList];
    [self initializeSegmentList];
    
    // 레이서 순서를 위해 마커 drawable를 drawables에 추가한다. Segment의 drawable은 initializeSegmentList에서 추가된다.
    for (VLOSummaryMarker *marker in _markers) {
        [_drawables addObject:[marker getDrawableView]];
    }
}

- (void) drawSummary {
    for (UIView *drawable in _drawables) {
        [_summaryView addSubview:drawable];
    }
}

- (NSArray *) sanitizeInput:(NSArray *)placeList :(NSArray *)dayList {
    
    NSMutableIndexSet *indicesToRemove = [NSMutableIndexSet indexSet];
    NSMutableArray *newPlaceList = [[NSMutableArray alloc] initWithArray:placeList copyItems:YES];
    NSMutableArray *newDayList = [[NSMutableArray alloc] initWithArray:dayList copyItems:YES];
                                  
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
    [newDayList removeObjectsAtIndexes:indicesToRemove];
    
    return newPlaceList;
}

- (void) initializeBackgroundView {
    UIImage *backgroundImage = [UIImage imageNamed:@"background-1"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.frame = CGRectMake(0, 0, BACKGROUND_WIDTH, BACKGROUND_HEIGHT);
    [_drawables addObject:backgroundImageView];
}

- (void) initializeMarkerList:(NSArray *)placeList :(NSArray *)dayList {
    
    CGFloat columnWidth = LONG_SEGMENT;
    CGFloat rowChangeXdiff = MIDDLE_SEGMENT - SHORT_SEGMENT;
    CGFloat firstMarkerY = BACKGROUND_HEIGHT;
    CGFloat firstMarkerX;
    
    switch (placeList.count) {
        case (1): firstMarkerX = _summaryWidth / 2.0;                     break;
        case (2): firstMarkerX = _summaryWidth / 2.0 - columnWidth / 2.0; break;
        default : firstMarkerX = _summaryWidth / 2.0 - columnWidth - 5;   break;
    }
    
    for (NSInteger i = 0; i < placeList.count; i++) {
        
        NSInteger row = i / MARKERS_PER_LINE;
        NSInteger col = i % MARKERS_PER_LINE;
        
        BOOL oddLine = row % 2 == 0; // 0번째 줄 부터 시작하기 때문에 lineNum이 짝수일 때 홀수 줄이다.
        
        CGFloat newX;
        if (oddLine) newX = firstMarkerX + col * columnWidth;
        else         newX = firstMarkerX + (MARKERS_PER_LINE - col - 1) * columnWidth;
        CGFloat newY = firstMarkerY + row * LINE_GAP;
        
        if (!oddLine) newX += rowChangeXdiff;
        
        VLOPlace *currPlace = [placeList objectAtIndex:i];
        VLOSummaryMarker *newMarker = [[VLOSummaryMarker alloc] init];
        
        newMarker.x = newX;
        newMarker.y = newY;
        newMarker.name = currPlace.name;
        newMarker.country = currPlace.country;
        newMarker.day = [dayList objectAtIndex:i];
        newMarker.color = VOLO_COLOR;
        
        if (oddLine) [newMarker setMarkerImage:@"marker_flag_cn" isDay:NO isFlag:YES];
        else [newMarker setMarkerImage:@"marker_day" isDay:YES isFlag:NO];

        [newMarker setMarkerIconImage:@"marker-icon-sample01"];
        
        [_markers addObject:newMarker];
        //[_drawables addObject:[newMarker getDrawableView]];
    }
}

- (void) initializeSegmentList {
    
    for(NSInteger i = 0; i < _markers.count - 1; i++) {
        VLOSummarySegment *segment = [[VLOSummarySegment alloc] initFrom:[_markers objectAtIndex:i] to:[_markers objectAtIndex:i+1]];
        
        NSInteger row = i / MARKERS_PER_LINE;
        
        BOOL oddLine = row % 2 == 0; // 0번째 줄 부터 시작하기 때문에 lineNum이 짝수일 때 홀수 줄이다.
        BOOL curved  = i % MARKERS_PER_LINE == MARKERS_PER_LINE - 1;
        
        segment.curved = curved;
        segment.leftToRight = (oddLine && !curved) || (!oddLine && curved);
        
        if (segment.leftToRight && !curved) [segment setSegmentIconImage:@"line-icon-left-sample01"];
        if (segment.leftToRight && curved) [segment setSegmentIconImage:@"curve-line-icon-left"];
        if (!segment.leftToRight && !curved) [segment setSegmentIconImage:@"line-icon-right-sample01"];
        if (!segment.leftToRight && curved) [segment setSegmentIconImage:@"curve-line-icon-right"];
        
        segment.hasSegmentIcon = YES;
        
        [segment setSegmentImageLong:@"line-long"
                              middle:@"line-middle"
                              shortt:@"line-short"
                               curve:@"line-curve"];
        
        [_segments addObject:segment];
        [_drawables addObject:[segment getDrawableView]];
    }
}

@end
