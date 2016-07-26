//  VLOPathAnimationMaker.m


#import "VLOPathAnimationMaker.h"
#import "UIFont+VLOExtension.h"

@interface VLOPathAnimationMaker()

@property (strong, nonatomic) CALayer *animationLayer;
@property (strong, nonatomic) VLOPathMaker *pathMaker;
@property (strong, nonatomic) UIView *receivedView;
@property (strong, nonatomic) NSArray *markerList;
@end

@implementation VLOPathAnimationMaker

- (id) initWithView:(UIView *)summaryView andMarkerList:(NSArray *)markerList {
    self = [super init];
    _receivedView = summaryView;
    _animationLayer = [[CALayer alloc] init];
    _pathMaker = [[VLOPathMaker alloc] init];
    [_receivedView.layer addSublayer:_animationLayer];
    _markerList = markerList;
    return self;
}

- (void) animatePath {
    [self eraseAll];
    [self drawFromMarkerArray:_markerList];
}

- (void) drawFromMarkerArray:(NSArray *)markerList {
    
    if (markerList.count < 1) {
        return;
    }
    
    CGFloat totalDuration = 0;
    CGFloat actualWidth = _receivedView.bounds.size.width - MARKER_SIZE * 2;
    
    VLOMarker *firstMarkerOfSameDay;

    for (NSInteger i = 0; i < markerList.count; i++) {
        
        CGFloat durationLeft = 0;
        CGFloat durationRight = 0;
        
        // 새로운 path 생성.
        VLOMarker *prevMarker = (i == 0) ? nil : [markerList objectAtIndex:i-1];
        VLOMarker *currMarker = [markerList objectAtIndex:i];
        VLOMarker *nextMarker = (i == markerList.count - 1) ? nil : [markerList objectAtIndex:i+1];
        
        //UIBezierPath *newPath = [_pathMaker pathBetweenPoint:currPoint point:nextPoint];
        
        // 마커 애니메이션 추가.
        [self addMarkerAnimation:currMarker delay:totalDuration color:currMarker.color];
        
        if (prevMarker) {
            
            // 마커의 왼쪽 path를 그립니다. 한 쪽만 점선일 수 있기 때문에 나눠 그립니다.
            UIBezierPath *leftPath = [self pathBetweenMarker1:currMarker andMarker2:prevMarker leftSide:YES];
            CGFloat durationFractionLeft = [VLOMarker distanceBetweenMarker1:currMarker Marker2:prevMarker] / actualWidth;
            durationLeft = LINE_ANIMATION_DURATION * durationFractionLeft;
            
            // 왼쪽 Path 애니메이션 추가.
            [self addPathAnimation:leftPath
                          duration:durationLeft
                             delay:totalDuration
                             color:currMarker.color
                            dotted:currMarker.dottedLeft];
        } else {
            firstMarkerOfSameDay = currMarker;
        }
        
        totalDuration += durationLeft;
        
        if (nextMarker) {
            
            // 머커의 오른쪽 path를 그립니다.
            UIBezierPath *rightPath = [self pathBetweenMarker1:currMarker andMarker2:nextMarker leftSide:NO];
            CGFloat durationFractionRight = [VLOMarker distanceBetweenMarker1:currMarker Marker2:nextMarker] / actualWidth;
            durationRight = LINE_ANIMATION_DURATION * durationFractionRight;
            
            // 오른쪽 Path 애니메이션 추가.
            [self addPathAnimation:rightPath
                          duration:durationRight
                             delay:totalDuration
                             color:currMarker.color
                            dotted:currMarker.dottedRight];
            
            // 다음 마커와 날짜가 같지 않다면 date label의 위치를 계산해 추가하고 firstMarkerOfSameDay를 리셋합니다.
            if ([currMarker.day integerValue] != [nextMarker.day integerValue]) {
                [self addDayLabelAnimation:currMarker firstMarker:firstMarkerOfSameDay delay:totalDuration];
                firstMarkerOfSameDay = nextMarker;
            }
            
        } else { // 마지막 마커일 땐 항상 date label을 추가합니다.
            [self addDayLabelAnimation:currMarker firstMarker:firstMarkerOfSameDay delay:totalDuration];
        }
        
        totalDuration += durationRight;
    }
}

- (void) addPathAnimation:(UIBezierPath *)path
                 duration:(CGFloat)duration
                    delay:(CGFloat)delay
                    color:(UIColor *)color
                   dotted:(BOOL)dotted {
    
    // Path 모양 추가.
    CAShapeLayer *pathLayer = [[CAShapeLayer alloc] init];
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = color.CGColor;
    pathLayer.fillColor = [UIColor clearColor].CGColor;
    pathLayer.strokeStart = 0.0;
    pathLayer.strokeEnd = 1.0;
    pathLayer.lineJoin = kCALineJoinRound;
    pathLayer.lineCap = kCALineCapRound;
    
    if (dotted) {
        NSArray *dashes = [NSArray arrayWithObjects:@(1), @(2), nil];
        [pathLayer setLineDashPattern:dashes];
        pathLayer.lineWidth = 1.0;
    } else {
        pathLayer.lineWidth = LINE_WIDTH;
    }
    
    [_animationLayer addSublayer:pathLayer];
    
    // Path 애니메이션 추가.
    CABasicAnimation *pathDrawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathDrawAnimation.duration  = duration;
    pathDrawAnimation.beginTime = CACurrentMediaTime() + delay;
    pathDrawAnimation.fillMode = kCAFillModeBackwards;
    pathDrawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathDrawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    [pathLayer addAnimation:pathDrawAnimation forKey:@"pathAnimation"];
}

- (UIBezierPath *) pathBetweenMarker1:(VLOMarker *)currMarker andMarker2:(VLOMarker *)otherMarker leftSide:(BOOL)leftSide {
    UIBezierPath *newPath = [UIBezierPath bezierPath];
    
    CGFloat midX = (currMarker.x + otherMarker.x) / 2;
    CGFloat midY = (currMarker.y + otherMarker.y) / 2;
    CGPoint midPoint = CGPointMake(midX, midY);
    
    CGPoint currPoint = CGPointMake(currMarker.x, currMarker.y);

    CGPoint startPoint = (leftSide) ? midPoint : currPoint;
    CGPoint endPoint = (leftSide) ? currPoint : midPoint;
        
    [newPath moveToPoint:startPoint];
    [newPath addLineToPoint:endPoint];
    
    return newPath;
}


- (void) addMarkerAnimation:(VLOMarker *)marker delay:(CGFloat)delay color:(UIColor *)color {
    UIView *markerView = [marker getMarkerViewWithColor:color];
    
    // 마커 애니메이션.
    markerView.alpha = 0;
    markerView.hidden = NO;
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
    [UIView animateWithDuration:MARKER_ANIMATION_DURATION delay:delay options:options
                     animations:^{
                         markerView.alpha = 1;
                         CGFloat markerLeft = markerView.frame.origin.x;
                         CGFloat markerTop = markerView.frame.origin.y;
                         CGFloat markerWidth = markerView.frame.size.width;
                         CGFloat markerHeight = markerView.frame.size.height;
                         [markerView setFrame:CGRectMake(markerLeft, markerTop + MARKER_TRAVEL, markerWidth, markerHeight)];
                     } completion: nil];
    [_receivedView addSubview: markerView];
}

- (void) addDayLabelAnimation:(VLOMarker *)marker firstMarker:(VLOMarker *)firstMarker delay:(CGFloat)delay {
    CGFloat labelX = (marker.x + firstMarker.x) / 2 - MARKER_LABEL_WIDTH / 2;
    CGFloat labelY = marker.y + MARKER_TRAVEL*2;
    
    UILabel *dayLabel = [[UILabel alloc]initWithFrame:
                         CGRectMake(labelX, labelY, MARKER_LABEL_WIDTH, MARKER_LABEL_HEIGHT)];
    dayLabel.text = [NSString stringWithFormat:@"Day %li", [marker.day integerValue]];
    dayLabel.font = [UIFont museoSans700WithSize:10.0f];
    dayLabel.textAlignment = NSTextAlignmentCenter;
    dayLabel.textColor = DAY_LABEL_COLOR;
    [dayLabel sizeToFit];
    
    // 마커 애니메이션.
    dayLabel.alpha = 0;
    dayLabel.hidden = NO;
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
    [UIView animateWithDuration:MARKER_ANIMATION_DURATION delay:delay options:options
                     animations:^{
                         dayLabel.alpha = 1;
                         CGFloat dateLeft = dayLabel.frame.origin.x;
                         CGFloat dateTop = dayLabel.frame.origin.y;
                         CGFloat dateWidth = dayLabel.frame.size.width;
                         CGFloat dateHeight = dayLabel.frame.size.height;
                         [dayLabel setFrame:CGRectMake(dateLeft, dateTop - MARKER_TRAVEL, dateWidth, dateHeight)];
                     } completion: nil];
    [_receivedView addSubview: dayLabel];
}

- (void) eraseAll {
    _animationLayer.sublayers = nil;
    
    // 마커 제거
    for (UIView *subView in _receivedView.subviews) {
        [subView removeFromSuperview];
    }
}

@end

