
//  VLOCoordinateConverter.h


#import <Foundation/Foundation.h>
#import "VLOUtilities.h"
#import "VLOMarker.h"
#import "VLOLocationCoordinate.h"
#import "VLOPlace.h"
#import "VLOTimeLineSummary.h"

#define VERTICAL_PADDING MARKER_SIZE + MARKER_LABEL_HEIGHT

@interface VLOCoordinateConverter : NSObject

- (id) init;
- (NSArray *) getCoordinates:(NSArray *)originalPlaceList;

@end
