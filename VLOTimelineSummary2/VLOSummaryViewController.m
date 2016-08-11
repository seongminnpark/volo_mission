//
//  VLOTimelineSummary.m
//  Volo
//
//  Created by Seongmin on 8/1/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import "VLOSummaryViewController.h"
#import "VLOLocalStorage.h"
#import "VLOPoi.h"

@interface VLOSummaryViewController ()

@property (strong, nonatomic) VLOTravel *travel;
@property (strong, nonatomic) NSArray *logList;

@property (strong, nonatomic) NSMutableArray *markers;
@property (strong, nonatomic) NSMutableArray *segments;
@property (strong, nonatomic) NSMutableArray *drawables;

@property (strong, nonatomic) NSArray *poiIcons;
@property (strong, nonatomic) NSString *lastCountryCode;

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
    
    _poiIcons = [VLOLocalStorage getPoiList];

    _summaryWidth = self.view.bounds.size.width;
    _actualWidth = _summaryWidth - (SEGMENT_ICON_SIZE * 2);
    
    [self parseLogList:logList];
    [self setMarkerCoordinates];
    //[self initializeDrawables];
    
    return self;
}

// 테스트용 버튼.
- (void) dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear {
    [super viewDidLoad];
    [self drawSummary];
}

- (void) drawSummary {

    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self initializeDrawables];
    
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
    marker.day = @(day.integerValue + 1);
    marker.logIndex= logIndex;
    [_markers addObject:marker];
    
    [self setMarkerImage:currPlace :prevPlace :_markers.count-1];
    [self setMarkerIconImage:currPlace :prevPlace :_markers.count-1];
    
    if (_markers.count > 1) {
        
        // 세그먼트 생성.
        VLOSummarySegment *segment = [self createSegmentFromNthMarker:_markers.count-2];
        [segment setSegmentImageLong:@"line_a_01" middle:@"line_b_01" shortt:@"line_c_01" curve:@"line_round_left_01"];
        if (log.type == VLOLogTypeRoute) {
            
            NSString *suffix, *transport, *segmentImageName;
            
            if      (!segment.curved  && segment.leftToRight)  suffix = @"01";
            else if (!segment.curved && !segment.leftToRight)  suffix = @"02";
            else if (segment.curved  && !segment.leftToRight)  suffix = @"03";
            else                                               suffix = @"04";
            
            transport = [VLORouteLog imageNameOf:transportType];
            
            segmentImageName = [NSString stringWithFormat:@"icon_transport_%@_%@", transport, suffix];
            
            [segment setSegmentIconImage:segmentImageName];
        }
        
        [_segments addObject:segment];
        
    }
    
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
//        [_drawables addObject:[segment getSegmentView]];
//        [_drawables addObject:[segment getSegmentIconView]];
    }
    
    for (VLOSummaryMarker *marker in _markers) {
        UIButton *markerDrawable = [marker getDrawableView];
        markerDrawable.tag = marker.logIndex;
        [_drawables addObject:markerDrawable];
        if ([_delegate respondsToSelector:@selector(scrollToLog:)]) {
            [markerDrawable addTarget:self action:@selector(callScrollToLog:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void) callScrollToLog:(id)sender {
    [_delegate scrollToLog:((UIButton *)sender).tag];
}


- (void) setMarkerImage:(VLOPlace *)currPlace :(VLOPlace *)prevPlace :(NSInteger)markerIndex {
    
    NSString *markerImage;
    BOOL isDay = NO, isFlag = NO, sameDay = YES, sameCountry = YES;
    BOOL firstMarker  = markerIndex == 0;
    BOOL secondMarker = markerIndex == 1;
    BOOL countryNil   = currPlace.country.country == nil;
    BOOL showCountry  = secondMarker && _travel.hasDate && !countryNil;
    
    VLOSummaryMarker *currMarker = [_markers objectAtIndex:markerIndex];
    
    if (markerIndex > 0) {
        VLOSummaryMarker *prevMarker = [_markers objectAtIndex:markerIndex-1];
        sameDay = _travel.hasDate && prevMarker.day == currMarker.day;
        sameCountry = countryNil || [_lastCountryCode isEqualToString:currPlace.country.isoCountryCode];
    }
    
    isDay  = (firstMarker || !sameDay) && _travel.hasDate;
    isFlag = (firstMarker && !_travel.hasDate) || !sameCountry || showCountry;
    
    if      (isDay)  markerImage = @"marker_day";
    else if (isFlag) {
       markerImage = [NSString stringWithFormat:@"42_%@", currPlace.country.isoCountryCode];
       _lastCountryCode = currPlace.country.isoCountryCode;
    }
    else markerImage = @"icon_poi_marker";
    
    [currMarker setMarkerImage:markerImage isDay:isDay isFlag:isFlag];
}

- (void) setMarkerIconImage:(VLOPlace *)currPlace :(VLOPlace *)prevPlace :(NSInteger)markerIndex {
    
    VLOSummaryMarker *currMarker = [_markers objectAtIndex:markerIndex];
    
    NSString *markerIconImage;
    
    BOOL newCity = NO;
    BOOL hasIcon = NO;
    
    VLOLocationCoordinate *coords = currPlace.coordinates;
    
    for (VLOPoi *poi in _poiIcons) {
        
        VLOLocationCoordinate *poiCoords = poi.coordinates;
        
        hasIcon = [self samePOI:coords :poiCoords];
        if (hasIcon){
            markerIconImage = poi.imageName;
            break;
        }
    }
    
    if (markerIndex > 0) {
        VLOSummaryMarker *prevMarker = [_markers objectAtIndex:markerIndex-1];
        newCity = ![self samePOI:coords :[prevMarker getPlace].coordinates];
    } else {
        newCity = YES;
    }
    
    if (newCity && hasIcon) [currMarker setMarkerIconImage:markerIconImage];
}

// 현재 정해진 도시 좌표에서 반경으로 테스트함. 추후에 폴리곤 로직 추가 해야함.
- (BOOL) samePOI:(VLOLocationCoordinate *)coord1 :(VLOLocationCoordinate *)coord2 {
    
    BOOL withinLongitude = (coord1.longitude.floatValue >= coord2.longitude.floatValue - PROXIMITY_RADIUS) &&
                           (coord1.longitude.floatValue <= coord2.longitude.floatValue + PROXIMITY_RADIUS);
    BOOL withinLatitude  = (coord1.latitude.floatValue  >= coord2.latitude.floatValue  - PROXIMITY_RADIUS) &&
                           (coord1.latitude.floatValue  <= coord2.latitude.floatValue  + PROXIMITY_RADIUS);
    
    return withinLongitude && withinLatitude;
}



@end
