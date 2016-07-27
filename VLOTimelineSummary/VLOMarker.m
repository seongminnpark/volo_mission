//  Marker.m


#import "VLOMarker.h"
#import "UIFont+VLOExtension.h"


@implementation VLOMarker

+ (CGFloat) distanceBetweenMarker1:(VLOMarker *)marker1 Marker2:(VLOMarker *)marker2 {
    CGFloat xDelta = marker2.x - marker1.x;
    CGFloat yDelta = marker2.y - marker1.y;
    CGFloat distance = sqrt(xDelta * xDelta + yDelta * yDelta);
    return distance;
}

- (UIView *) getMarkerView {
    // 마커 생성.
//    UIImageView *markerImageView = [[UIImageView alloc]
//                                    initWithImage: [UIImage imageNamed:MARKER_IMAGE_NAME]];
    UIImageView *markerImageView = [[UIImageView alloc] init];
    markerImageView.image = [[UIImage imageNamed:MARKER_IMAGE_NAME] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [markerImageView setTintColor:_color];
    
    CGFloat imageViewLeft = MARKER_LABEL_WIDTH/2 - MARKER_SIZE/2;
    CGFloat imageViewTop = -MARKER_SIZE/2;
    
    [markerImageView setFrame:CGRectMake(imageViewLeft, imageViewTop, MARKER_SIZE, MARKER_SIZE)];
    [markerImageView setTintColor:_color];
    
    // 마커 레이블 생성. 띄어쓰기가 있으면 여러줄로 나눔.
    NSMutableArray *label_arr = [NSMutableArray array];
    NSArray *name_split = [_name componentsSeparatedByString:@" "];
    
    // 레이블은 최대 세 줄로 표시.
    for (NSInteger i = 0; i < name_split.count; i++)
    {
        // 마커 이름이 네 줄 이상일 경우, 세 번째 줄에 "..." 추가.
        if (i > 2) {
            UILabel *thirdLabel = [label_arr objectAtIndex:2];
            thirdLabel.text = [thirdLabel.text stringByAppendingString:@"..."];
            break;
        }
        
        CGFloat labelTop = [self getLabelTop:name_split.count :i];
        
        // Label의 left bound가 0인 이유는 label의 넓이와 superview의 넓이와 같기 때문에 superview의 왼쪽 끝에서 시작한다.
        UILabel *markerLabel = [[UILabel alloc] initWithFrame:
                                CGRectMake(0, labelTop, MARKER_LABEL_WIDTH, MARKER_LABEL_HEIGHT)];
        markerLabel.text = [name_split objectAtIndex:i];
        markerLabel.font = [UIFont museoSans700WithSize:10.0f];
        markerLabel.textAlignment = NSTextAlignmentCenter;
        markerLabel.textColor = [UIColor darkGrayColor];
        [label_arr addObject:markerLabel];
    }
    
    // 마커 레이블 + 마커를 담은 UIView 생성.
    CGFloat markerViewLeft = _x - MARKER_LABEL_WIDTH/2;
    CGFloat markerViewTop = _y - MARKER_LABEL_HEIGHT - MARKER_SIZE;
    
    UIView *markerView = [[UIView alloc] initWithFrame:
                          CGRectMake(markerViewLeft, markerViewTop, MARKER_LABEL_WIDTH, MARKER_SIZE + MARKER_LABEL_HEIGHT)];
    
    
    // Subview 추가.
    [markerView addSubview:markerImageView];
    
    for (UILabel *label in label_arr)
    {
        [markerView addSubview:label];
    }
    
    return markerView;
}

- (CGFloat) getLabelTop:(NSInteger)nameSplitCount :(NSInteger)index {
    CGFloat label_top;
    CGFloat labelOffset;
    
    NSInteger wordCount = nameSplitCount;
    if (wordCount > 3) {
        wordCount = 3;
    }
    if (_nameAbove) {
        labelOffset = MARKER_LABEL_HEIGHT * (wordCount - index) + MARKER_TRAVEL;
        label_top = - labelOffset;
    } else {
        CGFloat labelOffset = MARKER_LABEL_HEIGHT * index + MARKER_TRAVEL;
        label_top = labelOffset;
    }
    
    return label_top;
}

@end