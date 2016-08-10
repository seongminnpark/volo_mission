//
//  VLOTimelineSummary.m
//  Volo
//
//  Created by Seongmin on 8/1/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import "VLOSummaryViewController.h"

@interface VLOSummaryViewController ()

@property (strong, nonatomic) VLOTravel *travel;
@property (strong, nonatomic) NSArray *logList;

@property (strong, nonatomic) NSMutableArray *markers;
@property (strong, nonatomic) NSMutableArray *segments;
@property (strong, nonatomic) NSMutableArray *drawables;


@property () CGFloat actualWidth;
@property () CGFloat summaryWidth;

@end

@implementation VLOSummaryViewController

- (id) initWithTravel:(VLOTravel *)travel andLogList:(NSArray *)logList {
    self = [super init];
    
    _travel    = travel;                 // 타임라인 뷰컽트롤러에게 받은 트래블.
    _logList   = logList;                // 타임라인 테이블뷰에게 받은 로그 리스트.
    _markers   = [NSMutableArray array]; // 위치, 경로 정보에서 추출한 마커 리스트.
    _segments  = [NSMutableArray array]; // 마커 사이 선(세그먼트) 리스트.
    _drawables = [NSMutableArray array]; // 이미지 리소스 캐싱.

    _summaryWidth = self.view.bounds.size.width;
    
    NSLog(@"Frame: %@", self.view);
    _actualWidth = _summaryWidth - (SEGMENT_ICON_SIZE * 2);
    
    [self parseLogList:logList];
    [self setMarkerCoordinates];
    [self initializeDrawables];
    
    return self;
}

- (void) drawSummary {
    for (UIView *drawable in _drawables) {
        [self.view addSubview:drawable];
    }
}

- (void) parseLogList: (NSArray *)logList {

    NSInteger GMTOffset = [_travel.timezone getNSTimezone].secondsFromGMT;
    NSInteger logIndex = 0;
    VLOPlace *currPlace, *prevPlace;
    
    for (VLOLog *log in logList) {
        
        NSNumber *day = nil;
        
        if (_travel.hasDate) {
            day = @([VLOUtilities calculateDaysBetweenFrom:_travel.startDate
                                             withGMTOffset:GMTOffset to:log.date withGMTOffset:GMTOffset]);
        }
        
        currPlace = log.place;
        
        if (log.type == VLOLogTypeMap) {
    
            if ([self createMarkerAndSegemnt:log
                                   logIndex:logIndex
                                         day:day
                                   currPlace:currPlace
                                   prevPlace:prevPlace
                               transportType:VLOTransportTypeUnknown]) {
            
                prevPlace = currPlace;
            }
        }
        
        else if (log.type == VLOLogTypeRoute) {
         
            for (VLORouteNode *node in ((VLORouteLog *)log).nodes) {
                
                currPlace = node.place;
                
                if ([self createMarkerAndSegemnt:log
                                        logIndex:logIndex
                                             day:day
                                       currPlace:currPlace
                                       prevPlace:prevPlace
                                   transportType:node.transportType]) {
                    
                    prevPlace = currPlace;
                }
            }
        }
        
        logIndex ++;
    }
}

- (BOOL) createMarkerAndSegemnt:(VLOLog *)log
                       logIndex:(NSInteger)logIndex
                            day:(NSNumber*)day
                      currPlace:(VLOPlace *)currPlace
                      prevPlace:(VLOPlace *)prevPlace
                  transportType:(VLOTransportType)transportType {
    
    if (prevPlace != nil) {
        
        BOOL sameLat = prevPlace.coordinates.latitude.floatValue == currPlace.coordinates.latitude.floatValue;
        BOOL sameLong = prevPlace.coordinates.longitude.floatValue == currPlace.coordinates.longitude.floatValue;
        
        // 중복되는 마커 검사. 중복되는 기준은 같은 coordinate.
        if (sameLat & sameLong) return NO;
    }
    
    VLOSummaryMarker *marker = [self createMarkerFromLog:log andPlace:currPlace];
    marker.day = day;
    marker.logIndex= logIndex;
    [_markers addObject:marker];
    
    if (_markers.count > 1) {
        
        // _markers.count-2는 마지막에서 두 번째 마커의 인덱스.
        VLOSummaryMarker *prevMarker = [_markers objectAtIndex:_markers.count-2];
        if (day != nil && prevMarker.day != day) [marker setMarkerImage:@"marker_day" isDay:YES isFlag:NO];
        else if (![prevPlace.country.country isEqualToString:currPlace.country.country])
            [marker setMarkerImage:@"marker_flag_cn" isDay:NO isFlag:YES];
        
        NSLog(@"prevCountry: %@, currCountry: %@", prevPlace.country.country, currPlace.country.country);

        VLOSummarySegment *segment = [self createSegmentFromNthMarker:_markers.count-2];
        [segment setSegmentImageLong:@"line-long" middle:@"line-middle" shortt:@"line-short" curve:@"line-curve"];
        if (log.type == VLOLogTypeRoute) {
//            [segment setSegmentIconImage:[VLORouteLog imageNameOf:transportType]];
                 if (segment.curved  && segment.leftToRight)  [segment setSegmentIconImage:@"curve-line-icon-left"];
            else if (!segment.curved && !segment.leftToRight) [segment setSegmentIconImage:@"line-icon-right-sample01"];
            else if (segment.curved  && !segment.leftToRight) [segment setSegmentIconImage:@"curve-line-icon-right"];
            else                                              [segment setSegmentIconImage:@"line-icon-left-sample01"];
        }
        [_segments addObject:segment];
        
    } else { // 첫 마커.
        _travel.hasDate && day != nil ?
            [marker setMarkerImage:@"marker_day" isDay:YES isFlag:NO] :
            [marker setMarkerImage:@"marker_flag_cn" isDay:NO  isFlag:YES];
    }
    
    // 이 시점에서 플레이스로 마커 아이콘 넣을지 체크해서 셋 하면 됨.
    [marker setMarkerIconImage:@"marker-icon-sample01"];
    
    return YES;
}

- (VLOSummaryMarker *) createMarkerFromLog:(VLOLog *)log andPlace:(VLOPlace *)place {
    
    VLOSummaryMarker *marker = [[VLOSummaryMarker alloc] initWithLog:log andPlace:place];
    return marker;
}

- (VLOSummarySegment *) createSegmentFromNthMarker:(NSInteger)markerIndex {
    
    VLOSummaryMarker *fromMarker = [_markers objectAtIndex:markerIndex];
    VLOSummaryMarker *toMarker = [_markers objectAtIndex:markerIndex+1];
    
    VLOSummarySegment *segment = [[VLOSummarySegment alloc] initFrom:fromMarker to:toMarker];
    
    NSInteger row = markerIndex / MARKERS_PER_LINE;
    
    BOOL oddLine = row % 2 == 0; // 0번째 줄 부터 시작하기 때문에 lineNum이 짝수일 때 홀수 줄이다.
    BOOL curved  = markerIndex % MARKERS_PER_LINE == MARKERS_PER_LINE - 1;
    
    segment.curved = curved;
    segment.leftToRight = (oddLine && !curved) || (!oddLine && curved);
    
    return segment;
}

- (void) setMarkerCoordinates {
    
    CGFloat columnWidth = LONG_SEGMENT;
    CGFloat rowChangeXdiff = MIDDLE_SEGMENT - SHORT_SEGMENT;
    CGFloat firstMarkerY = BACKGROUND_HEIGHT;
    CGFloat firstMarkerX;
    
    switch (_markers.count) {
        case (1): firstMarkerX = _summaryWidth / 2.0;                     break;
        case (2): firstMarkerX = _summaryWidth / 2.0 - columnWidth / 2.0; break;
        default : firstMarkerX = CURVE_WIDTH + SHORT_SEGMENT + 5;         break;
    }
    
    for (NSInteger i = 0; i < _markers.count; i++) {
        
        NSInteger row = i / MARKERS_PER_LINE;
        NSInteger col = i % MARKERS_PER_LINE;
        
        BOOL oddLine = row % 2 == 0; // 0번째 줄 부터 시작하기 때문에 lineNum이 짝수일 때 홀수 줄이다.
        
        CGFloat newX;
        if (oddLine) newX = firstMarkerX + col * columnWidth;
        else         newX = firstMarkerX + (MARKERS_PER_LINE - col - 1) * columnWidth;
        CGFloat newY = firstMarkerY + row * LINE_GAP;
        
        if (!oddLine) newX += rowChangeXdiff;
        
        VLOSummaryMarker *marker = [_markers objectAtIndex:i];
        
        marker.x = newX;
        marker.y = newY;
       
        if (i > 0) [[_segments objectAtIndex:i-1] updateMarkerPositions];
    }
}

- (void) initializeBackgroundView {
    UIImage *backgroundImage = [UIImage imageNamed:@"background-1"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.frame = CGRectMake(0, 0, BACKGROUND_WIDTH, BACKGROUND_HEIGHT);
    [_drawables addObject:backgroundImageView];
}

- (void) initializeDrawables {
    
    [self initializeBackgroundView];
    
    for (VLOSummarySegment *segment in _segments) {
        [_drawables addObject:[segment getDrawableView]];
    }
    
    for (VLOSummaryMarker *marker in _markers) {
        [_drawables addObject:[marker getDrawableView]];
    }
}

@end
