//
//  VLOSummaryMarker.m
//  Volo
//
//  Created by Seongmin on 7/29/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import "VLOSummaryMarker.h"

@interface VLOSummaryMarker ()

@property (nonatomic) VLOLog *log;
@property (nonatomic) VLOPlace *place;

@property (nonatomic, strong) UIView *markerView;
@property (nonatomic, strong) UIView *markerIconView;
@property (nonatomic, strong) UILabel *markerLabel;

@property () BOOL markerUsesCustomImage;
@property () BOOL markerImageIsDay;
@property () BOOL markerImageIsFlag;

@property () NSString *markerImageName;

@property () CGFloat drawableLeft;
@property () CGFloat drawableTop;
@property () CGFloat drawableWidth;
@property () CGFloat drawableHeight;

@end

@implementation VLOSummaryMarker

- (id) initWithLog:(VLOLog *)log andPlace:(VLOPlace *)place {
    self = [super init];
    
    _log = log;
    _place = place;
    
    _markerUsesCustomImage = NO;
    _markerImageIsDay = NO;
    _markerImageIsFlag = NO;
    _hasMarkerIcon = NO;
    
    return self;
}

- (void) setMarkerImage:(NSString *)markerImageName isDay:(BOOL)isDay isFlag:(BOOL)isFlag {
    _markerImageIsDay = isDay;
    _markerImageIsFlag = isFlag;
    _markerUsesCustomImage = YES;
    _markerImageName = markerImageName;
}

- (void) setMarkerIconImage:(NSString *)iconImageName {
    _hasMarkerIcon = YES;
    _iconImageName = iconImageName;
}

- (void) calculateReferenceFrame {
    // 모든 컴포넌트에 공유되는 Frame 변수들.
    _drawableLeft   = _x - MARKER_ICON_WIDTH/2.0;
    _drawableTop    = _y + SEGMENT_OFFSET - MARKER_ICON_HEIGHT;
    _drawableWidth  = MARKER_ICON_WIDTH;
    _drawableHeight = MARKER_ICON_HEIGHT + MARKER_LABEL_HEIGHT;
}

- (UIView *) getDrawableView {
    
    [self calculateReferenceFrame];

    // 마커와 마커 장식 묶음이 담길 뷰 생성.
    UIButton *drawableView = [[UIButton alloc] initWithFrame:CGRectMake(_drawableLeft, _drawableTop, _drawableWidth, _drawableHeight)];

    // 마커 레이블.
    [self initializeMarkerLabel];
    [drawableView addSubview:_markerLabel];
    
    // 마커 아이콘.
    if (_hasMarkerIcon) {
        [self initializeMarkerIconView];
        [drawableView addSubview:_markerIconView];
    }
    
    BOOL drawMarker = !_hasMarkerIcon || _markerImageIsDay || _markerImageIsFlag;
    
    // 마커 점.
    if (drawMarker) {
        [self initializeMarkerView];
        [drawableView addSubview:_markerView];
    }

    return drawableView;
}

- (UIView *) getMarkerView {
    [self calculateReferenceFrame];
    [self initializeMarkerView];
    
    CGFloat left = _markerView.frame.origin.x + _drawableLeft;
    CGFloat top = _markerView.frame.origin.y + _drawableTop;
    CGFloat width = _markerView.frame.size.width;
    CGFloat height = _markerView.frame.size.height;
    _markerView.frame = CGRectMake(left, top, width, height);
    
    return _markerView;
}

- (UIView *) getMarkerIconView {
    [self calculateReferenceFrame];
    [self initializeMarkerIconView];
    
    CGFloat left = _markerIconView.frame.origin.x + _drawableLeft;
    CGFloat top = _markerIconView.frame.origin.y + _drawableTop;
    CGFloat width = _markerIconView.frame.size.width;
    CGFloat height = _markerIconView.frame.size.height;
    _markerIconView.frame = CGRectMake(left, top, width, height);
    
    return _markerIconView;
}

- (UIView *) getMarkerLabel {
    [self calculateReferenceFrame];
    [self initializeMarkerLabel];
    
    CGFloat left = _markerLabel.frame.origin.x + _drawableLeft;
    CGFloat top = _markerLabel.frame.origin.y + _drawableTop;
    CGFloat width = _markerLabel.frame.size.width;
    CGFloat height = _markerLabel.frame.size.height;
    _markerLabel.frame = CGRectMake(left, top, width, height);
    
    return _markerLabel;
}

- (void) initializeMarkerView {
    
    CGFloat markerTop, markerLeft, markerWidth, markerImageWidth, markerImageHeight;
    
    
    if (_markerImageIsDay) {
        
        NSString *dayText = [NSString stringWithFormat:@"%@일차", _day];
        UIFont *font = [UIFont systemFontOfSize:MARKER_LABEL_HEIGHT*0.8];
        
        CGSize dayTextSize = [dayText sizeWithAttributes:@{ NSFontAttributeName : font }];
        
        CGFloat dayLabelWidth = dayTextSize.width + DAY_LABEL_PADDING*2;
        
        markerLeft  = _drawableWidth/2.0 - dayLabelWidth/2.0;
        markerTop   = _drawableHeight - MARKER_LABEL_HEIGHT - MARKER_IMAGE_SIZE;
        markerWidth = dayLabelWidth;
        
        // 레이블이 담길 검정색 상자
        _markerView = [[UIView alloc] initWithFrame:CGRectMake(markerLeft, markerTop, markerWidth, MARKER_LABEL_HEIGHT)];
        _markerView.layer.backgroundColor = [UIColor blackColor].CGColor;
        _markerView.layer.cornerRadius = 3.0;
        
        // "몇 일차" 레이블
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:
                             CGRectMake(0, 0, _markerView.frame.size.width, _markerView.frame.size.height)];
        dayLabel.text = dayText;
        dayLabel.textColor = [UIColor whiteColor];
        dayLabel.textAlignment = NSTextAlignmentCenter;
        // 0.8은 글씨가 레이블 속에 꽉 차지 않도록 임의로 정한 숫자입니다.
        [dayLabel setFont:font];
        
        [_markerView addSubview: dayLabel];
        
        
    } else if (_markerUsesCustomImage) {
        
        markerLeft  = _drawableWidth/2.0 - MARKER_IMAGE_SIZE/2.0;
        markerTop   = _drawableHeight - MARKER_LABEL_HEIGHT - MARKER_IMAGE_SIZE;
        markerWidth = MARKER_IMAGE_SIZE;
        
        _markerView = [[UIView alloc] initWithFrame:CGRectMake(markerLeft, markerTop, markerWidth, MARKER_IMAGE_SIZE)];
        _markerView.userInteractionEnabled = NO;
        
        // 마커 그림
        markerImageWidth = _markerImageIsFlag?  MARKER_FLAG_SIZE : MARKER_IMAGE_SIZE;
        UIImage *markerImage = [UIImage imageNamed:_markerImageName];
        UIImageView *markerImageView = [[UIImageView alloc] initWithImage:markerImage];
        markerImageHeight = _markerImageIsDay? markerImage.size.height : markerImageWidth;
        CGFloat imageViewLeft = markerWidth/2.0 - markerImageWidth/2.0;
        CGFloat imageViewTop = MARKER_IMAGE_SIZE/2.0 - markerImageHeight/2.0;
        markerImageView.frame = CGRectMake(imageViewLeft, imageViewTop, markerImageWidth, markerImageHeight);
        
        [_markerView addSubview:markerImageView];
        
        if (_markerImageIsFlag) {
            
            // 마커 테두리.
            UIBezierPath *rimPath = [UIBezierPath bezierPathWithOvalInRect:
                                     CGRectMake(imageViewLeft, imageViewTop, MARKER_FLAG_SIZE, MARKER_FLAG_SIZE)];
            CAShapeLayer *rimLayer = [CAShapeLayer layer];
            [rimLayer setFillColor:[UIColor clearColor].CGColor];
            [rimLayer setPath:rimPath.CGPath];
            [rimLayer setLineWidth:1.5]; // PL님이 1포인트로 하자고 하셨습니다.
            [rimLayer setStrokeColor:[UIColor blackColor].CGColor];
            [_markerView.layer addSublayer:rimLayer];
        }
        
    } else {
        
        markerLeft = _drawableWidth/2.0 - MARKER_IMAGE_SIZE/2.0;
        markerTop  = _drawableHeight - MARKER_LABEL_HEIGHT - MARKER_IMAGE_SIZE;
        
        _markerView = [[UIView alloc] initWithFrame:CGRectMake(markerLeft, markerTop, MARKER_IMAGE_SIZE, MARKER_IMAGE_SIZE)];
        
        CGFloat circleCenter = MARKER_IMAGE_SIZE/2.0 - MARKER_SIZE/2.0;
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(circleCenter, circleCenter, MARKER_SIZE, MARKER_SIZE)];
        
        CAShapeLayer *markerLayer = [CAShapeLayer layer];
        [markerLayer setPath:circlePath.CGPath];
        
        [_markerView.layer addSublayer:markerLayer];
        
        if (_hasMarkerIcon) {
            [markerLayer setStrokeColor:[VOLO_COLOR CGColor]];
            [markerLayer setFillColor:[VOLO_COLOR CGColor]];
        } else {
            [markerLayer setStrokeColor:[LINE_COLOR CGColor]];
            [markerLayer setFillColor:[LINE_COLOR CGColor]];
        }
        [markerLayer setLineWidth:LINE_WIDTH];
    }
}

- (void) initializeMarkerIconView {

    CGFloat imageViewLeft, imageViewTop;
    
    UIImage *iconImage = [UIImage imageNamed:_iconImageName];
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
    [iconImageView setBackgroundColor:[UIColor clearColor]];
    
    imageViewLeft = _drawableWidth/2 - MARKER_ICON_WIDTH/2.0;
    imageViewTop  = 0;
    iconImageView.frame = CGRectMake(imageViewLeft, imageViewTop, MARKER_ICON_WIDTH, MARKER_ICON_HEIGHT);

    _markerIconView = iconImageView;
    _markerIconView.userInteractionEnabled = NO;
}

- (void) initializeMarkerLabel {
  
    CGFloat labelWidth = _drawableWidth * 1.5; // 1.5는 옆 마커를 침범하지 않는 적당한 수치 같아 임의로 정한 숫자입니다.
    CGFloat labelLeft  = _drawableWidth/2.0 - labelWidth/2.0;
    CGFloat labelTop   = _drawableHeight - MARKER_LABEL_HEIGHT + 2; // PL님이 레이블 2포인트 내리자고 하셨습니다.
    
    _markerLabel = [[UILabel alloc] initWithFrame: CGRectMake(labelLeft, labelTop, labelWidth, MARKER_LABEL_HEIGHT)];
    _markerLabel.text = _place.name;
    _markerLabel.textAlignment = NSTextAlignmentCenter;
    _markerLabel.textColor = [UIColor vlo_darkGrayColor];
    [_markerLabel setFont:[UIFont systemFontOfSize:MARKER_LABEL_HEIGHT]];
}

- (VLOPlace *) getPlace {
    return _place;
}

@end
