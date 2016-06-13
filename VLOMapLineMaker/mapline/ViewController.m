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
    _imageMixView = [[ImageMixView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    
    // 포토 라이브러리 띄우는 뷰컨트롤러 생성.
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePickerController.delegate = self;
    
    // 페이스북 쉐어 컨트롤러 셋업.
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        _shareable = YES;
        _shareController =
            [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    } else {
        _shareable = NO;
    }
    
    // 커브 뷰 생성.
    _curveView = [[CurveView alloc] initWithFrame:
                 CGRectMake(0, _screenHeight * CURVE_VERTICAL_RATIO,
                            _screenWidth, CURVE_VERTICAL_VARIATION * 2.5)];
    [_curveView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
    _curveView.opaque = NO;
    
    // 점선 뷰 생성.
    _dotView = [[DotView alloc] initWithFrame:
                 CGRectMake(_curveView.frame.origin.x, _curveView.frame.origin.y - DOTVIEW_OFFSET,
                            _curveView.frame.size.width, _curveView.frame.size.height)];
    [_dotView setBackgroundColor:[UIColor whiteColor]];
    
    // 애니메이션 레이어 설정.
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.position = CGPointMake(_curveView.frame.origin.x, _curveView.frame.origin.y);
    _shapeLayer.strokeColor = [[UIColor blackColor] CGColor];
    _shapeLayer.fillColor = nil;
    _shapeLayer.lineWidth = LINE_WIDTH;
    _shapeLayer.lineJoin = kCALineJoinBevel;
    [self.view.layer addSublayer:_shapeLayer];
    
    // "새로운 커브" 버튼 추가.
    CGFloat bigButtonLeft = BUTTON_PADDING;
    CGFloat bigButtonTop = _screenHeight * BUTTON_TOP_RATIO;
    CGFloat bigButtonWidth = (_screenWidth - BUTTON_PADDING * 2.5) / GOLDEN_RATIO;
    CGFloat bigButtonHeight = _screenHeight * BUTTON_HEIGHT_RATIO;
    UIButton *bigButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [bigButton setFrame:CGRectMake(bigButtonLeft, bigButtonTop, bigButtonWidth, bigButtonHeight)];
    [bigButton setTitle:@"New curve" forState:UIControlStateNormal];
    [bigButton addTarget:self action:@selector(testMapLineMaker)
               forControlEvents:UIControlEventTouchUpInside];
    bigButton.backgroundColor=[UIColor grayColor];
    [bigButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:bigButton];
    
    // 애니메이션 버튼 추가.
    CGFloat smallButtonLeft = BUTTON_PADDING + bigButtonWidth + BUTTON_PADDING/2;
    CGFloat smallButtonWidth = _screenWidth - BUTTON_PADDING * 2.5 - bigButtonWidth;
    UIButton *smallButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [smallButton setFrame:CGRectMake(smallButtonLeft, bigButtonTop, smallButtonWidth, bigButtonHeight)];
    [smallButton setTitle:@"Animate" forState:UIControlStateNormal];
    [smallButton addTarget:self action:@selector(animateCurve)
               forControlEvents:UIControlEventTouchUpInside];
    smallButton.backgroundColor=[UIColor lightGrayColor];
    [smallButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // 페이스북 쉐어 버튼 추가.
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [shareButton setFrame:CGRectMake(bigButtonLeft, bigButtonTop + bigButtonHeight + BUTTON_PADDING/2,
                                     _screenWidth - BUTTON_PADDING * 2, bigButtonHeight)];
    [shareButton setTitle:@"Share on Facebook" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(sharePhoto)
          forControlEvents:UIControlEventTouchUpInside];
    shareButton.backgroundColor =
        [UIColor colorWithRed:174.0f/255.0f green:198.0f/255.0f blue:207.0f/255.0f alpha:1.0f];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:shareButton];
    
    // 슬라이더 추가.
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
    
    // 커브 만들어서 초기화.
    [self testMapLineMaker];
    
    // 애니메이션 버튼의 콜백은 path가 필요하기 때문에 testMapLineMaker 후에 호출합니다.
    [self.view addSubview:smallButton];
    
    // 제일 윗 레이어로 만들기 위해 나중에 추가합니다.
    [self.view addSubview:_curveView];
    [self.view addSubview:_dotView];
}

- (void)testMapLineMaker {
    [_shapeLayer setHidden:YES];
    [_curveView setHidden:NO];
    
    // Create random starting points.
    _curveLength = _slider.value;
    
    CGFloat curveY = 0;
    _start.y = arc4random_uniform(CURVE_VERTICAL_VARIATION);
    _end.x = CURVE_HORIZONTAL_PADDING + _curveLength;
    _end.y = arc4random_uniform(CURVE_VERTICAL_VARIATION) + curveY;
    
    //_testView.path = [_mapLineMaker mapLineBetweenPoint:_start point:_end];
    NSArray *pointList = [_mapLineMaker createPointsBetweenPoint:_start point:_end];
    _dotView.dots = pointList;
    _curveView.path = [_mapLineMaker interpolatePoints:pointList];
    
    [_dotView setNeedsDisplay];
    [_curveView setNeedsDisplay];
}

- (void) animateCurve {
    [_curveView setHidden:YES];
    [_shapeLayer setHidden:NO];
    
    _shapeLayer.path = _curveView.path.CGPath;
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = ANIMATION_DURATION * (_slider.value / _slider.maximumValue);
    pathAnimation.fromValue = @(0.0f);
    pathAnimation.toValue = @(1.0f);
    [_shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

- (void) sharePhoto {
    if (_shareable) {
        // 페이스북에 공유 할 이미지를 생성합니다. - 현재 처음 곡선이 계속 나오는 오류 있음.
        _curveImage = [_curveView curveIntoImage];
        
        // 커브와 합칠 타임라인 커버를 고릅니다.
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
        
    } else {
        // 쉐어 가능하지 않다고 표시.
    }
}

- (void) makeShareImage {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if (_curveImage && _pickedImage) {
        UIImage *imageToShare = [_imageMixView mixImage:_curveImage image:_pickedImage];
        //UIImageWriteToSavedPhotosAlbum(imageToShare, nil, nil, nil);
        [_shareController addImage:imageToShare];
        [self presentViewController:_shareController animated:YES completion:Nil];
    }
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingMediaWithInfo:(NSDictionary *)info {
    _pickedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self makeShareImage];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
