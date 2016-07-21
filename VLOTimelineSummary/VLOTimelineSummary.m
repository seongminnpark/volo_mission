// VLOTimeLineSummary.m


#import "VLOTimelineSummary.h"

@interface VLOTimelineSummary()

@property CGFloat summaryWidth;
@property CGFloat summaryHeight;

@end

@implementation VLOTimelineSummary


- (id)initWithView:(UIView *)summaryView andPlaceList:(NSArray *)placeList
{
    self = [super init];
    
    _summaryWidth = summaryView.bounds.size.width;
    _summaryHeight = summaryView.bounds.size.height;
    
    //VLOCoordinateConverter *converter = [[VLOCoordinateConverter alloc] initWithWidth:_summaryWidth andHeight:_summaryHeight];
    VLOCoordinateConverter *converter = [[VLOCoordinateConverter alloc] init];
    
    NSArray *markerList = [converter getCoordinates:placeList];

    _animationMaker = [[VLOPathAnimationMaker alloc] initWithView:summaryView andMarkerList:markerList];
    
    return self;
    
}

- (void) animateSummary {
    [_animationMaker animatePath];
}

@end