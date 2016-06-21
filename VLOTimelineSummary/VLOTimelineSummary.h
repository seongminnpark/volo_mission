// VLOTimelineSummary.h


#import <UIKit/UIKit.h>
#import "getCoordinates.h"
#import "VLOPathAnimationMaker.h"
#import "VLOMarker.h"
#import "VLOCoordinateConverter.h"
#define SUMMARY_HEIGHT 100


@interface VLOTimelineSummary : NSObject


@property (strong,nonatomic) GetCoordinates * gc;
@property (strong,nonatomic) VLOPathAnimationMaker * animationMaker;

- (id)initWithView:(UIView *)summaryView andPlaceList:(NSArray *)placeList;
- (void) animateSummary;

@end