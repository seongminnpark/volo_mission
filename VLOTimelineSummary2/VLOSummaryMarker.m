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

- (void) initializeMarkerImage {
    CGFloat markerLeft = _x - MARKER_SIZE/2;
    CGFloat markerTop  = _y - MARKER_SIZE/2;
    
    if (_markerUsesCustomImage) {
        
        UIImage *markerImage = [UIImage imageNamed:_markerImageName];
        _markerView = [[UIImageView alloc] initWithImage:markerImage];
        _markerView.frame = CGRectMake(markerLeft, markerTop, MARKER_SIZE, MARKER_SIZE);
        
    } else {
        _markerView = [[UIView alloc] initWithFrame:CGRectMake(markerLeft, markerTop, MARKER_SIZE, MARKER_SIZE)];
        
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:
                                    CGRectMake(markerLeft, markerTop, MARKER_SIZE, MARKER_SIZE)];
        
        CAShapeLayer *markerLayer = [CAShapeLayer layer];
        [markerLayer setPath:circlePath.CGPath];
        
        [_markerView.layer addSublayer:markerLayer];
        
        if (_hasMarkerContent) {
            [markerLayer setStrokeColor:[[UIColor redColor] CGColor]];
            [markerLayer setFillColor:[[UIColor clearColor] CGColor]];
        }
    }
}

- (void) initializeMarkerContentImage {
    CGFloat contentLeft = _x - MARKER_CONTENT_SIZE/2;
    CGFloat contentTop  = _y - LINE_SIZE - MARKER_CONTENT_SIZE;
    
    if (_markerContentUsesCustomImage) {
        
        UIImage *contentImage = [UIImage imageNamed:_contentImageName];
        _markerContentView = [[UIImageView alloc] initWithImage:contentImage];
        _markerContentView.frame =
            CGRectMake(contentLeft, contentTop, MARKER_CONTENT_SIZE + LINE_SIZE, MARKER_CONTENT_SIZE + LINE_SIZE);
        
    } else {
        _markerContentView = [[UIView alloc] initWithFrame:
                              CGRectMake(contentLeft, contentTop, MARKER_CONTENT_SIZE + LINE_SIZE, MARKER_CONTENT_SIZE + LINE_SIZE)];
        
        // 국기
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:
                                    CGRectMake(contentLeft, contentTop, MARKER_CONTENT_SIZE, MARKER_CONTENT_SIZE)];
        CAShapeLayer *contentLayer = [CAShapeLayer layer];
        [contentLayer setPath:circlePath.CGPath];
        
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

- (UIView *) getDrawableView {
    CGFloat drawableLeft, drawableTop, drawableWidth, drawableHeight;
    
    // 마커와 마커 장식 생성.
    [self initializeMarkerImage];
    if (_hasMarkerContent) [self initializeMarkerContentImage];

    // 마커와 마커 장식 묶음이 담길 뷰 생성.
    if (_hasMarkerContent) {
        drawableLeft   = MIN(_markerView.frame.origin.x,    _markerContentView.frame.origin.x);
        drawableTop    = MIN(_markerView.frame.origin.y,    _markerContentView.frame.origin.y);
        drawableWidth  = MAX(_markerView.frame.size.width,  _markerContentView.frame.size.width);
        drawableHeight = MAX(_markerView.frame.size.height, _markerContentView.frame.size.height);
    } else {
        drawableLeft   = _markerContentView.frame.origin.x;
        drawableTop    = _markerContentView.frame.origin.y;
        drawableWidth  = _markerContentView.frame.origin.y;
        drawableHeight = _markerContentView.frame.size.height;
    }
    
    UIView *drawableView = [[UIView alloc] initWithFrame:CGRectMake(drawableLeft, drawableTop, drawableWidth, drawableHeight)];
    [drawableView addSubview:_markerView];
    if (_hasMarkerContent) [drawableView addSubview:_markerContentView];
    
    return drawableView;
}




@end
