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

@interface VLOSummaryViewController() <UIScrollViewDelegate>

@property (strong, nonatomic) VLOTravel *travel;
@property (strong, nonatomic) NSArray *logList;

@property (strong, nonatomic) VLOSummaryTheme *theme;

@property (strong, nonatomic) NSMutableArray *markers;
@property (strong, nonatomic) NSMutableArray *segments;
@property (strong, nonatomic) NSMutableArray *drawables;

@property (strong, nonatomic) NSArray *poiIcons;
@property (strong, nonatomic) NSString *lastCountryCode;

@property () UIScrollView *summaryView;
@property () UIView *dimView;

@property () UIView   *menuBar;
@property () UIButton *backButton;
@property () UIButton *shareButton;


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
 
    return self;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    // 타임라인 딤 처리하는 뷰.
    _dimView = [[UIView alloc] initWithFrame:self.view.bounds];
    _dimView.alpha = 0.3;
    [_dimView setBackgroundColor:[UIColor vlo_darkGrayColor]];
    
    // 서머리가 담길 뷰.
    _summaryView  = [[UIScrollView alloc] init];
    _summaryView.delegate = self;
    _summaryView.transform = CGAffineTransformMakeScale(SHRINK_RATIO, SHRINK_RATIO);
    _summaryView.layer.cornerRadius = 10;
    _summaryView.layer.masksToBounds = YES;
    [_summaryView setBackgroundColor:[UIColor whiteColor]];
    
    // 닫기, 쉐어 버튼이 담긴 상단의 메뉴 바. share시 summaryView만 캡쳐하기 위해 버튼을 메뉴 바로 분리함.
    _menuBar = [[UIView alloc] init];
    _menuBar.transform = CGAffineTransformMakeScale(SHRINK_RATIO, SHRINK_RATIO);
    
    _backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_backButton setImage:[UIImage imageNamed:@"TimePickerCancel"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(didSelectBackButton) forControlEvents:UIControlEventTouchUpInside];
    
    _shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_shareButton setImage:[UIImage imageNamed:@"TimelineShareButton"] forState:UIControlStateNormal];
    [_shareButton addTarget:self action:@selector(didSelectShareButton) forControlEvents:UIControlEventTouchUpInside];
    
    [_menuBar addSubview:_backButton];
    [_menuBar addSubview:_shareButton];

    [self.view addSubview:_dimView];
    [self.view addSubview:_summaryView];
    [self.view addSubview:_menuBar];
    [self makeAutoLayoutConstraints];
    
    [self drawSummary];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
}

- (void) makeAutoLayoutConstraints
{
    
    [_summaryView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat width  = [VLOUtilities screenWidth];
        CGFloat height = [VLOUtilities screenHeight];
        
        make.left.equalTo(@(0.0f));
        make.top.equalTo(@(0.0f));
        make.width.equalTo(@(width));
        make.height.equalTo(@(height));
    }];
    
    [_menuBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_summaryView);
        make.top.equalTo(@([VLOUtilities screenHeight]* (1-SHRINK_RATIO)/2.0));
        make.width.equalTo(_summaryView);
        make.height.equalTo(@(BUTTON_SIZE));
    }];
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0.0f));
        make.top.equalTo(@(0.0f));
        make.width.equalTo(@(BUTTON_SIZE));
        make.height.equalTo(@(BUTTON_SIZE));
    }];
    
    [_shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@([VLOUtilities screenWidth] - BUTTON_SIZE));
        make.top.equalTo(@(0.0f));
        make.width.equalTo(@(BUTTON_SIZE));
        make.height.equalTo(@(BUTTON_SIZE));
    }];
}

- (void) makeMenuBar {
    
}

- (void) setTheme:(VLOSummaryTheme *)theme {
    _theme = theme;
}

// 필요시 이 함수만 부를 수 있도록 분리함.
- (void) drawSummary {
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [self parseLogList:_logList];
    [self setMarkerCoordinates];
    
    [self initializeDrawables];
    
    for (UIView *drawable in _drawables) {
        [_summaryView addSubview:drawable];
        
        if (drawable == [_drawables lastObject]) {
            CGFloat contentHeight =
                drawable.frame.origin.y + drawable.frame.size.height + CONTENT_SIZE_PAD;
            _summaryView.contentSize = CGSizeMake([VLOUtilities screenWidth], contentHeight);
        }
    }
}

- (void) parseLogList: (NSArray *)logList {
    
    NSInteger GMTOffset = [_travel.timezone getNSTimezone].secondsFromGMT;
    NSInteger logIndex = 0;
    [_theme shuffleIndex:logList.count];
    
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
 
        NSString *longSeg  = [_theme getLongSeg:logIndex-1];
        NSString *medSeg   = [_theme getMedSeg:logIndex-1];
        NSString *shortSeg = [_theme getShortSeg:logIndex-1];
        NSString *curveSeg = [_theme getCurveSeg:logIndex-1];
        
        [segment setSegmentImageLong:longSeg middle:medSeg shortt:shortSeg curve:curveSeg];
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

// 마커의 coordinate은 validity check를 통과한 로그가 몇개인지 안 후에야 정할 수 있다.
- (void) setMarkerCoordinates {
    
    CGFloat columnWidth = LONG_SEGMENT;
    CGFloat rowChangeXdiff = MIDDLE_SEGMENT - SHORT_SEGMENT;
    CGFloat firstMarkerY = BACKGROUND_HEIGHT;
    CGFloat firstMarkerX;
    CGFloat summaryWidth = _summaryView.frame.size.width;
    
    switch (_markers.count) {
        case (1): firstMarkerX = summaryWidth / 2.0;                     break;
        case (2): firstMarkerX = summaryWidth / 2.0 - columnWidth / 2.0; break;
        default : firstMarkerX = CURVE_WIDTH + SHORT_SEGMENT + 5;        break;
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
    else markerImage = _theme.markerImage;
    
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


- (void) initializeDrawables {
    
    [self initializeBackgroundView];
    [self initializeTitleView];
    
    for (VLOSummarySegment *segment in _segments) {
        [_drawables addObject:[segment getDrawableView]];
        
        /*
         
         레이어별로 그리고 싶을 때.

        [_drawables addObject:[segment getSegmentView]];
        [_drawables addObject:[segment getSegmentIconView]];
         
        */
    }
    
    for (VLOSummaryMarker *marker in _markers) {
        UIButton *markerDrawable = [marker getDrawableView];
        markerDrawable.tag = marker.logIndex;
        [_drawables addObject:markerDrawable];
        
        [markerDrawable addTarget:self action:@selector(didClickMarker:) forControlEvents:UIControlEventTouchUpInside];
        [markerDrawable addTarget:self action:@selector(willClickMarker:) forControlEvents:UIControlEventTouchDown];
        
        /*
         
        레이어별로 그리고 싶을 때.
         
        (현재 구조에선 교통수단 아이콘과 마커가 겹치지 않아서, 마커가 마커 아이콘 위에 오기만 하면 레이어별로 그리는 메리트가 없음
         + 레이어별로 그리면 for loop 더 많이 돌려야 함 + 마커와 관련된 요소만 새로운 UI버튼으로 묶어야 함.)

        UIView *markerDrawable = [marker getMarkerView];
        UIView *markerIconDrawable = [marker getMarkerIconView];
        UIView *markerLabelDrawable = [marker getMarkerLabel];
        
        [_drawables addObject:markerIconDrawable];
        [_drawables addObject:markerLabelDrawable];
        [_drawables addObject:markerDrawable];
         
        */
    }
}

- (void) initializeBackgroundView {
    
    UIImage *backgroundImage = [UIImage imageNamed:_theme.backgroundImage];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    
    backgroundImageView.frame = CGRectMake(0, 0, BACKGROUND_WIDTH, BACKGROUND_HEIGHT);
    [_drawables addObject:backgroundImageView];
    
}

- (void) initializeTitleView {
    CGFloat titleWidth = BACKGROUND_WIDTH;
    CGFloat titleTop  = BACKGROUND_HEIGHT/2.0 - TITLE_HEIGHT;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleTop, titleWidth, TITLE_HEIGHT)];
    titleLabel.text = _travel.title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel setFont:[UIFont systemFontOfSize:TITLE_HEIGHT]];
    
    [_drawables addObject:titleLabel];
}


#pragma mark - 타임라인 스크롤

- (void) didClickMarker:(id)sender {

    if ([_delegate respondsToSelector:@selector(scrollToLog:)]) {
        [_delegate scrollToLog:((UIButton *)sender).tag];
    }
}

// 버튼 딤처리.
- (void) willClickMarker:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(scrollToLog:)]) {
        
    }
}


#pragma mark - buttons up top

- (void) didSelectBackButton {
    if ([_delegate respondsToSelector:@selector(summaryControllerClosed:)]) {
        [_delegate summaryControllerClosed:self];
    }
}
    
- (void) didSelectShareButton {
    if([_delegate respondsToSelector:@selector(summaryShareSelected:)]) {
        [_delegate summaryShareSelected:self];
    }

}


# pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        [scrollView setScrollEnabled:NO];
        [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        [scrollView setScrollEnabled:YES];
    }
    
    
    CGFloat menuBarLeft = _menuBar.frame.origin.x;
    CGFloat menuBarTop = scrollView.contentOffset.y;
    
    //_menuBar.frame = CGRectMake(menuBarLeft, menuBarTop, BUTTON_SIZE, BUTTON_SIZE);
    
}
    
@end
