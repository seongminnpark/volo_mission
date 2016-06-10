//
//  ViewController.h
//  mapline
//
//  Created by Seongmin on 6/7/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "VLOMapLineMaker.h"
#import "CurveView.h"
#import "DotView.h"

#define BUTTON_PADDING 10
#define BUTTON_TOP_RATIO 0.75
#define BUTTON_HEIGHT_RATIO 0.09
#define CURVE_HORIZONTAL_PADDING 40
#define CURVE_VERTICAL_RATIO 0.45
#define CURVE_VERTICAL_VARIATION 30
#define SLIDER_VERTICAL_RATIO 0.65
#define DOTVIEW_OFFSET 100
#define ANIMATION_DURATION 0.8
#define GOLDEN_RATIO 1.4


@interface ViewController : UIViewController

@property (strong, nonatomic) VLOMapLineMaker *mapLineMaker;
@property (strong, nonatomic) CurveView *curveView;
@property (strong, nonatomic) DotView *dotView;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) CAShapeLayer *shapeLayer;
@property (strong, nonatomic) SLComposeViewController *shareController;
@property () CGPoint start;
@property () CGPoint end;
@property () CGFloat screenWidth;
@property () CGFloat screenHeight;
@property () NSInteger curveLength;
@property () BOOL shareable;

@end

