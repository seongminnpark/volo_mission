//
//  CurveView.h
//  mapline
//
//  Created by Seongmin on 6/7/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurveView : UIView

@property (strong, nonatomic) UIBezierPath *path;

- (UIImage *) curveIntoImage;

@end
