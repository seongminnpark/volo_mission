// VLOTimeLineSummary.m


#import "VLOTimelineSummary.h"

@interface VLOTimelineSummary()

@property CGFloat summaryWidth;
@property CGFloat summaryHeight;

@end

@implementation VLOTimelineSummary


- (id)initWithView:(UIView *)summaryView andLogList:(NSArray *)logList
{
    self = [super init];
    
    _summaryWidth = summaryView.bounds.size.width;
    _summaryHeight = summaryView.bounds.size.height;
    
    VLOCoordinateConverter *converter = [[VLOCoordinateConverter alloc] init];
    
    NSArray *markerList = [converter getCoordinates:logList];

    _animationMaker = [[VLOPathAnimationMaker alloc] initWithView:summaryView andMarkerList:markerList];
    
    return self;
    
}

- (void) animateSummary {
    [_animationMaker animatePath];
}

@end