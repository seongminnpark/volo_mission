// VLOTimeLineSummary.m


#import "VLOTimelineSummary.h"
#import "VLOUtilities.h"

@interface VLOTimelineSummary()

@end

@implementation VLOTimelineSummary


- (id)initWithView:(UIView *)summaryView andLogList:(NSArray *)logList groupByDate:(BOOL)groupByDate
{
    self = [super init];
    
    _summaryWidth = summaryView.bounds.size.width;
    _summaryHeight = summaryView.bounds.size.height;
    
    VLOSummaryConverter *converter = [[VLOSummaryConverter alloc] initWithWidth:_summaryWidth andHeight:_summaryHeight];
    //NSArray *markerList = [converter getCoordinates:logList groupByDate:groupByDate];
    [converter getCoordinates:logList groupByDate:groupByDate];
    
    //_animationMaker = [[VLOPathAnimationMaker alloc] initWithView:summaryView andMarkerList:markerList];
    
    return self;
    
}

- (void) animateSummary {
    [_animationMaker animatePath];
}

@end