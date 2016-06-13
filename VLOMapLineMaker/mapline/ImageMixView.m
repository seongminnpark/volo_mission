//
//  ImageMixView.m
//  VLOMapLineMaker
//
//  Created by Seongmin on 6/11/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import "ImageMixView.h"

@implementation ImageMixView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIImage *) mixImage:(UIImage *)curve image:(UIImage *)cover {
    UIGraphicsBeginImageContextWithOptions(cover.size, self.opaque, 0.0);
    
    [cover drawInRect:CGRectMake(0,0,cover.size.width, cover.size.height)];
    CGFloat curveLeft = self.frame.size.width/2.0f - curve.size.width/2.0f;
    CGFloat curveTop = self.frame.size.height * OVERLAY_VERTICAL_RATIO;
    [curve drawInRect:CGRectMake(curveLeft,curveTop,curve.size.width, curve.size.height)];
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImage;
}

@end
