//
//  ViewController.m
//  mapline
//
//  Created by Seongmin on 6/7/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;;
    
    _curveLength = _screenWidth - CURVE_HORIZONTAL_PADDING * 2;

    CGFloat initialCurveY = _screenHeight * CURVE_VERTICAL_RATIO;
    _start = CGPointMake(CURVE_HORIZONTAL_PADDING, initialCurveY);
    _end = CGPointMake(CURVE_HORIZONTAL_PADDING + _curveLength, initialCurveY);
    
    _mapLineMaker = [[VLOMapLineMaker alloc] init];
    
    _testView = [[TestView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    [_testView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_testView];
    
    // 애니메이션 레이어 설정
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.strokeColor = [[UIColor blackColor] CGColor];
    _shapeLayer.fillColor = nil;
    _shapeLayer.lineWidth = LINE_WIDTH;
    _shapeLayer.lineJoin = kCALineJoinBevel;
    [self.view.layer addSublayer:_shapeLayer];
    
    // Add new random curve button.
    CGFloat bigButtonLeft = BUTTON_PADDING;
    CGFloat bigButtonTop = _screenHeight * BUTTON_TOP_RATIO;
    CGFloat bigButtonWidth = (_screenWidth - BUTTON_PADDING * 2.5) / GOLDEN_RATIO;
    CGFloat bigButtonHeight = _screenHeight * BUTTON_HEIGHT_RATIO;
    UIButton *bigButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bigButton setFrame:CGRectMake(bigButtonLeft, bigButtonTop, bigButtonWidth, bigButtonHeight)];
    [bigButton setTitle:@"New curve" forState:UIControlStateNormal];
    [bigButton addTarget:self action:@selector(testMapLineMaker)
               forControlEvents:UIControlEventTouchUpInside];
    bigButton.backgroundColor=[UIColor grayColor];
    [self.view addSubview:bigButton];
    
    // Add animate button.
    CGFloat smallButtonLeft = BUTTON_PADDING + bigButtonWidth + BUTTON_PADDING/2;
    CGFloat smallButtonWidth = _screenWidth - BUTTON_PADDING * 2.5 - bigButtonWidth;
    UIButton *smallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [smallButton setFrame:CGRectMake(smallButtonLeft, bigButtonTop, smallButtonWidth, bigButtonHeight)];
    [smallButton setTitle:@"Animate" forState:UIControlStateNormal];
    [smallButton addTarget:self action:@selector(animateCurve)
               forControlEvents:UIControlEventTouchUpInside];
    smallButton.backgroundColor=[UIColor lightGrayColor];
    
    // Add slider.
    CGFloat sliderLeft = CURVE_HORIZONTAL_PADDING;
    CGFloat sliderTop = _screenHeight * SLIDER_VERTICAL_RATIO;
    CGRect sliderFrame = CGRectMake(sliderLeft, sliderTop,
                                    _screenWidth - CURVE_HORIZONTAL_PADDING*2,bigButtonHeight);
    _slider = [[UISlider alloc] initWithFrame:sliderFrame];
    _slider.minimumTrackTintColor = [UIColor grayColor];
    _slider.minimumValue = 0;
    _slider.maximumValue = _curveLength;
    _slider.value = _slider.maximumValue;
    [_slider addTarget:self action:@selector(testMapLineMaker)
      forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider];
    
    [self testMapLineMaker];
    
    // 애니메이션 버튼의 콜백은 path가 필요하기 때문에 제일 마지막에 호출합니다.
    [self.view addSubview:smallButton];
    
}

- (void)testMapLineMaker {
    [_shapeLayer setHidden:YES];
    [_testView setHidden:NO];
    
    // Create random starting points.
    _curveLength = _slider.value;
    
    CGFloat curveY = _screenHeight * CURVE_VERTICAL_RATIO;
    _start.y = arc4random_uniform(CURVE_VERTICAL_VARIATION) + curveY;
    _end.x = CURVE_HORIZONTAL_PADDING + _curveLength;
    _end.y = arc4random_uniform(CURVE_VERTICAL_VARIATION) + curveY;
    
    //_testView.path = [_mapLineMaker mapLineBetweenPoint:_start point:_end];
    NSArray *pointList = [_mapLineMaker createPointsBetweenPoint:_start point:_end];
    _testView.path = [_mapLineMaker interpolatePoints:pointList];
    _testView.dots = pointList;
    
    [_testView setNeedsDisplay];
}

- (void) animateCurve {
    [_testView setHidden:YES];
    [_shapeLayer setHidden:NO];
    
    _shapeLayer.path = _testView.path.CGPath;
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.7;
    pathAnimation.fromValue = @(0.0f);
    pathAnimation.toValue = @(1.0f);
    [_shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
