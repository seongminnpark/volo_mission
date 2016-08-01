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
    NSString *name1 = @"dssdd";
    marker1.x = 50;
    marker1.y = 100;
    marker1.name = name1;
    marker1.color = [UIColor lightGrayColor];
    marker1.country = [[VLOCountry alloc] initWithCode:name1 country:name1];
    marker1.day = 0;
    marker1.hasMarkerContent = YES;
    
    VLOSummaryMarker *marker2 = [[VLOSummaryMarker alloc] init];
    NSString *name2 = @"dssddd";
    marker2.x = 150;
    marker2.y = 100;
    marker2.name = name2;
    marker2.color = [UIColor lightTextColor];
    marker2.country = [[VLOCountry alloc] initWithCode:name2 country:name2];
    marker2.day = @2;
    marker2.hasMarkerContent = YES;
    
    VLOSummaryMarker *marker3 = [[VLOSummaryMarker alloc] init];
    NSString *name3 = @"dssadsdd";
    marker3.x = 250;
    marker3.y = 100;
    marker3.name = name3;
    marker3.color = [UIColor greenColor];
    marker3.country = [[VLOCountry alloc] initWithCode:name3 country:name3];
    marker3.day = @1;
    marker3.hasMarkerContent = NO;
    
    [_drawables addObject:[marker1 getDrawableView]];
    [_drawables addObject:[marker2 getDrawableView]];
    [_drawables addObject:[marker3 getDrawableView]];
    
}

- (void) drawSummary {
    for (UIView *drawable in _drawables) {
        [_summaryView addSubview:drawable];
    }
}

@end
