//  VLOCoordinateConverter.m


#import "VLOCoordinateConverter.h"

@interface VLOCoordinateConverter()

@property (strong, nonatomic) NSMutableArray *distanceList;

@property () CGFloat actualWidth;
@property () CGFloat summaryWidth;
@property () CGFloat summaryHeight;
@property () CGFloat distanceSum;
@property () NSInteger maxMarkers;
@property () NSInteger markerNum;

@end

@implementation VLOCoordinateConverter

- (id) initWithWidth:(CGFloat)width andHeight:(CGFloat)height {
    self = [super init];
    _summaryWidth = width;
    _summaryHeight = height;
    _actualWidth = _summaryWidth - HORIZONTAL_PADDING * 2;
    _maxMarkers = @(_actualWidth).intValue / @(MIN_DIST).intValue + 1;
    return self;
}

- (NSArray *) getCoordinates:(NSArray *)originalPlaceList {
    
    if (originalPlaceList.count < 1) {
        return [NSArray array];
    }
    
    // 연속으로 중복되거나 불량한 인풋을 정리하고, 군집된 로케이션 더 큰 범위로 묶습니다.
    NSArray *placeList = [self sanitizeInput:originalPlaceList];
    
    BOOL tooManyMarkers = placeList.count > _maxMarkers;
    
    // 각 마커의 x 좌표를 설정하기 위해 경도 분포를 확인합니다.
    [self initDistanceList:placeList tooMany:tooManyMarkers];
    
    // 첫 VLOMarker의 좌표.
    CGFloat leftover = _actualWidth - @(MIN_DIST).intValue * (_markerNum - 1);
    CGFloat xVariation = (placeList.count == 1) ? 0 : leftover / 5.0;
    CGFloat leftmostX = @(MIN_DIST).intValue * (_markerNum - 1) / 2 ;
    CGFloat adjustedLeftMostX = [VLOUtilities screenWidth]/2 - leftmostX - xVariation;

    // VLOMarker 생성.
    NSMutableArray *markerList = [[NSMutableArray alloc] initWithCapacity:_markerNum];
    CGFloat newX = adjustedLeftMostX;
    NSInteger up = -1;

    for (NSInteger i = 0; i < placeList.count; i++) {
        
        // 마커가 너무 많을 때 중간 마커를 생략한다.
        if (tooManyMarkers) {
            
            // 마커를 생략해야 할 때 점선의 왼쪽과 오른쪽 마커의 개수.
            NSInteger markersOnLeft = _maxMarkers/2;
            NSInteger markersOnRight = (_maxMarkers % 2 == 0) ? _maxMarkers/2 : _maxMarkers/2 + 1;
            
            BOOL omitThisIndex = i >= markersOnLeft && i < (placeList.count - markersOnRight);
            
            if (omitThisIndex) continue;
        }
        
        VLOPlace *place = [placeList objectAtIndex:i];
        VLOMarker *newMarker = [[VLOMarker alloc] init];
        
        if (i > 0) {
            CGFloat horizontalVariation = xVariation * ([[_distanceList objectAtIndex:i-1] floatValue] / _distanceSum);
            newX += MIN_DIST + horizontalVariation;
        }
        
        newMarker.x = newX;
        newMarker.y = _summaryHeight / 2 + up * Y_VARIATION;
        newMarker.name = place.name;
        newMarker.nameAbove = YES;
        newMarker.dottedLine = tooManyMarkers && (i == _maxMarkers/2 - 1);

        up *= -1;
        
        [markerList addObject:newMarker];
    }
    
    return markerList;
}

- (NSArray *) sanitizeInput:(NSArray *)placeList {
    
    NSMutableArray *newPlaceList = [[NSMutableArray alloc] initWithArray:placeList copyItems:YES];

    for (NSInteger i = 1; i < placeList.count; i++) {
        
        VLOPlace *prevPlace = [placeList objectAtIndex:i-1];
        VLOPlace *currPlace = [placeList objectAtIndex:i];
        
        BOOL sameLat = prevPlace.coordinates.latitude.floatValue == currPlace.coordinates.latitude.floatValue;
        BOOL sameLong = prevPlace.coordinates.longitude.floatValue == currPlace.coordinates.longitude.floatValue;
        
        // 중복되는 마커 제거. 중복되는 기준은 같은 coordinate.
        if (sameLat & sameLong) {
            [newPlaceList removeObject:currPlace];
        }
    }
    
    return newPlaceList;
}

- (void) initDistanceList:(NSArray *)placeList tooMany:(BOOL)tooManyMarkers {
    _distanceList = [[NSMutableArray alloc] initWithCapacity:placeList.count-1];
    _distanceSum = 0;
    _markerNum = 0;
    
    for (NSInteger i = 1; i < placeList.count; i++) {
        
        VLOPlace *prevPlace = [placeList objectAtIndex:i-1];
        VLOPlace *currPlace = [placeList objectAtIndex:i];
        
        if (tooManyMarkers) {
            
            // 마커를 생략해야 할 때 점선의 왼쪽과 오른쪽 마커의 개수.
            NSInteger markersOnLeft = _maxMarkers/2;
            NSInteger markersOnRight = (_maxMarkers % 2 == 0) ? _maxMarkers/2 : _maxMarkers/2 + 1;
            
            BOOL omitThisIndex = i >= markersOnLeft && i < (placeList.count - markersOnRight);
            
            if (omitThisIndex) {
                [_distanceList addObject: @(0)];
                continue;
            }
            
            // 생략 점선 이후 그려지는 첫 마커.
            else if (i == placeList.count - markersOnRight) {
                prevPlace = [placeList objectAtIndex:_maxMarkers/2 - 1];
                CGFloat distance = [self distance:prevPlace:currPlace];
                _distanceSum += distance;
                [_distanceList addObject: @(distance)];
                _markerNum += 1;
                continue;
            }
        }
        
        CGFloat distance = [self distance:prevPlace:currPlace];
        _distanceSum += distance;
        [_distanceList addObject: @(distance)];
        _markerNum += 1;
    }
    
}

- (CGFloat) distance:(VLOPlace *)from :(VLOPlace *)to {
    
    CGFloat latitudeDiff = [to.coordinates.latitude floatValue] - [from.coordinates.latitude floatValue];
    CGFloat longitudeDiff = [to.coordinates.longitude floatValue] - [from.coordinates.longitude floatValue];
    
    return sqrt(pow(latitudeDiff,2) + pow(longitudeDiff,2));
}


@end









