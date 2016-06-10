//
//  PointTestView.m
//  mapline
//
//  Created by Seongmin on 6/7/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import "TestView.h"

@implementation TestView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)drawRect:(CGRect)rect {
    [_path stroke];
    
    for (NSValue *dot in _dots) {
        CGPoint dott = dot.CGPointValue;
        CGColorRef darkColor = [[UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] CGColor];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, darkColor);
        CGContextFillRect(context, CGRectMake(dott.x,dott.y - 100,3,3));
    }
    
}

@end
