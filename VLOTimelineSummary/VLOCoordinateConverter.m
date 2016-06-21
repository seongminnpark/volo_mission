//  VLOCoordinateConverter.m


#import "VLOCoordinateConverter.h"

@interface VLOCoordinateConverter()

@property () CGFloat actualHeight;
@property () CGFloat actualWidth;
@property () CGFloat longitudeDiffSum;
@property () CGFloat latitudeMaxDiff;
@property () CGFloat latitudeMax;

@end

@implementation VLOCoordinateConverter

- (id) init {
    self = [super init];
    _actualWidth = [VLOUtilities screenWidth] - MARKER_SIZE * 2;
    _actualHeight = SUMMARY_HEIGHT - VERTICAL_PADDING * 2;
    
    _longitudeDiffSum = 0;
    _latitudeMaxDiff = 0;
    _latitudeMax = 0;
    return self;
}

- (NSArray *) getCoordinates:(NSArray *)originalPlaceList {
    
    if (originalPlaceList.count < 1) {
        return [NSArray array];
    }
    
    NSMutableArray *placeList = [originalPlaceList mutableCopy];
    NSMutableArray *longitudeDiffList = [NSMutableArray arrayWithCapacity:placeList.count - 1];
    NSMutableArray *latitudeList = [[NSMutableArray alloc] initWithCapacity:placeList.count];
    [self initializeLists:placeList :longitudeDiffList :latitudeList];
    
    NSLog(@"countt: %li", placeList.count);
    
    NSMutableArray *markerList = [[NSMutableArray alloc] initWithCapacity:placeList.count];
    
    // First marker
    VLOMarker *firstMarker = [[VLOMarker alloc] init];
    CGFloat latitude = [[latitudeList objectAtIndex:0] floatValue];
    firstMarker.x = (placeList.count == 1) ? _actualWidth/2 + MARKER_SIZE : MARKER_SIZE;
    firstMarker.y = (placeList.count == 1) ? _actualHeight/2 + VERTICAL_PADDING : [self getYCoordinate:latitude];
    firstMarker.name = ((VLOPlace *)[placeList objectAtIndex:0]).name;
    [markerList addObject:firstMarker];
    
    // Every other markers (index 1 < )
    for (NSInteger i = 1; i < placeList.count; i++) {
        
        VLOPlace *currPlace = [placeList objectAtIndex:i];
        
        CGFloat longitudeDiffFromPreviousPlace = [[longitudeDiffList objectAtIndex:i-1] floatValue];
        CGFloat currentLatitude = [[latitudeList objectAtIndex:i] floatValue];
        
        VLOMarker *prevMarker = [markerList objectAtIndex:i-1];
        VLOMarker *newMarker = [[VLOMarker alloc] init];
        
        newMarker.x = [self getXCoordinate:longitudeDiffFromPreviousPlace :prevMarker.x];
        newMarker.y = [self getYCoordinate:currentLatitude];
        newMarker.name = currPlace.name;
        
        [markerList addObject:newMarker];
    }

    return markerList;
}

- (void) initializeLists:(NSMutableArray *)placeList :(NSMutableArray *)longitudeDiffList :(NSMutableArray *)latitudeList {
    
    NSMutableArray *originalPlaceList = [placeList mutableCopy];
    
    for (NSInteger i = 0; i < originalPlaceList.count - 1; i++) {
        
        VLOPlace *currPlace = [originalPlaceList objectAtIndex:i];
        VLOPlace *nextPlace = [originalPlaceList objectAtIndex:i+1];
        
        BOOL sameLong = currPlace.coordinates.longitude.floatValue == nextPlace.coordinates.longitude.floatValue;
        BOOL sameLat = currPlace.coordinates.latitude.floatValue == nextPlace.coordinates.latitude.floatValue;
        BOOL sameName = [currPlace.name isEqualToString:nextPlace.name];

        if (sameLong && sameLat && sameName) {

            // 연속으로 동일한 마커 제거. removeObject 메쏘드는 같은 마커 모두 지움.
            [placeList removeObjectAtIndex:i];

        } else {
            
            // Longitude
            CGFloat longitudeDiff = fabs(nextPlace.coordinates.longitude.floatValue - currPlace.coordinates.longitude.floatValue);
            [longitudeDiffList addObject:[NSNumber numberWithFloat:longitudeDiff]];
            _longitudeDiffSum += longitudeDiff;
            
            // Latitude
            CGFloat latitude = nextPlace.coordinates.latitude.floatValue;
            [latitudeList addObject:[NSNumber numberWithFloat:latitude]];

        }
    }
    
    // Add last latitude.
    VLOPlace *lastPlace = [originalPlaceList lastObject];
    CGFloat lastLatitude = [lastPlace.coordinates.latitude floatValue];
    [latitudeList addObject:[NSNumber numberWithFloat:lastLatitude]];
    
    CGFloat maxLatitude = [[latitudeList valueForKeyPath:@"@max.doubleValue"] floatValue];
    CGFloat minLatitude = [[latitudeList valueForKeyPath:@"@min.doubleValue"] floatValue];
    _latitudeMaxDiff = maxLatitude - minLatitude; // 마커가 하나일 땐 이 값이 0이므로 getYCoordinate애서 분모로 이용하지 않음.
    _latitudeMax = maxLatitude;
}

- (CGFloat) getXCoordinate:(CGFloat)longitudeDiff :(CGFloat)previousX {
    // 모든 마커의 x좌표가 같은 경우 모든 마커는 써머리 뷰 중간에 놓음.
    CGFloat longitudeRatio = (_longitudeDiffSum == 0) ? 0.5 : longitudeDiff / _longitudeDiffSum;
    CGFloat xIncrement = longitudeRatio * _actualWidth;
    CGFloat newX = previousX + xIncrement;
    return newX;
}

- (CGFloat) getYCoordinate:(CGFloat)currentLatutude {
    // 모든 마커의 y좌표가 같은 경우 모든 마커는 써머리 뷰 중간에 놓음.
    CGFloat latitudeRatio = (_latitudeMaxDiff == 0) ? 0.5 : (_latitudeMax - currentLatutude) / _latitudeMaxDiff;
    CGFloat newY = latitudeRatio * _actualHeight + VERTICAL_PADDING;
    return newY;
}

@end





