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
    _drawableTop    = _y - MARKER_SIZE/2 - MARKER_CONTENT_GAP - MARKER_CONTENT_SIZE;
    _drawableWidth  = MAX(MARKER_SIZE, MARKER_CONTENT_SIZE);
    _drawableHeight = MARKER_CONTENT_SIZE + MARKER_CONTENT_GAP + MARKER_SIZE;

    // 마커와 마커 장식 생성.
    [self initializeMarkerView];
    if (_hasMarkerContent) [self initializeMarkerContentView];

    // 마커와 마커 장식 묶음이 담길 뷰 생성.
    UIView *drawableView = [[UIView alloc] initWithFrame:CGRectMake(_drawableLeft, _drawableTop, _drawableWidth, _drawableHeight)];
    [drawableView addSubview:_markerView];
    //[drawableView setBackgroundColor:[UIColor blueColor]];
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
            [markerLayer setFillColor:[[UIColor whiteColor] CGColor]];
        } else {
            [markerLayer setStrokeColor:[VOLO_COLOR CGColor]];
            [markerLayer setFillColor:[VOLO_COLOR CGColor]];
        }
        [markerLayer setLineWidth:LINE_WIDTH];
    }
}

- (void) initializeMarkerContentView {
    CGFloat contentLeft = _drawableWidth/2 - MARKER_CONTENT_SIZE/2;
    CGFloat contentTop  = 0;
    
    _markerContentView = [[UIView alloc] initWithFrame:
                          CGRectMake(contentLeft, contentTop, MARKER_CONTENT_SIZE, MARKER_CONTENT_SIZE + MARKER_CONTENT_GAP)];
    
    if (_markerContentUsesCustomImage) {
        
        UIImage *contentImage = [UIImage imageNamed:_contentImageName];
        UIImageView *contentImageView = [[UIImageView alloc] initWithImage:contentImage];
        contentImageView.frame = CGRectMake(0, 0, MARKER_CONTENT_SIZE, MARKER_CONTENT_SIZE);
        
        [_markerContentView addSubview:contentImageView];
        
    } else {
        
        // 국기
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:
                                    CGRectMake(0, 0, MARKER_CONTENT_SIZE, MARKER_CONTENT_SIZE)];
        CAShapeLayer *contentLayer = [CAShapeLayer layer];
        [contentLayer setPath:circlePath.CGPath];
        [contentLayer setStrokeColor:[VOLO_COLOR CGColor]];
        [contentLayer setFillColor:[[UIColor clearColor] CGColor]];
        [contentLayer setLineWidth:LINE_WIDTH];
        
        [_markerContentView.layer addSublayer:contentLayer];
    }
    // 마커와 국기를 잇는 선.
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    CGFloat topOfMarker = _drawableHeight - MARKER_SIZE;
    CGFloat bottomOfFlag = topOfMarker - MARKER_CONTENT_GAP;
    [linePath moveToPoint:CGPointMake(_drawableWidth/2, topOfMarker)];
    [linePath addLineToPoint:CGPointMake(_drawableWidth/2, bottomOfFlag)];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    [lineLayer setPath:linePath.CGPath];
    
    [_markerContentView.layer addSublayer:lineLayer];
    [lineLayer setStrokeColor:[VOLO_COLOR CGColor]];
    [lineLayer setLineWidth:LINE_WIDTH];
}




@end
