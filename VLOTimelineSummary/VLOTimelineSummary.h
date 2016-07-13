// VLOTimelineSummary.h


#import <UIKit/UIKit.h>
#import "VLOPathAnimationMaker.h"
#import "VLOMarker.h"
#import "VLOCoordinateConverter.h"

#define SUMMARY_HEIGHT 130 // MARKER_SIZE + (MARKER_LABEL_HEIGHT * 3) 이상 이어야 합니다.


@interface VLOTimelineSummary : NSObject

@property (strong,nonatomic) VLOPathAnimationMaker * animationMaker;

- (id) initWithView:(UIView *)summaryView andPlaceList:(NSArray *)placeList;
- (void) animateSummary;

@end