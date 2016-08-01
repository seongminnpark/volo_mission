//
//  VLOSummarySegment.m
//  Volo
//
//  Created by Seongmin on 7/29/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import "VLOSummarySegment.h"

@interface VLOSummarySegment ()

@property (nonatomic, strong) UIView *segmentView;
@property (nonatomic, strong) UIView *segmentContentView;
@property () BOOL segmentUsesCustomImage;
@property () BOOL segmentContentUsesCustomImage;
@property () NSString *segmentImageName;
@property () NSString *contentImageName;

@end

@implementation VLOSummarySegment

- (id) initFrom:(VLOSummaryMarker *)fromMarker to:(VLOSummaryMarker *)toMarker {
    self = [super init];
    _fromMarker = fromMarker;
    _toMarker = toMarker;
    _curved = NO;
    _leftToRight = YES;
    _hasSegmentContent = NO;
    return self;
}

- (void) setSegmentImage:(NSString *)segmentImageName {
    _segmentUsesCustomImage = YES;
    
    _segmentImageName = segmentImageName;
}

- (void) setSegmentContentImage:(NSString *)contentImageName {
    _hasSegmentContent = YES;
    _segmentContentUsesCustomImage = YES;
    
    _contentImageName = contentImageName;
}

- (void) initializeSegmentImage {
    CGFloat segmentLeft, segmentWidth, segmentHeight;
    CGFloat segmentTop = _fromMarker.y;
    CGFloat curveRadius = LINE_VERTICAL_DIFFERENCE / 2;
    
    if (_curved) {
        segmentLeft = _leftToRight ? _fromMarker.x : _toMarker.x - curveRadius;
    } else {
        segmentLeft = _leftToRight ? _fromMarker.x : _toMarker.x;
    }
    
    segmentWidth = fabs(_toMarker.x - _fromMarker.x);
    segmentHeight = _curved? _toMarker.y - _fromMarker.y : SEGMENT_HEIGHT;
    
    // _segmentView 생성.
    if (_segmentUsesCustomImage) {
        
        UIImage *segmentImage= [UIImage imageNamed:_segmentImageName ];
        _segmentView = [[UIImageView alloc] initWithImage:segmentImage];
        _segmentView.frame = CGRectMake(segmentLeft, segmentTop, segmentWidth, SEGMENT_HEIGHT);
        
    } else {
        _segmentView = [[UIView alloc] initWithFrame:CGRectMake(segmentLeft, segmentTop, segmentWidth, segmentHeight)];
        
        UIBezierPath *segmentPath = [UIBezierPath bezierPath];
        [segmentPath moveToPoint:CGPointMake(_fromMarker.x, _fromMarker.y)];
        
        if (_curved) {
            
            CGFloat curveStartX = _leftToRight ? _fromMarker.x + CURVE_BUFFER : _fromMarker.x - CURVE_BUFFER;
            CGPoint arcCenter = CGPointMake(curveStartX, (_fromMarker.y + _toMarker.y)/2);
            [segmentPath addLineToPoint:CGPointMake(curveStartX, _fromMarker.y)];
            [segmentPath addArcWithCenter:arcCenter radius:curveRadius startAngle:0 endAngle:M_PI clockwise:YES];
            
        } else {
            [segmentPath addLineToPoint:CGPointMake(_toMarker.x, _toMarker.y)];
        }
        
        CAShapeLayer *segmentLayer = [CAShapeLayer layer];
        [segmentLayer setPath:segmentPath.CGPath];
        
        [_segmentView.layer addSublayer:segmentLayer];
    }
}

- (void) initializeSegmentContentImage {
    
    // Segment Content의 frame.origin.x를 구하는 로직.
    CGFloat contentLeft;
    CGFloat curveRadius = LINE_VERTICAL_DIFFERENCE / 2;
    
    if (_curved) {
        CGFloat curveStartX = _leftToRight ? _fromMarker.x + CURVE_BUFFER : _fromMarker.x - CURVE_BUFFER;
        if (_leftToRight) {
            contentLeft = curveStartX + curveRadius - SEGMENT_CONTENT_SIZE/2;
        } else {
            contentLeft = curveStartX - curveRadius + SEGMENT_CONTENT_SIZE/2;;
        }
    } else {
        CGFloat middleX = (_fromMarker.x + _toMarker.x)/2;
        contentLeft = middleX - SEGMENT_CONTENT_SIZE/2;
    }
    
    // Segment Content의 frame.origin.y를 구하는 로직.
    CGFloat arcCenterY = (_fromMarker.y + _toMarker.y)/2;
    CGFloat contentTop = arcCenterY - SEGMENT_CONTENT_SIZE/2;
    
    // _segmentContentView 생성.
    if (_segmentContentUsesCustomImage) {
        
        UIImage *contentImage = [UIImage imageNamed:_contentImageName];
        _segmentContentView = [[UIImageView alloc] initWithImage:contentImage];
        _segmentContentView.frame = CGRectMake(contentLeft, contentTop, SEGMENT_CONTENT_SIZE, SEGMENT_CONTENT_SIZE);
        
    } else {
        _segmentContentView = [[UIView alloc] initWithFrame:
                               CGRectMake(contentLeft, contentTop, SEGMENT_CONTENT_SIZE, SEGMENT_CONTENT_SIZE)];
    }
}

- (UIView *) getDrawableView {

    CGFloat drawableTop, drawableHeight;
    CGFloat drawableLength = fabs(_toMarker.x - _fromMarker.x);
    
    // 선과 선 장식 생성.
    [self initializeSegmentImage];
    if (_hasSegmentContent) [self initializeSegmentContentImage];
    
    // 선과 선 장식 묶음이 담길 뷰 생성.
    if (_hasSegmentContent) {
        drawableTop    = MIN(_segmentView.frame.origin.y,    _segmentContentView.frame.origin.y);
        drawableHeight = MAX(_segmentView.frame.size.height, _segmentContentView.frame.size.height);
    } else {
        drawableTop    = _segmentView.frame.origin.y;
        drawableHeight = _segmentView.frame.size.height;
    }
    
    UIView *drawableView = [[UIView alloc] initWithFrame:CGRectMake(_fromMarker.x, drawableTop, drawableLength, drawableHeight)];
    [drawableView addSubview:_segmentView];
    if (_hasSegmentContent) [drawableView addSubview:_segmentContentView];
    
    return drawableView;
}

@end
