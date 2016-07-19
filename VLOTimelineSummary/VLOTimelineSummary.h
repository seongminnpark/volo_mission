// VLOTimelineSummary.h


#import <UIKit/UIKit.h>
#import "VLOPathAnimationMaker.h"
#import "VLOMarker.h"
#import "VLOCoordinateConverter.h"


@interface VLOTimelineSummary : NSObject

@property (strong,nonatomic) VLOPathAnimationMaker * animationMaker;

- (id) initWithView:(UIView *)summaryView andPlaceList:(NSArray *)placeList;
- (void) animateSummary;

@end