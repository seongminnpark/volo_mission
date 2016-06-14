//
//  ViewController.m
//  VLOPathAnimation
//
//  Created by Seongmin on 6/13/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    _mapLineMaker = [[VLOMapLineMaker alloc] init];
    
    _animationLayer = [[CALayer alloc] init];
    [self.view.layer addSublayer:_animationLayer];

    // 버튼
    CGFloat deleteButtonLeft = BUTTON_PADDING;
    CGFloat deleteButtonWidth = _screenWidth - BUTTON_PADDING * 2;
    CGFloat deleteButtonHeight = _screenHeight * BUTTON_HEIGHT_RATIO;
    CGFloat deleteButtonTop = _screenHeight - deleteButtonHeight - BUTTON_PADDING;
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [deleteButton setFrame:CGRectMake(deleteButtonLeft, deleteButtonTop,
                                      deleteButtonWidth, deleteButtonHeight)];
    [deleteButton setTitle:@"랜덤한 좌표 생성" forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(eraseAll)
           forControlEvents:UIControlEventTouchUpInside];
    deleteButton.backgroundColor=[UIColor grayColor];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:deleteButton];
    
    // 데모
    //[self startDemo];
    
}

- (void) startDemo {
    // 2~7개의 마커
    NSInteger numMarkers = arc4random_uniform(6) + 2;
    
    NSMutableArray *markerList = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < numMarkers; i ++) {
        CGFloat sideMargin = (_screenWidth-BUTTON_PADDING*2) / (numMarkers*2);
        Marker *marker = [[Marker alloc] init];
        marker.x = (sideMargin * 2) * (i+1) - arc4random_uniform(sideMargin*2) + BUTTON_PADDING;
        marker.y = 150 + arc4random_uniform(40);
        
        [markerList addObject:marker];
    }

    [self drawFromMarkerArray:markerList];
}

- (void) drawFromMarkerArray:(NSArray *)markerList {
    CGFloat totalDuration = 0;
    for (NSInteger i = 1; i < markerList.count; i++) {
        // 새로운 path 생성.
        Marker *prevMarker = [markerList objectAtIndex:i-1];
        Marker *currMarker = [markerList objectAtIndex:i];
        CGPoint prevPoint = CGPointMake(prevMarker.x, prevMarker.y);
        CGPoint currPoint = CGPointMake(currMarker.x, currMarker.y);
        UIBezierPath *newPath = [_mapLineMaker mapLineBetweenPoint:prevPoint point:currPoint];
        
        CGFloat duration = WHOLE_DURATION * (currPoint.x - prevPoint.x) / _screenWidth;
        
        // Path 애니메이션 추가.
        [self addPathAnimation:newPath duration:duration delay:totalDuration];
        
        // 마커 애니메이션 추가.
        Marker *marker = (Marker *) [markerList objectAtIndex:i-1];
        [self addMarkerAnimation:marker delay:totalDuration];
        
        totalDuration += duration;
        
    }
    // 마지막 마커 추가.
    Marker *marker = (Marker *) [markerList objectAtIndex:markerList.count-1];
    [self addMarkerAnimation:marker delay:totalDuration];
}

- (void) addPathAnimation:(UIBezierPath *)path duration:(CGFloat)duration delay:(CGFloat)delay {
    CAShapeLayer *pathLayer = [[CAShapeLayer alloc] init];
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [UIColor blackColor].CGColor;
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
    // 마커 생성.
    UIImageView *markerImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"marker.png"]];
    CGFloat markerLeft = marker.x - MARKER_SIZE/2;
    CGFloat markerTop = marker.y - MARKER_SIZE - 8;
    [markerImageView setFrame:CGRectMake(markerLeft, markerTop, MARKER_SIZE, MARKER_SIZE)];
    
    // 마커 애니메이션.
    markerImageView.alpha = 0;
    markerImageView.hidden = NO;
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
    [UIView animateWithDuration:MARKER_ANIMATION_DURATION delay:delay options:options
                     animations:^{
                         markerImageView.alpha = 1;
                         [markerImageView setFrame:
                          CGRectMake(markerLeft,markerTop + MARKER_TRAVEL,MARKER_SIZE,MARKER_SIZE)];
                     } completion: nil];
    
    [self.view addSubview: markerImageView];
}

- (void) eraseAll {
    _animationLayer.sublayers = nil;
    
    // 마커 제거
    for (UIView *imageView in self.view.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            [imageView removeFromSuperview];
        }
    }
    
    [self startDemo];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
