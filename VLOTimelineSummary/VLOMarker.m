//  Marker.m


#import "VLOMarker.h"

@implementation VLOMarker
@synthesize x;
@synthesize y;

+ (CGFloat) distanceBetweenMarker1:(VLOMarker *)marker1 Marker2:(VLOMarker *)marker2 {
    CGFloat xDelta = marker2.x - marker1.x;
    CGFloat yDelta = marker2.y - marker1.y;
    CGFloat distance = sqrt(xDelta * xDelta + yDelta * yDelta);
    return distance;
}

- (UIView *) getMarkerView {
    // 마커 생성.
    UIImageView *markerImageView = [[UIImageView alloc]
                                    initWithImage: [UIImage imageNamed:MARKER_IMAGE_NAME]];
    CGFloat markerLeft = x - MARKER_SIZE/2;
    CGFloat markerTop = y - MARKER_SIZE;
    
    [markerImageView setFrame:CGRectMake(0, -MARKER_TRAVEL, MARKER_SIZE, MARKER_SIZE)];
    
    // 마커 레이블 생성. 띄어쓰기가 있으면 여러줄로 나눔.
    NSMutableArray *label_arr = [NSMutableArray array];
    NSArray *name_split = [_name componentsSeparatedByString:@" "];
    Boolean place_name_three = FALSE;
    NSInteger cnt;

    if(name_split.count > 3)
    {
        cnt = 3;
        place_name_three = TRUE;
    }
    else
    {
        cnt = name_split.count;
    }
    
    for (NSInteger i = 0; i < cnt; i++)
    {
        
        CGFloat label_top = -((cnt - i) * MARKER_LABEL_HEIGHT + MARKER_TRAVEL);
        
        UILabel *markerLabel = [[UILabel alloc] initWithFrame:
                       CGRectMake(-MARKER_SIZE/2, label_top, MARKER_LABEL_WIDTH, MARKER_LABEL_HEIGHT)];
        
        if(place_name_three)
        {
            markerLabel.text = [[name_split objectAtIndex:i] stringByAppendingString:@"..."];
        }
        else
        {
            markerLabel.text = [name_split objectAtIndex:i];
        }
        
        markerLabel.font = [markerLabel.font fontWithSize:10];
        markerLabel.textAlignment = NSTextAlignmentCenter;
        
        [label_arr addObject:markerLabel];
    }
    
    // 마커 레이블 + 마커를 담은 UIView 생성.
    UIView *markerView = [[UIView alloc] initWithFrame:
                          CGRectMake(markerLeft, markerTop, MARKER_SIZE, MARKER_SIZE + MARKER_LABEL_HEIGHT)];
    [markerView addSubview:markerImageView];
    
    for (UILabel *label in label_arr)
    {
        [markerView addSubview:label];
    }

    return markerView;
}

@end