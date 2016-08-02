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
    
    [self parseLogList:logList];
    
    return self;
}

- (void) parseLogList:(NSArray *)logList {
    
    /* 데모용 */
    
    VLOSummaryMarker *marker1 = [[VLOSummaryMarker alloc] init];
    NSString *name1 = @"뉴욕";
    marker1.x = 50;
    marker1.y = 100;
    marker1.name = name1;
    marker1.color = VOLO_COLOR;
    marker1.country = [[VLOCountry alloc] initWithCode:name1 country:name1];
    marker1.day = 0;
    marker1.hasMarkerContent = YES;
    [marker1 setMarkerContentImage:@"78_KR"];
    
    VLOSummaryMarker *marker2 = [[VLOSummaryMarker alloc] init];
    NSString *name2 = @"보스턴";
    marker2.x = 130;
    marker2.y = 100;
    marker2.name = name2;
    marker2.color = VOLO_COLOR;
    marker2.country = [[VLOCountry alloc] initWithCode:name2 country:name2];
    marker2.day = @2;
    marker2.hasMarkerContent = YES;
    
    VLOSummaryMarker *marker3 = [[VLOSummaryMarker alloc] init];
    NSString *name3 = @"서울";
    marker3.x = 210;
    marker3.y = 100;
    marker3.name = name3;
    marker3.color = VOLO_COLOR;
    marker3.country = [[VLOCountry alloc] initWithCode:name3 country:name3];
    marker3.day = @1;
    marker3.hasMarkerContent = NO;
    
    VLOSummaryMarker *marker4 = [[VLOSummaryMarker alloc] init];
    NSString *name4 = @"방콕";
    marker4.x = 250;
    marker4.y = 200;
    marker4.name = name4;
    marker4.color = VOLO_COLOR;
    marker4.country = [[VLOCountry alloc] initWithCode:name4 country:name4];
    marker4.day = @1;
    marker4.hasMarkerContent = YES;
    
    VLOSummaryMarker *marker5 = [[VLOSummaryMarker alloc] init];
    NSString *name5 = @"바그다드";
    marker5.x = 180;
    marker5.y = 200;
    marker5.name = name4;
    marker5.color = VOLO_COLOR;
    marker5.country = [[VLOCountry alloc] initWithCode:name5 country:name5];
    marker5.day = @1;
    marker5.hasMarkerContent = YES;
    [marker5 setMarkerContentImage:@"78_DE"];
    
    VLOSummaryMarker *marker6 = [[VLOSummaryMarker alloc] init];
    NSString *name6 = @"시드니";
    marker6.x = 110;
    marker6.y = 200;
    marker6.name = name6;
    marker6.color = VOLO_COLOR;
    marker6.country = [[VLOCountry alloc] initWithCode:name6 country:name6];
    marker6.day = @1;
    marker6.hasMarkerContent = YES;
    
    VLOSummaryMarker *marker7 = [[VLOSummaryMarker alloc] init];
    NSString *name7 = @"피츠버그";
    marker7.x = 80;
    marker7.y = 300;
    marker7.name = name7;
    marker7.color = VOLO_COLOR;
    marker7.country = [[VLOCountry alloc] initWithCode:name7 country:name7];
    marker7.day = @1;
    marker7.hasMarkerContent = YES;
    
    VLOSummarySegment *segment1 = [[VLOSummarySegment alloc] initFrom:marker1 to:marker2];
    segment1.leftToRight = YES;
    segment1.curved = NO;
    segment1.hasSegmentContent = YES;
    
    VLOSummarySegment *segment2 = [[VLOSummarySegment alloc] initFrom:marker2 to:marker3];
    segment2.leftToRight = YES;
    segment2.curved = NO;
    segment2.hasSegmentContent = YES;
    [segment2 setSegmentContentImage:@"train"];
    
    VLOSummarySegment *segment3 = [[VLOSummarySegment alloc] initFrom:marker3 to:marker4];
    segment3.leftToRight = YES;
    segment3.curved = YES;
    segment3.hasSegmentContent = YES;
    [segment3 setSegmentContentImage:@"tram"];
    
    VLOSummarySegment *segment4 = [[VLOSummarySegment alloc] initFrom:marker4 to:marker5];
    segment4.leftToRight = NO;
    segment4.curved = NO;
    segment4.hasSegmentContent = YES;
    
    VLOSummarySegment *segment5 = [[VLOSummarySegment alloc] initFrom:marker5 to:marker6];
    segment5.leftToRight = NO;
    segment5.curved = NO;
    segment5.hasSegmentContent = YES;
    
    VLOSummarySegment *segment6 = [[VLOSummarySegment alloc] initFrom:marker6 to:marker7];
    segment6.leftToRight = NO;
    segment6.curved = YES;
    segment6.hasSegmentContent = YES;
    [segment6 setSegmentContentImage:@"plane"];
    
    // 마커를 나중에 그림.
    [_drawables addObject:[segment1 getDrawableView]];
    [_drawables addObject:[segment2 getDrawableView]];
    [_drawables addObject:[segment3 getDrawableView]];
    [_drawables addObject:[segment4 getDrawableView]];
    [_drawables addObject:[segment5 getDrawableView]];
    [_drawables addObject:[segment6 getDrawableView]];
    [_drawables addObject:[marker1 getDrawableView]];
    [_drawables addObject:[marker2 getDrawableView]];
    [_drawables addObject:[marker3 getDrawableView]];
    [_drawables addObject:[marker4 getDrawableView]];
    [_drawables addObject:[marker5 getDrawableView]];
    [_drawables addObject:[marker6 getDrawableView]];
    [_drawables addObject:[marker7 getDrawableView]];
   
}

- (void) drawSummary {
    for (UIView *drawable in _drawables) {
        [_summaryView addSubview:drawable];
    }
}

@end
