//  VLOCoordinateConverter.m


#import "VLOCoordinateConverter.h"

@interface VLOCoordinateConverter()

@property (strong, nonatomic) NSMutableArray *distanceList;

@property () CGFloat actualWidth;
@property () CGFloat distanceSum;
@property () BOOL tooManyMarkers;
@property () NSInteger diff;

@end

@implementation VLOCoordinateConverter

- (id) init {
    self = [super init];
    _actualWidth = [VLOUtilities screenWidth] - HORIZONTAL_PADDING * 2;
    _tooManyMarkers = FALSE;
    return self;
}

- (NSArray *) getCoordinates:(NSArray *)originalPlaceList {
    
    if (originalPlaceList.count < 1) {
        return [NSArray array];
    }
    
    
    // 연속으로 중복되거나 불량한 인풋을 정리하고, 군집된 로케이션 더 큰 범위로 묶습니다.
    NSArray *placeList = [[NSArray alloc] initWithArray:originalPlaceList copyItems:YES];
    placeList = [self sanitizeInput:placeList];
    
    // 각 마커의 x 좌표를 설정하기 위해 경도 분포를 확인합니다.
    [self initDistanceList:placeList];
    
    // 첫 VLOMarker의 좌표.
    CGFloat leftover = _actualWidth - @(MIN_DIST).intValue * (placeList.count - 1);
    CGFloat xVariation = (placeList.count == 1) ? 0 : leftover / 5.0;
    CGFloat leftmostX = @(MIN_DIST).intValue * (placeList.count - 1) / 2 ;
    CGFloat adjustedLeftMostX = [VLOUtilities screenWidth] / 2 - leftmostX - xVariation;
    
    // VLOMarker 생성.
    NSMutableArray *markerList = [[NSMutableArray alloc] initWithCapacity:originalPlaceList.count];
    CGFloat newX = adjustedLeftMostX;
    NSInteger up = -1;
    
    for (NSInteger i = 0; i < placeList.count; i++) {
        
        VLOPlace *place = [placeList objectAtIndex:i];
        
        VLOMarker *newMarker = [[VLOMarker alloc] init];
        
        if (i > 0) {
            if (i > (placeList.count / 2) && i < (placeList.count / 2) + _diff) {
                continue;
            }
            CGFloat horizontalVariation = xVariation * ([[_distanceList objectAtIndex:i-1] floatValue] / _distanceSum);
            newX += MIN_DIST + horizontalVariation;
            
        }
        
        newMarker.x = newX;
        newMarker.y = SUMMARY_HEIGHT / 2 + up * Y_VARIATION;
        newMarker.name = place.name;
        newMarker.nameAbove = YES;
        
        if (i == placeList.count / 2) {
            newMarker.isVisible = FALSE;
        }
        else {
            newMarker.isVisible = TRUE;
        }
        
        
        up *= -1;
        
        [markerList addObject:newMarker];
    }
    
    return markerList;
}

- (NSArray *) sanitizeInput:(NSArray *)placeList {
    
    NSMutableIndexSet *indicesToRemove = [NSMutableIndexSet indexSet];
    
    NSInteger maxMarkers = @(_actualWidth).intValue / @(MIN_DIST).intValue + 1;
    
    for (NSInteger i = 1; i < placeList.count; i++) {
        
        VLOPlace *prevPlace = [placeList objectAtIndex:i-1];
        VLOPlace *currPlace = [placeList objectAtIndex:i];
        
        BOOL sameLat = prevPlace.coordinates.latitude.floatValue == currPlace.coordinates.latitude.floatValue;
        BOOL sameLong = prevPlace.coordinates.longitude.floatValue == currPlace.coordinates.longitude.floatValue;
        
        // 중복되는 마커 제거. 중복되는 기준은 같은 coordinate.
        if (sameLat & sameLong) {
            [indicesToRemove addIndex:i];
        }
        
        // 군집 제거.
        /* BOOL tooManyMarkers = placeList.count - indicesToRemove.count > maxMarkers;
         
         if (tooManyMarkers) {
         //[self reducePlaceList:placeList :i :indicesToRemove];
         //_crowded_cnt = maxMarkers - (placeList.count - indicesToRemove.count);
         }*/
    }
    
    NSMutableArray *newPlaceList = [placeList mutableCopy];
    [newPlaceList removeObjectsAtIndexes:indicesToRemove];
    
    /*if (newPlaceList.count > maxMarkers) {
     newPlaceList = (NSMutableArray *)[newPlaceList subarrayWithRange:(NSRange){0, maxMarkers}];
     }*/
    
    if(newPlaceList.count > maxMarkers)
    {
        _tooManyMarkers = TRUE;
        _diff = newPlaceList.count - maxMarkers;
    }
    
    
    return newPlaceList;
}

- (void) reducePlaceList:(NSArray *)placeList :(NSInteger)index :(NSMutableIndexSet *)indicesToRemove {
    
    for (NSInteger i = index; i < placeList.count; i++) {
        
        VLOCountry *prevCountry = ((VLOPlace *)[placeList objectAtIndex:i-1]).country;
        VLOCountry *currCountry = ((VLOPlace *)[placeList objectAtIndex:i]).country;
        
        BOOL sameCountry = [prevCountry.isoCountryCode isEqualToString:currCountry.isoCountryCode];
        
        if (!sameCountry) break;
        
        ((VLOPlace *)[placeList objectAtIndex:i-1]).name = prevCountry.country;
        [indicesToRemove addIndex:i];
        
    }
}

- (void) initDistanceList:(NSArray *)placeList {
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









