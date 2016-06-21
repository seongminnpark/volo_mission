// VLOTimeLineSummary.m


#import "VLOTimelineSummary.h"

@interface VLOTimelineSummary()

@end

@implementation VLOTimelineSummary


- (id)initWithView:(UIView *)summaryView andPlaceList:(NSArray *)placeList
{
    self = [super init];
    
    VLOCoordinateConverter *converter = [[VLOCoordinateConverter alloc] init];
    NSArray *markerList = [converter getCoordinates:placeList];

    _animationMaker = [[VLOPathAnimationMaker alloc] initWithView:summaryView andMarkerList:markerList];
    
    return self;
    
}

- (void) animateSummary {
    [_animationMaker animatePath];
}

@end