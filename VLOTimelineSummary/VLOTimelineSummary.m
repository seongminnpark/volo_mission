// VLOTimeLineSummary.m


#import "VLOTimelineSummary.h"

@interface VLOTimelineSummary()

@end

@implementation VLOTimelineSummary


- (id)initWithView:(UIView *)summaryView andPlaceList:(NSArray *)placeList
{
    self = [super init];
    
    VLOCoordinateConverter *conv = [[VLOCoordinateConverter alloc] init];
    NSArray *markerList = [conv getCoordinates:placeList];

    _animationMaker = [[VLOPathAnimationMaker alloc] initWithView:summaryView andMarkerList:markerList];
    return self;
    
}

- (void) animateSummary {
    [_animationMaker animatePath];
}

@end