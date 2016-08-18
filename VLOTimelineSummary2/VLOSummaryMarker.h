//
//  VLOSummaryMarker.h
//  Volo
//
//  Created by Seongmin on 7/29/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIkit/UIkit.h>
#import "VLOLog.h"
#import "VLOPlace.h"
#import "VLOUtilities.h"
#import "UIColor+VLOExtension.h"

// 마커
#define MARKERS_PER_LINE       3                                   // 각 row의 마커 개수.
#define MARKER_SIZE          5.0 * [VLOUtilities screenRatioWith6] // 마커를 직접 그릴 때 마커 원 지름.
#define MARKER_IMAGE_SIZE   20.0 * [VLOUtilities screenRatioWith6] // 마커가 이미지일 때 정사각형 이미지 크기.
#define MARKER_FLAG_SIZE    18.0 * [VLOUtilities screenRatioWith6] // 마커가 국기일 때 국기 지름.
#define DAY_LABEL_HEIGHT    12.0 * [VLOUtilities screenRatioWith6] // 마커가 "몇 일차"일 때, 마커 세로 길이.
#define DAY_LABEL_PADDING    5.0 * [VLOUtilities screenRatioWith6] // 마커가 "몇 일차"일 때, 네모난 마커와 속의 텍스트 양 옆의 마진.

// 마커 아이콘 (서울타워, 뉴욕 등)
#define MARKER_ICON_WIDTH   60.0 * [VLOUtilities screenRatioWith6] // 마커 아이콘 가로 길이.
#define MARKER_ICON_HEIGHT  67.0 * [VLOUtilities screenRatioWith6] // 마커 아이콘 세로 길이.

// 마커 레이블
#define MARKER_LABEL_HEIGHT 10.0 * [VLOUtilities screenRatioWith6] // 마커 레이블 세로 길이.

// 선
#define LINE_WIDTH           3.0 * [VLOUtilities screenRatioWith6] // 직접 선을 그릴 때 선의 두께.
#define SEGMENT_HEIGHT      50.0 * [VLOUtilities screenRatioWith6] // 선이 이미지일 때,이미지의 세로 길이.
#define SEGMENT_OFFSET      10.0 * [VLOUtilities screenRatioWith6] // 선 이미지 하단에서 실제 선 까지의 거리.
#define LONG_SEGMENT       100.0 * [VLOUtilities screenRatioWith6] // 긴 선 이미지 길이.
#define MIDDLE_SEGMENT      30.0 * [VLOUtilities screenRatioWith6] // 중간 선 이미지 길이.
#define SHORT_SEGMENT       20.0 * [VLOUtilities screenRatioWith6] // 짧은 선 이미지 길이.
#define CURVE_WIDTH         58.0 * [VLOUtilities screenRatioWith6] // 곡선 가로 길이. (세로 길이는 LINE_GAP과 같다.)
#define LINE_GAP            80.0 * [VLOUtilities screenRatioWith6] // 선이 바뀔 때 변하는 y값.

// 선 아이콘 (교통수단 등)
#define SEGMENT_ICON_SIZE   45.0 * [VLOUtilities screenRatioWith6] // 정사각형인 선 아이콘 이미지 한 변의 길이.

// 배경
#define BACKGROUND_WIDTH   375.0 * [VLOUtilities screenRatioWith6] // 배경 가로 길이. ScreenWidth와 같다.
#define BACKGROUND_HEIGHT  150.0 * [VLOUtilities screenRatioWith6] // 배경 최소 세로 길이. 이 높이에서 첫 번째 마커가 시작된다.
#define TITLE_HEIGHT        26.0 * [VLOUtilities screenRatioWith6] // 여행기 제목 텍스트 세로 높이.

#define CONTENT_SIZE_PAD   100.0 * [VLOUtilities screenRatioWith6] // 스크롤뷰(_summaryView) 최하단 마커의 레이블 밑에 더해주는 패딩.
#define SHRINK_RATIO         0.9                                   // _summaryView가 화면을 채우면 모달 느낌이 나지 않기 때문에 shrink 하는 비율.
#define BUTTON_SIZE         30.0 * [VLOUtilities screenRatioWith6] // 상단 메뉴 버튼(close, share) 사이즈.

#define PROXIMITY_RADIUS     0.1                                   // 마커가 POI 속인지 판별하는 과정에서 쓰이는 반경.

#define VOLO_COLOR          [UIColor colorWithRed:200/255.0 green:240/255.0 blue:235/255.0 alpha:1]
#define LINE_COLOR          [UIColor colorWithRed:211/255.0 green:213/255.0 blue:212/255.0 alpha:1]


@interface VLOSummaryMarker : NSObject

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) NSNumber *day;
@property (nonatomic) NSInteger logIndex;

@property () BOOL hasMarkerIcon;
@property () NSString *iconImageName;

- (id) initWithLog:(VLOLog *)log andPlace:(VLOPlace *)place;
- (void) setMarkerImage:(NSString *)markerImageName isDay:(BOOL)isDay isFlag:(BOOL)isFlag;
- (void) setMarkerIconImage:(NSString *)iconImageName;

- (UIButton *) getDrawableView;
- (UIView *) getMarkerView;
- (UIView *) getMarkerIconView;
- (UIView *) getMarkerLabel;

- (VLOPlace *) getPlace;

@end


