//
//  VLOCoordinateConverter.m
//  Volo
//
//  Created by Seongmin on 6/20/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

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
    _actualHeight = SUMMARY_HEIGHT - MARKER_VERTICAL_OFFSET * 2;
    
    _longitudeDiffSum = 0;
    _latitudeMaxDiff = 0;
    _latitudeMax = 0;
    return self;
}

- (NSArray *) getCoordinates:(NSArray *)placesList {
    if (placesList.count < 1) {
        return [NSArray array];
    }
    
    NSMutableArray *longitudeDiffList = [NSMutableArray arrayWithCapacity:placesList.count - 1];
    NSMutableArray *latitudeList = [[NSMutableArray alloc] initWithCapacity:placesList.count];
    [self initializeLists:placesList :longitudeDiffList :latitudeList];
    
    NSMutableArray *markerList = [[NSMutableArray alloc] initWithCapacity:placesList.count];
    
    // First marker
    Marker *firstMarker = [[Marker alloc] init];
    CGFloat latitude = [[latitudeList objectAtIndex:0] floatValue];
    firstMarker.x = (placesList.count == 1) ? _actualWidth/2 + MARKER_SIZE: MARKER_SIZE;
    firstMarker.y = (placesList.count == 1) ? _actualHeight/2 + MARKER_VERTICAL_OFFSET: [self getYCoordinate:latitude];
    firstMarker.name = ((VLOPlace *)[placesList objectAtIndex:0]).name;
    [markerList addObject:firstMarker];
    
    for (NSInteger i = 1; i < placesList.count; i++) {
        
        VLOPlace *currPlace = [placesList objectAtIndex:i];
        
        CGFloat longitudeDiffFromPreviousPlace = [[longitudeDiffList objectAtIndex:i-1] floatValue];
        CGFloat currentLatitude = [[latitudeList objectAtIndex:i] floatValue];
        
        Marker *prevMarker = [markerList objectAtIndex:i-1];
        Marker *newMarker = [[Marker alloc] init];
        
        newMarker.x = [self getXCoordinate:longitudeDiffFromPreviousPlace :prevMarker.x];
        newMarker.y = [self getYCoordinate:currentLatitude];
        newMarker.name = currPlace.name;
        
        [markerList addObject:newMarker];
    }
    
    return markerList;
}

- (void) initializeLists:(NSArray *)placesList :(NSMutableArray *)longitudeDiffList :(NSMutableArray *)latitudeList {
    
    for (NSInteger i = 0; i < placesList.count - 1; i++) {
        
        VLOPlace *currPlace = [placesList objectAtIndex:i];
        VLOPlace *nextPlace = [placesList objectAtIndex:i+1];
        
        // Longitude
        CGFloat longitudeDiff = fabs([nextPlace.coordinates.longitude floatValue] - [currPlace.coordinates.longitude floatValue]);
        [longitudeDiffList addObject:[NSNumber numberWithFloat:longitudeDiff]];
        _longitudeDiffSum += longitudeDiff;
        
        // Latitude
        CGFloat latitude = [nextPlace.coordinates.latitude floatValue];
        [latitudeList addObject:[NSNumber numberWithFloat:latitude]];
    }
    
    // Add last latitude.
    VLOPlace *lastPlace = [placesList lastObject];
    CGFloat lastLatitude = [lastPlace.coordinates.latitude floatValue];
    [latitudeList addObject:[NSNumber numberWithFloat:lastLatitude]];
    
    CGFloat maxLatitude = [[latitudeList valueForKeyPath:@"@max.doubleValue"] floatValue];
    CGFloat minLatitude = [[latitudeList valueForKeyPath:@"@min.doubleValue"] floatValue];
    _latitudeMaxDiff = maxLatitude - minLatitude; // 마커가 하나일 땐 이 값이 0이므로 getYCoordinate애서 분모로 이용하지 않음.
    _latitudeMax = maxLatitude;
}

- (CGFloat) getXCoordinate:(CGFloat)longitudeDiff :(CGFloat)previousX {
    CGFloat longitudeRatio = longitudeDiff / _longitudeDiffSum;
    CGFloat xIncrement = longitudeRatio * _actualWidth;
    CGFloat newX = previousX + xIncrement;
    return newX;
}

- (CGFloat) getYCoordinate:(CGFloat)currentLatutude {
    CGFloat latitudeRatio = (_latitudeMax - currentLatutude) / _latitudeMaxDiff;
    CGFloat newY = latitudeRatio * _actualHeight + MARKER_VERTICAL_OFFSET;
    return newY;
}

@end





