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

@property () NSString *longImageName;
@property () NSString *middleImageName;
@property () NSString *shortImageName;
@property () NSString *curveImageName;
@property () NSString *contentImageName;

@property () CGFloat drawableLeft;
@property () CGFloat drawableTop;
@property () CGFloat drawableWidth;
@property () CGFloat drawableHeight;

@property (strong, nonatomic) VLOSummaryMarker *leftMarker;
@property (strong, nonatomic) VLOSummaryMarker *rightMarker;

@end

@implementation VLOSummarySegment

- (id) initFrom:(VLOSummaryMarker *)fromMarker to:(VLOSummaryMarker *)toMarker {
    self = [super init];
    _fromMarker = fromMarker;
    _toMarker = toMarker;
    _curved = NO;
    _leftToRight = YES;
    _hasSegmentContent = NO;
    _leftMarker  = (fromMarker.x < toMarker.x) ? fromMarker : toMarker;
    _rightMarker = (fromMarker.x < toMarker.x) ? toMarker : fromMarker;
    return self;
}

- (void) setSegmentImageLong:(NSString *)longImage
                      middle:(NSString *)middleImage
                       shortt:(NSString *)shortImage
                       curve:(NSString *)curveImage {
    
    _segmentUsesCustomImage = YES;
    
    _longImageName = longImage;
    _middleImageName = middleImage;
    _shortImageName = shortImage;
    _curveImageName = curveImage;
}

- (void) setSegmentContentImage:(NSString *)contentImageName {
    _hasSegmentContent = YES;
    _segmentContentUsesCustomImage = YES;
    _contentImageName = contentImageName;
}

- (UIView *) getDrawableView {
    
    CGFloat xDiff = fabs(_toMarker.x - _fromMarker.x);
    CGFloat curveRadius = fabs(_toMarker.y - _fromMarker.y)/2.0;
    
    // 모든 컴포넌트에 공유되는 Frame 변수들.
    if (_curved) {
        _drawableLeft = _leftToRight? _leftMarker.x - SHORT_SEGMENT - curveRadius - SEGMENT_CONTENT_SIZE/2 : _leftMarker.x;
    } else {
        _drawableLeft = _leftMarker.x;
    }
    _drawableTop    = _curved? _fromMarker.y - SEGMENT_HEIGHT/2.0: _fromMarker.y - SEGMENT_CONTENT_SIZE + SEGMENT_HEIGHT/2.0;
    _drawableWidth  = _curved? MIDDLE_SEGMENT + curveRadius + SEGMENT_CONTENT_SIZE/2.0 : xDiff;
    _drawableHeight = _curved? _toMarker.y - _fromMarker.y + SEGMENT_HEIGHT : MAX(SEGMENT_CONTENT_SIZE, SEGMENT_HEIGHT);
    
    // 선과 선 장식 생성.
    [self initializeSegmentView];
    if (_hasSegmentContent) [self initializeSegmentContentView];
    
    // 선과 선 장식 묶음이 담길 뷰 생성.
    UIView *drawableView = [[UIView alloc] initWithFrame:CGRectMake(_drawableLeft, _drawableTop, _drawableWidth, _drawableHeight)];
    [drawableView addSubview:_segmentView];
    if (_hasSegmentContent) [drawableView addSubview:_segmentContentView];

    return drawableView;
}

- (void) initializeSegmentView {
    if (_segmentView) return;
    
    CGFloat curveRadius = fabs(_toMarker.y - _fromMarker.y) / 2.0;
    CGFloat segmentLeft   = (_curved && _leftToRight)? SEGMENT_CONTENT_SIZE/2.0: 0;
    CGFloat segmentTop    = _curved? 0 : _drawableHeight - SEGMENT_HEIGHT;
    CGFloat segmentWidth  = _curved? _drawableWidth - SEGMENT_CONTENT_SIZE/2.0 : _drawableWidth;
    CGFloat segmentHeight = _curved? _drawableHeight : SEGMENT_HEIGHT;
    
    // (0,0)에서 시작하는 drawable 프레임에 맞춘 fromMarker과 toMarker 좌표.
    CGFloat fromMarkerX = _fromMarker.x - _drawableLeft;
    CGFloat fromMarkerY = SEGMENT_HEIGHT/2.0;
    CGPoint fromMarker  = CGPointMake(fromMarkerX, fromMarkerY);
    
    CGFloat toMarkerX   = _toMarker.x - _drawableLeft;
    CGFloat toMarkerY   = _curved? _drawableHeight - SEGMENT_HEIGHT/2.0 : SEGMENT_HEIGHT/2.0;
    CGPoint toMarker    = CGPointMake(toMarkerX, toMarkerY);
    
    CGFloat rightMarkerX = _rightMarker.x - _drawableLeft;
    CGFloat leftMarkerX = _leftMarker.x - _drawableLeft;
    
    // _segmentView 생성.
    if (_segmentUsesCustomImage) {
        
        if (_curved) { // 짧은 선 이미지 + 중간 선 이미지 + 곡선 이미지
            _segmentView = [[UIView alloc] initWithFrame:CGRectMake(segmentLeft, segmentTop, segmentWidth, segmentHeight)];
            
            // 중간 선 이미지뷰.
            CGFloat middleSegLeft = _leftToRight? curveRadius : 0;
            UIImageView *middleSegImageView =
                [[UIImageView alloc] initWithFrame:CGRectMake(middleSegLeft, 0, MIDDLE_SEGMENT, SEGMENT_HEIGHT)];
            middleSegImageView.image = [UIImage imageNamed:_middleImageName];
            
            // 곡선 이미지뷰.
            CGFloat curveSegLeft = _leftToRight? 0 : MIDDLE_SEGMENT;
            UIImageView *curveSegImageView =
                [[UIImageView alloc] initWithFrame:CGRectMake(curveSegLeft, 0, curveRadius, segmentHeight)];
            curveSegImageView.image = [UIImage imageNamed:_curveImageName];
            
            // 짧은 선 이미지뷰.
            CGFloat shortSegLeft = _leftToRight? curveRadius : MIDDLE_SEGMENT - SHORT_SEGMENT;
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
    
    } else { // 디폴트 세그먼트 그릴 때.
        
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

- (void) initializeSegmentContentView {
    if (_segmentContentView) return;
    
    // Segment Content의 frame을 구하는 로직.
    CGFloat contentLeft;
    if (_curved) {
        contentLeft = _leftToRight? 0 : _drawableWidth - SEGMENT_CONTENT_SIZE;
    } else {
        contentLeft = _drawableWidth/2 - SEGMENT_CONTENT_SIZE/2.0;
    }
    
    CGFloat contentTop;
    
    // _segmentContentView 생성.
    if (_segmentContentUsesCustomImage) {
        
        UIImage *contentImage = [UIImage imageNamed:_contentImageName];
        CGFloat imageWidthHeightRatio = contentImage.size.height / contentImage.size.width;
        CGFloat imageHeight = imageWidthHeightRatio * SEGMENT_CONTENT_SIZE;
        
        if (_curved) {
            contentTop = _drawableHeight/2.0 - imageHeight/2.0;
        } else {
            contentTop = _drawableHeight - imageHeight;
            if (!_segmentUsesCustomImage) contentTop -= LINE_WIDTH; // Segment와 겹쳐서 LINE_WIDTH만큼 빼준다.
        }
        
        _segmentContentView = [[UIImageView alloc] initWithImage:contentImage];
        _segmentContentView.frame = CGRectMake(contentLeft, contentTop, SEGMENT_CONTENT_SIZE, imageHeight);
        if (!_leftToRight) _segmentContentView.transform = CGAffineTransformMakeScale(-1, 1);
        
        [_segmentContentView setBackgroundColor:[UIColor whiteColor]];
        
    } else {
        contentTop = _curved? _drawableHeight/2 - SEGMENT_CONTENT_SIZE/2.0 : 0;
        _segmentContentView = [[UIView alloc] initWithFrame:
                               CGRectMake(contentLeft, contentTop, SEGMENT_CONTENT_SIZE, SEGMENT_CONTENT_SIZE)];
    }

}

@end
