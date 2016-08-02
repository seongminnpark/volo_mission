//
//  VLOSummaryMarker.m
//  Volo
//
//  Created by Seongmin on 7/29/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import "VLOSummaryMarker.h"

@interface VLOSummaryMarker ()

@property (nonatomic, strong) UIView *markerView;
@property (nonatomic, strong) UIView *markerContentView;
@property () BOOL markerUsesCustomImage;
@property () BOOL markerContentUsesCustomImage;
@property () NSString *markerImageName;
@property () NSString *contentImageName;

@property () CGFloat drawableLeft;
@property () CGFloat drawableTop;
@property () CGFloat drawableWidth;
@property () CGFloat drawableHeight;

@end

@implementation VLOSummaryMarker

+ (CGFloat) distanceBetweenMarker1:(VLOSummaryMarker *)marker1 Marker2:(VLOSummaryMarker *)marker2 {
    CGFloat xDelta = marker2.x - marker1.x;
    CGFloat yDelta = marker2.y - marker1.y;
    CGFloat distance = sqrt(xDelta * xDelta + yDelta * yDelta);
    return distance;
}

- (id) init {
    self = [super init];
    
    _markerUsesCustomImage = NO;
    _markerContentUsesCustomImage = NO;
    _hasMarkerContent = NO;
    
    return self;
}

- (void) setMarkerImage:(NSString *)markerImageName {
    _markerUsesCustomImage = YES;
    
    _markerImageName = markerImageName;
}

- (void) setMarkerContentImage:(NSString *)contentImageName {
    _markerContentUsesCustomImage = YES;
    _hasMarkerContent = YES;
    
    _contentImageName = contentImageName;
}

- (UIView *) getDrawableView {
    
    // 모든 컴포넌트에 공유되는 Frame 변수들.
    _drawableLeft   = MIN(_x - MARKER_SIZE/2, _x - MARKER_CONTENT_SIZE/2);
    _drawableTop    = _y - LINE_SIZE - MARKER_CONTENT_SIZE/2;
    _drawableWidth  = MAX(MARKER_SIZE, MARKER_CONTENT_SIZE);
    _drawableHeight = MARKER_CONTENT_SIZE/2 + LINE_SIZE + MARKER_SIZE/2;

    // 마커와 마커 장식 생성.
    [self initializeMarkerView];
    if (_hasMarkerContent) [self initializeMarkerContentView];

    // 마커와 마커 장식 묶음이 담길 뷰 생성.
    UIView *drawableView = [[UIView alloc] initWithFrame:CGRectMake(_drawableLeft, _drawableTop, _drawableWidth, _drawableHeight)];
    [drawableView addSubview:_markerView];
    [drawableView setBackgroundColor:[UIColor blueColor]];
    if (_hasMarkerContent) [drawableView addSubview:_markerContentView];
    
    return drawableView;
}

- (void) initializeMarkerView {
    CGFloat markerLeft = _drawableWidth/2 - MARKER_SIZE/2;
    CGFloat markerTop  = _drawableHeight - MARKER_SIZE;
    
    if (_markerUsesCustomImage) {
        
        UIImage *markerImage = [UIImage imageNamed:_markerImageName];
        _markerView = [[UIImageView alloc] initWithImage:markerImage];
        _markerView.frame = CGRectMake(markerLeft, markerTop, MARKER_SIZE, MARKER_SIZE);
        
    } else {
        _markerView = [[UIView alloc] initWithFrame:CGRectMake(markerLeft, markerTop, MARKER_SIZE, MARKER_SIZE)];
        
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, MARKER_SIZE, MARKER_SIZE)];
        
        CAShapeLayer *markerLayer = [CAShapeLayer layer];
        [markerLayer setPath:circlePath.CGPath];
        
        [_markerView.layer addSublayer:markerLayer];
        
        if (_hasMarkerContent) {
            [markerLayer setStrokeColor:[VOLO_COLOR CGColor]];
            [markerLayer setFillColor:[[UIColor clearColor] CGColor]];
        } else {
            [markerLayer setStrokeColor:[VOLO_COLOR CGColor]];
            [markerLayer setFillColor:[VOLO_COLOR CGColor]];
        }
        [markerLayer setLineWidth:3.0];
    }
}

- (void) initializeMarkerContentView {
    CGFloat contentLeft = _drawableWidth/2 - MARKER_CONTENT_SIZE/2;
    CGFloat contentTop  = 0;
    
    if (_markerContentUsesCustomImage) {
        
        UIImage *contentImage = [UIImage imageNamed:_contentImageName];
        _markerContentView = [[UIImageView alloc] initWithImage:contentImage];
        _markerContentView.frame =
        CGRectMake(contentLeft, contentTop, MARKER_CONTENT_SIZE, MARKER_CONTENT_SIZE + LINE_SIZE);
        
    } else {
        _markerContentView = [[UIView alloc] initWithFrame:
                              CGRectMake(contentLeft, contentTop, MARKER_CONTENT_SIZE + LINE_SIZE, MARKER_CONTENT_SIZE + LINE_SIZE)];
        
        // 국기
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:
                                    CGRectMake(contentLeft, contentTop, MARKER_CONTENT_SIZE, MARKER_CONTENT_SIZE)];
        CAShapeLayer *contentLayer = [CAShapeLayer layer];
        [contentLayer setPath:circlePath.CGPath];
        [contentLayer setStrokeColor:[VOLO_COLOR CGColor]];
        [contentLayer setFillColor:[[UIColor clearColor] CGColor]];
        [contentLayer setLineWidth:3.0];
        
        // 마커와 국기를 잇는 선.
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:CGPointMake(_x, _y)];
        [linePath addLineToPoint:CGPointMake(_x, _y - LINE_SIZE)];
        
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        [lineLayer setPath:linePath.CGPath];
        
        [_markerContentView.layer addSublayer:contentLayer];
        [_markerContentView.layer addSublayer:lineLayer];
    }
}




@end
