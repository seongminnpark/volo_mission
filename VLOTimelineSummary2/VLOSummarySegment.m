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
@property (nonatomic, strong) UIView *segmentIconView;

@property () BOOL segmentUsesCustomImage;
@property () BOOL hasSegmentIcon;

@property () NSString *longImageName;
@property () NSString *mediumImageName;
@property () NSString *shortImageName;
@property () NSString *curveImageName;
@property () NSString *iconImageName;

@property () CGFloat drawableLeft;
@property () CGFloat drawableTop;
@property () CGFloat drawableWidth;
@property () CGFloat drawableHeight;

@property (strong, nonatomic) VLOSummaryMarker *fromMarker;
@property (strong, nonatomic) VLOSummaryMarker *toMarker;

@property (strong, nonatomic) VLOSummaryMarker *leftMarker;
@property (strong, nonatomic) VLOSummaryMarker *rightMarker;

@end

@implementation VLOSummarySegment

- (id) initFrom:(VLOSummaryMarker *)fromMarker to:(VLOSummaryMarker *)toMarker {
    self = [super init];
    
    _fromMarker = fromMarker;
    _toMarker   = toMarker;
    
    _curved      = NO;
    _leftToRight = YES;
    
    
    _segmentUsesCustomImage = NO;
    _hasSegmentIcon = NO;
    
    return self;
}

- (void) updateMarkerPositions {
    _leftMarker  = (_fromMarker.x < _toMarker.x) ? _fromMarker : _toMarker;
    _rightMarker = (_fromMarker.x < _toMarker.x) ? _toMarker : _fromMarker;
}

- (void) setSegmentImageLong:(NSString *)longImage
                      medium:(NSString *)mediumImage
                       shortt:(NSString *)shortImage
                       curve:(NSString *)curveImage {
    
    _segmentUsesCustomImage = YES;
    
    _longImageName = longImage;
    _mediumImageName = mediumImage;
    _shortImageName = shortImage;
    _curveImageName = curveImage;
}

- (void) setSegmentIconImage:(NSString *)iconImageName {
    _hasSegmentIcon = YES;
    _iconImageName = iconImageName;
}

- (void) calculateReferenceFrame {
    
    CGFloat curveRadius = fabs(_toMarker.y - _fromMarker.y)/2.0;
    
    // 모든 컴포넌트에 공유되는 Frame 변수들.
    _drawableLeft =  (_curved && _leftToRight)?  _rightMarker.x - MIDDLE_SEGMENT - CURVE_WIDTH : _leftMarker.x;
    _drawableTop    = _curved? _fromMarker.y - curveRadius: _fromMarker.y - SEGMENT_HEIGHT + SEGMENT_OFFSET;
    _drawableWidth  = _curved? CURVE_WIDTH + MIDDLE_SEGMENT : LONG_SEGMENT;
    _drawableHeight = _curved? LINE_GAP + SEGMENT_HEIGHT : SEGMENT_HEIGHT;
}

- (UIView *) getSegmentView {
    
    [self calculateReferenceFrame];
    [self initializeSegmentView];
    
    CGFloat left = _segmentView.frame.origin.x + _drawableLeft;
    CGFloat top = _segmentView.frame.origin.y + _drawableTop;
    CGFloat width = _segmentView.frame.size.width;
    CGFloat height = _segmentView.frame.size.height;
    _segmentView.frame = CGRectMake(left, top, width, height);
    
    return _segmentView;
}

- (UIView *) getSegmentIconView {
    [self calculateReferenceFrame];
    [self initializeSegmentIconView];
    
    CGFloat left = _segmentIconView.frame.origin.x + _drawableLeft;
    CGFloat top = _segmentIconView.frame.origin.y + _drawableTop;
    CGFloat width = _segmentIconView.frame.size.width;
    CGFloat height = _segmentIconView.frame.size.height;
    _segmentIconView.frame = CGRectMake(left, top, width, height);
    
    return _segmentIconView;
}

// drawableView는 선과 선 아이콘을 포함한다.
- (UIView *) getDrawableView {
    
    [self calculateReferenceFrame];
    
    // 선과 선 아이콘 생성.
    [self initializeSegmentView];
    if (_hasSegmentIcon) [self initializeSegmentIconView];
    
    // 선과 선 아이콘 묶음이 담길 뷰 생성.
    UIView *drawableView = [[UIView alloc] initWithFrame:CGRectMake(_drawableLeft, _drawableTop, _drawableWidth, _drawableHeight)];
    [drawableView addSubview:_segmentView];
    if (_hasSegmentIcon) [drawableView addSubview:_segmentIconView];
    
    return drawableView;
}

- (void) initializeSegmentView {
    
    CGFloat curveRadius = fabs(_toMarker.y - _fromMarker.y) / 2.0;
    CGFloat segmentLeft   = 0;
    CGFloat segmentTop    = _curved? 0 : _drawableHeight - SEGMENT_HEIGHT;
    CGFloat segmentWidth  = _drawableWidth;
    CGFloat segmentHeight = _curved? _drawableHeight : SEGMENT_HEIGHT;
    
    // (0,0)에서 시작하는 drawable 프레임에 맞춘 fromMarker과 toMarker 좌표.
    CGFloat fromMarkerX = _fromMarker.x - _drawableLeft;
    CGFloat fromMarkerY = _curved? curveRadius : _drawableHeight - SEGMENT_OFFSET;
    CGPoint fromMarker  = CGPointMake(fromMarkerX, fromMarkerY);
    
    CGFloat toMarkerX   = _toMarker.x - _drawableLeft;
    CGFloat toMarkerY   = _drawableHeight - SEGMENT_OFFSET;
    CGPoint toMarker    = CGPointMake(toMarkerX, toMarkerY);
    
    CGFloat rightMarkerX = _rightMarker.x - _drawableLeft;
    CGFloat leftMarkerX = _leftMarker.x - _drawableLeft;
    
    // _segmentView 생성.
    if (_segmentUsesCustomImage) {
        
        if (_curved) { // 짧은 선 이미지 + 중간 선 이미지 + 곡선 이미지
            _segmentView = [[UIView alloc] initWithFrame:CGRectMake(segmentLeft, segmentTop, segmentWidth, segmentHeight)];
            
            // 중간 선 이미지뷰.
            CGFloat middleSegLeft = _leftToRight? CURVE_WIDTH : 0;
            UIImageView *middleSegImageView =
                [[UIImageView alloc] initWithFrame:CGRectMake(middleSegLeft, 0, MIDDLE_SEGMENT, SEGMENT_HEIGHT)];
            middleSegImageView.image = [UIImage imageNamed:_mediumImageName];
            
            // 곡선 이미지뷰.
            CGFloat curveSegLeft = _leftToRight? 0 : MIDDLE_SEGMENT;
            UIImageView *curveSegImageView =
                [[UIImageView alloc] initWithFrame:CGRectMake(curveSegLeft, 0, segmentWidth - MIDDLE_SEGMENT, segmentHeight)];
            curveSegImageView.image = [UIImage imageNamed:_curveImageName];
            if (!_leftToRight) curveSegImageView.transform = CGAffineTransformMakeScale(-1, 1);
            
            // 짧은 선 이미지뷰.
            CGFloat shortSegLeft = _leftToRight? CURVE_WIDTH : MIDDLE_SEGMENT - SHORT_SEGMENT;
            CGFloat shortSegTop = segmentHeight - SEGMENT_HEIGHT;
            UIImageView *shortSegImageView =
                [[UIImageView alloc] initWithFrame:CGRectMake(shortSegLeft, shortSegTop, SHORT_SEGMENT, SEGMENT_HEIGHT)];
            shortSegImageView.image = [UIImage imageNamed:_shortImageName];
            
            [_segmentView addSubview:middleSegImageView];
            [_segmentView addSubview:curveSegImageView];
            [_segmentView addSubview:shortSegImageView];

        } else { // 긴 선 이미지
            UIImage *segmentImage= [UIImage imageNamed:_longImageName];
            _segmentView = [[UIImageView alloc] initWithImage:segmentImage];
            _segmentView.frame = CGRectMake(segmentLeft, segmentTop, segmentWidth, segmentHeight);
        }
    
    } else { // 삽입된 이미지 없이 직접 디폴트 세그먼트 그릴 때.
        
        _segmentView = [[UIView alloc] initWithFrame:CGRectMake(segmentLeft, segmentTop, segmentWidth, segmentHeight)];
        UIBezierPath *segmentPath = [UIBezierPath bezierPath];
        [segmentPath moveToPoint:fromMarker];
        
        if (_curved) { // 디폴트 세그먼트가 커브일 때.
            
            CGFloat arcCenterX = _leftToRight? leftMarkerX - MIDDLE_SEGMENT : rightMarkerX + MIDDLE_SEGMENT;
            CGPoint curveStartPoint = CGPointMake(arcCenterX, fromMarkerY);
            CGPoint arcCenter = CGPointMake(arcCenterX, fromMarkerY + curveRadius);
            
            [segmentPath addLineToPoint:curveStartPoint]; // 중간선.
            [segmentPath addArcWithCenter:arcCenter radius:curveRadius startAngle:3*M_PI/2.0 endAngle:M_PI_2 clockwise:!_leftToRight];
            [segmentPath addLineToPoint:toMarker]; // 짧은선.
            
        } else { // 디폴트 세그먼트가 직선일 때.
            [segmentPath addLineToPoint:toMarker];
        }
        
        CAShapeLayer *segmentLayer = [CAShapeLayer layer];
        [segmentLayer setPath:segmentPath.CGPath];
        [segmentLayer setStrokeColor:[LINE_COLOR CGColor]];
        [segmentLayer setLineWidth:LINE_WIDTH];
        [segmentLayer setFillColor:[[UIColor clearColor] CGColor]];
        
        [_segmentView.layer addSublayer:segmentLayer];
    }
}

- (void) initializeSegmentIconView {
    
    // Segment Icon의 frame을 구하는 로직.
    CGFloat iconLeft;
    if (_curved) {
        iconLeft = _leftToRight? 0 : _drawableWidth - SEGMENT_ICON_SIZE;
    } else {
        iconLeft = _drawableWidth/2 - SEGMENT_ICON_SIZE/2.0;
    }
    
    CGFloat iconTop;
    
    // _segmentIconView 생성.
    UIImage *iconImage = [UIImage imageNamed:_iconImageName];
    
    if (_curved) {
        iconTop = LINE_GAP - SEGMENT_ICON_SIZE/2.0; // 0 + LINE_GAP == 커브 vertical 중간.
    } else {
        iconTop = _drawableHeight - SEGMENT_ICON_SIZE;
        if (!_segmentUsesCustomImage) iconTop -= LINE_WIDTH; // Segment와 겹쳐서 LINE_WIDTH만큼 빼준다.
    }
    
    _segmentIconView = [[UIImageView alloc] initWithImage:iconImage];
    _segmentIconView.frame = CGRectMake(iconLeft, iconTop, SEGMENT_ICON_SIZE, SEGMENT_ICON_SIZE);
    
    [_segmentIconView setBackgroundColor:[UIColor clearColor]];
}

@end
