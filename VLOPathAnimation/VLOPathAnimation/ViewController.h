//
//  ViewController.h
//  VLOPathAnimation
//
//  Created by Seongmin on 6/13/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLOMapLineMaker.h"
#import "Marker.h"

#define ANIMATION_VERTICAL_LIMIT 0.7
#define BUTTON_PADDING 10.0
#define BUTTON_HEIGHT_RATIO 0.1
#define WHOLE_DURATION 2
#define MARKER_SIZE 60.0
#define MARKER_ANIMATION_DURATION 0.3
#define MARKER_TRAVEL 20.0

@interface ViewController : UIViewController

@property (strong, nonatomic) VLOMapLineMaker *mapLineMaker;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) CALayer *animationLayer;

@property () CGFloat screenWidth;
@property () CGFloat screenHeight;

@end
