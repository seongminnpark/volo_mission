//
//  VLOMapLineManager.h
//  mapline
//
//  Created by Seongmin on 6/7/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import <math.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef VLOMapLineManager_h
#define VLOMapLineManager_h

// 다음 세 상수들로 선의 복잡한 정도를 조절합니다.
#define MAX_LINE_DIVISION 1
//#define MIN_DISTANCE 50
#define MIN_DISTANCE 10
#define ANGLE_DEVIATION 15

#define ALPHA 1
//#define LINE_WIDTH 3
#define LINE_WIDTH 5
#define MITERLIM -10
#define RAD(degrees) (degrees / 180.0 * M_PI)
#define DEG(radians) (radians * (180.0 / M_PI))

/**
 *  `VLOMapLineManager`는 타임라인 커버 위에 요약된 경로를 표시하기 위해, 
 *  지도상의 길과 같이 구부러진 UIBezierPath를 생성합니다.
 */
@interface VLOMapLineMaker : NSObject

/**
 * 두 좌표 사이의 구불구불한 UIBezierPath를 리턴합니다.
 * createPointsBetweenPoint:andPoint: method로 임의의 좌표들을 정한 후,
 * interpolateWithPoints: method를 호출해 선을 만듭니다.
 */
- (UIBezierPath *) mapLineBetweenPoint:(CGPoint)from point:(CGPoint)to;

/**
 * 주어진 두 좌표 사이에 구부러진 길을 구성하는 점 좌표들을 생성합니다.
 */
- (NSArray *) createPointsBetweenPoint:(CGPoint)from point:(CGPoint)to;

/**
 * 좌표 배열이 주어지면, catmull-rom 기법으로 좌표를 interpolate 합니다.
 */
- (UIBezierPath *) interpolatePoints:(NSArray *)pointList;

@end

#endif /* VLOMapLineManager_h */
