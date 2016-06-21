//
//  Marker.m
//  getCoordinates(ios)
//
//  Created by M on 2016. 6. 10..
//  Copyright © 2016년 M. All rights reserved.
//

#import "Marker.h"

@implementation Marker
@synthesize x;
@synthesize y;

- (UIView *) getMarkerView {
    // 마커 생성.
    UIImageView *markerImageView = [[UIImageView alloc]
                                    initWithImage: [UIImage imageNamed:MARKER_IMAGE_NAME]];
    CGFloat markerLeft = x - MARKER_SIZE/2;
    CGFloat markerTop = y - MARKER_SIZE;
    [markerImageView setFrame:CGRectMake(0, -MARKER_TRAVEL, MARKER_SIZE, MARKER_SIZE)];
    
    // 마커 레이블 생성.
    UILabel *markerLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(-MARKER_SIZE/2, -MARKER_LABEL_HEIGHT -MARKER_TRAVEL, MARKER_LABEL_WIDTH, MARKER_LABEL_HEIGHT)];
    markerLabel.text = _name;
    markerLabel.font = [markerLabel.font fontWithSize:10];
    markerLabel.textAlignment = NSTextAlignmentCenter;
    
    // 마커 레이블 + 마커를 담은 UIView 생성.
    UIView *markerView = [[UIView alloc] initWithFrame:
                          CGRectMake(markerLeft, markerTop, MARKER_SIZE, MARKER_SIZE + MARKER_LABEL_HEIGHT)];
    [markerView addSubview:markerImageView];
    [markerView addSubview:markerLabel];
    
    return markerView;
}

@end