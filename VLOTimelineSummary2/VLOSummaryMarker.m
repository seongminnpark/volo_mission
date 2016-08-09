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
@property (nonatomic, strong) UIView *markerIconView;
@property (nonatomic, strong) UILabel *markerLabel;
@property () BOOL hasMarkericon;
@property () BOOL markericonIsFlag;
@property () BOOL markerUsesCustomImage;
@property () NSString *markerImageName;
@property () NSString *iconImageName;

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
    _hasMarkericon = NO;
    _markericonIsFlag = NO;
    
    return self;
}

- (void) setMarkerImage:(NSString *)markerImageName {
    _markerUsesCustomImage = YES;
    _markerImageName = markerImageName;
}

- (void) setMarkerIconImage:(NSString *)iconImageName isFlag:(BOOL)isFlag {
    _hasMarkericon = YES;
    _markericonIsFlag = isFlag;
    _iconImageName = iconImageName;
}

- (UIView *) getDrawableView {
    
    // 모든 컴포넌트에 공유되는 Frame 변수들.
    _drawableLeft   = _x - MARKER_ICON_WIDTH/2.0;
    _drawableTop    = _y + SEGMENT_OFFSET - MARKER_ICON_HEIGHT;
    _drawableWidth  = MARKER_ICON_WIDTH;
    _drawableHeight = MARKER_ICON_HEIGHT + MARKER_LABEL; // 순서대로

    // 마커와 마커 장식 묶음이 담길 뷰 생성.
    UIView *drawableView = [[UIView alloc] initWithFrame:CGRectMake(_drawableLeft, _drawableTop, _drawableWidth, _drawableHeight)];

    // 마커 레이블.
    [self initializeMarkerLabel];
    [drawableView addSubview:_markerLabel];
    
    // 마커 그림.
    if (_hasMarkericon) {
        [self initializeMarkericonView];
        [drawableView addSubview:_markerIconView];
    }
    
    // 마커 점.
    if (_markerUsesCustomImage || !_hasMarkericon) {
        [self initializeMarkerView];
        [drawableView addSubview:_markerView];
    }
    
    return drawableView;
}

- (void) initializeMarkerView {
    if (_markerView) return;
    
    
    CGFloat markerTop, markerLeft;
    
    if (_markerUsesCustomImage) {
        
        markerTop  = _drawableHeight - MARKER_LABEL - MARKER_IMAGE_SIZE;
        markerLeft = _drawableWidth/2.0 - MARKER_IMAGE_SIZE/2.0;
        UIImage *markerImage = [UIImage imageNamed:_markerImageName];
        _markerView = [[UIImageView alloc] initWithImage:markerImage];
        _markerView.frame = CGRectMake(markerLeft, markerTop, MARKER_IMAGE_SIZE, MARKER_IMAGE_SIZE);
        
    } else {
        markerTop  = _drawableHeight - MARKER_LABEL - MARKER_FLAG_GAP - MARKER_SIZE;
        markerLeft = _drawableWidth/2.0 - MARKER_SIZE/2.0;
        
        _markerView = [[UIView alloc] initWithFrame:CGRectMake(markerLeft, markerTop, MARKER_SIZE, MARKER_SIZE)];
        
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, MARKER_SIZE, MARKER_SIZE)];
        
        CAShapeLayer *markerLayer = [CAShapeLayer layer];
        [markerLayer setPath:circlePath.CGPath];
        
        [_markerView.layer addSublayer:markerLayer];
        
        if (_hasMarkericon) {
            [markerLayer setStrokeColor:[VOLO_COLOR CGColor]];
            [markerLayer setFillColor:[VOLO_COLOR CGColor]];
        } else {
            [markerLayer setStrokeColor:[LINE_COLOR CGColor]];
            [markerLayer setFillColor:[LINE_COLOR CGColor]];
        }
        [markerLayer setLineWidth:LINE_WIDTH];
    }
}

- (void) initializeMarkericonView {
    if (_markerIconView) return;
        
    CGFloat imageViewLeft, imageViewTop;
    
    UIImage *iconImage = [UIImage imageNamed:_iconImageName];
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
    [iconImageView setBackgroundColor:[UIColor clearColor]];
    
    if (_markericonIsFlag) {
        
        // 국기 이미지 위치 설정.
        imageViewLeft = _drawableWidth/2.0 - MARKER_FLAG_SIZE/2.0;
        imageViewTop  = MARKER_ICON_HEIGHT - SEGMENT_HEIGHT - MARKER_FLAG_SIZE - MARKER_FLAG_GAP;
        iconImageView.frame = CGRectMake(imageViewLeft, imageViewTop, MARKER_FLAG_SIZE, MARKER_FLAG_SIZE);
        
        // 마커 컨텐츠 테두리.
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:
                                    CGRectMake(0, 0, MARKER_FLAG_SIZE, MARKER_FLAG_SIZE)];
        CAShapeLayer *iconLayer = [CAShapeLayer layer];
        [iconLayer setPath:circlePath.CGPath];
        [iconLayer setStrokeColor:[VOLO_COLOR CGColor]];
        [iconLayer setFillColor:[[UIColor clearColor] CGColor]];
        [iconLayer setLineWidth:LINE_WIDTH];
        [iconImageView.layer addSublayer:iconLayer];
        
        // 마커와 국기를 잇는 선.
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:CGPointMake(MARKER_FLAG_SIZE/2.0, MARKER_FLAG_SIZE)];
        CGFloat topOfMarker = MARKER_FLAG_SIZE + MARKER_FLAG_GAP + SEGMENT_OFFSET - MARKER_SIZE/2.0;
        [linePath addLineToPoint:CGPointMake(MARKER_FLAG_SIZE/2.0, topOfMarker)];
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        [lineLayer setPath:linePath.CGPath];
        [iconImageView.layer addSublayer:lineLayer];
        [lineLayer setStrokeColor:[VOLO_COLOR CGColor]];
        [lineLayer setLineWidth:LINE_WIDTH];
        
    } else {
        imageViewLeft = _drawableWidth/2 - MARKER_ICON_WIDTH/2.0;
        imageViewTop  = 0;
        iconImageView.frame = CGRectMake(imageViewLeft, imageViewTop, MARKER_ICON_WIDTH, MARKER_ICON_HEIGHT);
    }
    
    _markerIconView = iconImageView;
}

- (void) initializeMarkerLabel {
    if (_markerLabel) return;
    _markerLabel = [[UILabel alloc] initWithFrame:CGRectMake(-_drawableWidth/2.0, _drawableHeight - MARKER_LABEL, _drawableWidth*2, MARKER_LABEL)];
    _markerLabel.text = _name;
    _markerLabel.textAlignment = NSTextAlignmentCenter;
    _markerLabel.textColor = [UIColor grayColor];
    [_markerLabel setFont:[UIFont systemFontOfSize:MARKER_LABEL]];
}



@end
