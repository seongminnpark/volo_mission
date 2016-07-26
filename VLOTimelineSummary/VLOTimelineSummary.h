// VLOTimelineSummary.h


#import <UIKit/UIKit.h>
#import "VLOPathAnimationMaker.h"
#import "VLOMarker.h"
#import "VLOCoordinateConverter.h"
#import "VLOLog.h"
#import "VLODayLog.h"

#define SUMMARY_HEIGHT 130


@interface VLOTimelineSummary : NSObject

@property (strong,nonatomic) VLOPathAnimationMaker * animationMaker;
@property NSInteger summaryWidth;
@property NSInteger summaryHeight;

- (id) initWithView:(UIView *)summaryView andLogList:(NSArray *)logList;
- (void) animateSummary;

@end