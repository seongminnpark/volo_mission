//
//  ImageMixView.h
//  VLOMapLineMaker
//
//  Created by Seongmin on 6/11/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OVERLAY_VERTICAL_RATIO 0.7

@interface ImageMixView : UIView

- (UIImage *) mixImage:(UIImage *)curve image:(UIImage *)cover;

@end
