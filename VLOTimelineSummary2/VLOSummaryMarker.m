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
@property (nonatomic, strong) UILabel *markerLabel;
@property () BOOL hasMarkerContent;
@property () BOOL markerContentIsFlag;
@property () BOOL markerUsesCustomImage;
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
    _hasMarkerContent = NO;
    _markerContentIsFlag = NO;
    
    return self;
}

- (void) setMarkerImage:(NSString *)markerImageName {
    _markerUsesCustomImage = YES;
    _markerImageName = markerImageName;
}

- (void) setMarkerContentImage:(NSString *)contentImageName isFlag:(BOOL)isFlag {
    _hasMarkerContent = YES;
    _markerContentIsFlag = isFlag;
    _contentImageName = contentImageName;
}

- (UIView *) getDrawableView {
    
    // 모든 컴포넌트에 공유되는 Frame 변수들.
    _drawableLeft   = MIN(_x - MARKER_SIZE/2, _x - MARKER_CONTENT_SIZE/2);
    _drawableTop    = _y - MARKER_SIZE/2 - MARKER_CONTENT_GAP - MARKER_CONTENT_SIZE;
    _drawableWidth  = MAX(MARKER_SIZE, MARKER_CONTENT_SIZE);
    _drawableHeight = MARKER_CONTENT_SIZE + MARKER_CONTENT_GAP + MARKER_SIZE + MARKER_CONTENT_GAP + MARKER_LABEL;

    // 마커, 마커 레이블, 마커 장식 생성.
    [self initializeMarkerView];
    [self initializeMarkerLabel];
    if (_hasMarkerContent) [self initializeMarkerContentView];

    // 마커와 마커 장식 묶음이 담길 뷰 생성.
    UIView *drawableView = [[UIView alloc] initWithFrame:CGRectMake(_drawableLeft, _drawableTop, _drawableWidth, _drawableHeight)];
    [drawableView addSubview:_markerView];
    [drawableView addSubview:_markerLabel];
    if (_hasMarkerContent) [drawableView addSubview:_markerContentView];
    
    return drawableView;
}

- (void) initializeMarkerView {
    if (_markerView) return;
    
    CGFloat markerLeft = _drawableWidth/2 - MARKER_SIZE/2;
    CGFloat markerTop  = _drawableHeight - MARKER_LABEL - MARKER_CONTENT_GAP - MARKER_SIZE;
    
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
            [markerLayer setFillColor:[VOLO_COLOR CGColor]];
        } else {
            [markerLayer setStrokeColor:[LINE_COLOR CGColor]];
            [markerLayer setFillColor:[LINE_COLOR CGColor]];
        }
        [markerLayer setLineWidth:LINE_WIDTH];
    }
}

- (void) initializeMarkerContentView {
    if (_markerContentView) return;
    
    CGFloat contentLeft = _drawableWidth/2 - MARKER_CONTENT_SIZE/2;
    CGFloat contentTop  = 0;
    
    _markerContentView = [[UIView alloc] initWithFrame:
                          CGRectMake(contentLeft, contentTop, MARKER_CONTENT_SIZE, MARKER_CONTENT_SIZE + MARKER_CONTENT_GAP)];
    
    
    // 마커 컨텐츠 (국기 등).
    if (_hasMarkerContent) {
        
        // 국기가 아닌 경우 마커로부터 국기까지의 선이 없다. 
        CGFloat contentViewTop = _markerContentIsFlag? 0 : MARKER_CONTENT_GAP;
        
        UIImage *contentImage = [UIImage imageNamed:_contentImageName];
        UIImageView *contentImageView = [[UIImageView alloc] initWithImage:contentImage];
        contentImageView.frame = CGRectMake(0, contentViewTop, MARKER_CONTENT_SIZE, MARKER_CONTENT_SIZE);
        
        [_markerContentView addSubview:contentImageView];
        
        if (_markerContentIsFlag) {
            // 마커 컨텐츠 테두리.
            UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:
                                        CGRectMake(0, 0, MARKER_CONTENT_SIZE, MARKER_CONTENT_SIZE)];
            CAShapeLayer *contentLayer = [CAShapeLayer layer];
            [contentLayer setPath:circlePath.CGPath];
            [contentLayer setStrokeColor:[VOLO_COLOR CGColor]];
            [contentLayer setFillColor:[[UIColor clearColor] CGColor]];
            [contentLayer setLineWidth:LINE_WIDTH];
            
            [_markerContentView.layer addSublayer:contentLayer];
            
            // 마커와 국기를 잇는 선.
            UIBezierPath *linePath = [UIBezierPath bezierPath];
            CGFloat topOfMarker = _drawableHeight - MARKER_LABEL - MARKER_CONTENT_GAP - MARKER_SIZE;
            CGFloat bottomOfFlag = topOfMarker - MARKER_CONTENT_GAP;
            [linePath moveToPoint:CGPointMake(_drawableWidth/2, topOfMarker)];
            [linePath addLineToPoint:CGPointMake(_drawableWidth/2, bottomOfFlag)];
            
            CAShapeLayer *lineLayer = [CAShapeLayer layer];
            [lineLayer setPath:linePath.CGPath];
            
            [_markerContentView.layer addSublayer:lineLayer];
            [lineLayer setStrokeColor:[VOLO_COLOR CGColor]];
            [lineLayer setLineWidth:LINE_WIDTH];
        }
    }
    
}

- (void) initializeMarkerLabel {
    if (_markerLabel) return;
    _markerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _drawableHeight - MARKER_LABEL, _drawableWidth, MARKER_LABEL)];
    _markerLabel.text = _name;
    _markerLabel.textAlignment = NSTextAlignmentCenter;
    _markerLabel.textColor = [UIColor grayColor];
    [_markerLabel setFont:[UIFont systemFontOfSize:MARKER_LABEL]];
}



@end
