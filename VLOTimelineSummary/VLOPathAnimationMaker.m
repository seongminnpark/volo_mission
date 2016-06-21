//
//  VLOPathAnimationMaker.m
//

#import "VLOPathAnimationMaker.h"

@interface VLOPathAnimationMaker()

@property (strong, nonatomic) CALayer *animationLayer;
@property (strong, nonatomic) VLOPathMaker *pathMaker;
@property (strong, nonatomic) UIView *receivedView;
@property (strong, nonatomic) NSArray *markerList;

@property () CGFloat screenWidth;
@property () CGFloat screenHeight;

@end

@implementation VLOPathAnimationMaker

- (id) initWithView:(UIView *)summaryView andMarkerList:(NSArray *)markerList {
    self = [super init];
    _receivedView = summaryView;
    _animationLayer = [[CALayer alloc] init];
    _pathMaker = [[VLOPathMaker alloc] init];
    [_receivedView.layer addSublayer:_animationLayer];
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    _markerList = markerList;
    return self;
}

- (void) animatePath {
    [self eraseAll];
    [self drawFromMarkerArray:_markerList];
}

- (void) drawFromMarkerArray:(NSArray *)markerList {
    CGFloat totalDuration = 0;
    for (NSInteger i = 1; i < markerList.count; i++) {
        // 새로운 path 생성.
        Marker *prevMarker = [markerList objectAtIndex:i-1];
        Marker *currMarker = [markerList objectAtIndex:i];
        CGPoint prevPoint = CGPointMake(prevMarker.x, prevMarker.y);
        CGPoint currPoint = CGPointMake(currMarker.x, currMarker.y);
        UIBezierPath *newPath = [_pathMaker pathBetweenPoint:prevPoint point:currPoint];
        
        CGFloat duration = ANIMATION_DURATION * (currPoint.x - prevPoint.x) / _screenWidth;
        
        // Path 애니메이션 추가.
        [self addPathAnimation:newPath duration:duration delay:totalDuration];
        
        // 마커 애니메이션 추가.
        Marker *marker = (Marker *) [markerList objectAtIndex:i-1];
        [self addMarkerAnimation:marker delay:totalDuration];
        
        totalDuration += duration;
        
    }
    
    if (markerList.count > 0) {
        // 마지막 마커 추가.
        Marker *marker = (Marker *) [markerList objectAtIndex:markerList.count-1];
        [self addMarkerAnimation:marker delay:totalDuration];
    }
    
}

- (void) addPathAnimation:(UIBezierPath *)path duration:(CGFloat)duration delay:(CGFloat)delay {
    CAShapeLayer *pathLayer = [[CAShapeLayer alloc] init];
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1].CGColor;
    //pathLayer.strokeColor = [UIColor blackColor].CGColor;
    pathLayer.fillColor = [UIColor clearColor].CGColor;
    pathLayer.lineWidth = LINE_WIDTH;
    pathLayer.strokeStart = 0.0;
    pathLayer.strokeEnd = 1.0;
    pathLayer.lineJoin = kCALineJoinBevel;
    [_animationLayer addSublayer:pathLayer];
    
    CABasicAnimation *pathDrawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathDrawAnimation.duration  = duration;
    pathDrawAnimation.beginTime = CACurrentMediaTime() + delay;
    pathDrawAnimation.fillMode = kCAFillModeBackwards;
    pathDrawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathDrawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    [pathLayer addAnimation:pathDrawAnimation forKey:@"strokeEnd"];
}

- (void) addMarkerAnimation:(Marker *)marker delay:(CGFloat)delay {
    UIView *markerView = [marker getMarkerView];
    
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

- (void) eraseAll {
    _animationLayer.sublayers = nil;
    
    // 마커 제거
    for (UIView *subView in _receivedView.subviews) {
        [subView removeFromSuperview];
    }
}

@end

