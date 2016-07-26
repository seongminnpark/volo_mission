
//  VLOCoordinateConverter.h


#import <Foundation/Foundation.h>
#import "VLOMarker.h"
#import "VLOLocationCoordinate.h"
#import "VLOPlace.h"
#import "VLOCountry.h"
#import "VLOTimeLineSummary.h"
#import "VLORouteLog.h"

#define VERTICAL_PADDING   MARKER_SIZE + MARKER_LABEL_HEIGHT * 3 // 마커 레이블은 세 줄까지 가능.
#define HORIZONTAL_PADDING MARKER_SIZE
#define MIN_DIST           MARKER_SIZE + 20 // 두 마커 사이 최소 거리.
#define Y_VARIATION        MARKER_SIZE / 4.0f

@interface VLOCoordinateConverter : NSObject

- (id) initWithWidth:(CGFloat)width andHeight:(CGFloat)height;
- (NSArray *) getCoordinates:(NSArray *)originalPlaceList; 

@end
