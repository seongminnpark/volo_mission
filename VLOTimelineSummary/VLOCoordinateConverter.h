
//  VLOCoordinateConverter.h


#import <Foundation/Foundation.h>
#import "VLOUtilities.h"
#import "VLOMarker.h"
#import "VLOLocationCoordinate.h"
#import "VLOPlace.h"
#import "VLOTimeLineSummary.h"

#define VERTICAL_PADDING MARKER_SIZE + MARKER_LABEL_HEIGHT * 3
#define HORIZONTAL_PADDING MARKER_SIZE
#define HORIZONTAL_SQUASH 4 // 0이면 적용 안 됨.
#define VERTICAL_SQUASH   5   // 0이면 적용 안 됨.


@interface VLOCoordinateConverter : NSObject

- (id) init;
- (NSArray *) getCoordinates:(NSArray *)originalPlaceList; 

@end
