// VLOTimeLineSummary.m


#import "VLOTimelineSummary.h"
#import "VLOUtilities.h"

@interface VLOTimelineSummary()

@end

@implementation VLOTimelineSummary


- (id)initWithView:(UIView *)summaryView andLogList:(NSArray *)logList
{
    self = [super init];
    
    
    _summaryWidth = summaryView.bounds.size.width;
    _summaryHeight = summaryView.bounds.size.height;
    
    VLOCoordinateConverter *converter = [[VLOCoordinateConverter alloc] initWithWidth:_summaryWidth andHeight:_summaryHeight];
    
    NSArray *markerList = [converter getCoordinates:logList];
    _animationMaker = [[VLOPathAnimationMaker alloc] initWithView:summaryView andMarkerList:markerList];
    
    return self;
    
}

- (void) animateSummary {
    [_animationMaker animatePath];
}

@end