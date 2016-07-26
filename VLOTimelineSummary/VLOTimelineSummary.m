// VLOTimeLineSummary.m


#import "VLOTimelineSummary.h"

@interface VLOTimelineSummary()

@end

@implementation VLOTimelineSummary


- (id)initWithView:(UIView *)summaryView andPlaceList:(NSArray *)placeList
{
    self = [super init];
    
    CGFloat summaryWidth = summaryView.bounds.size.width;
    CGFloat summaryHeight = summaryView.bounds.size.height;
    
    VLOCoordinateConverter *converter = [[VLOCoordinateConverter alloc] initWithWidth:summaryWidth andHeight:summaryHeight];
    NSArray *markerList = [converter getCoordinates:placeList];

    _animationMaker = [[VLOPathAnimationMaker alloc] initWithView:summaryView andMarkerList:markerList];
    
    return self;
    
}

- (void) animateSummary {
    [_animationMaker animatePath];
}

@end