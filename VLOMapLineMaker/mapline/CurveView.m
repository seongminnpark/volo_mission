//
//  CurveView.m
//  mapline
//
//  Created by Seongmin on 6/7/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import "CurveView.h"

@implementation CurveView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)drawRect:(CGRect)rect {
    [_path stroke];
}

-(UIImage *) curveIntoImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *curveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return curveImage;
}

@end
