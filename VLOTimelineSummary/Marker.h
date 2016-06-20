//
//  Marker.h
//  getCoordinates(ios)
//
//  Created by M on 2016. 6. 10..
//  Copyright © 2016년 M. All rights reserved.
//


// 화면상의 좌표값을 담을 클래스

#import <CoreGraphics/CGBase.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MARKER_SIZE 30.0
#define MARKER_LABEL_HEIGHT 10.0
#define MARKER_IMAGE_NAME @"marker5.png"


@interface Marker : NSObject

- (UIView *) getMarkerView;

@property (nonatomic)CGFloat x;
@property (nonatomic)CGFloat y;
@property (nonatomic)NSString *name;

@end
