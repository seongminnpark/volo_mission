//
//  Marker.h
//  getCoordinates(ios)
//
//  Created by M on 2016. 6. 10..
//  Copyright © 2016년 M. All rights reserved.
//


// 화면상의 좌표값을 담을 클래스

#ifndef Marker_h
#define Marker_h
#import <CoreGraphics/CGBase.h>
#import <UIKit/UIKit.h>


@interface Marker : NSObject


@property (nonatomic)CGFloat x;
@property (nonatomic)CGFloat y;

@end


#endif /* Marker_h */
