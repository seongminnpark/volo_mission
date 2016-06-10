//
//  VLOMapLineManager.m
//  mapline
//
//  Created by Seongmin on 6/7/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VLOMapLineMaker.h"

@interface VLOMapLineMaker()

@property (nonatomic, weak) NSString *a;

- (NSArray *)partitionLineOfDistance:(NSInteger)distance
                       numberOfDivisions:(NSInteger)divisions
                       randomSeed:(NSInteger)randonSeed;

@end

@implementation VLOMapLineMaker: NSObject

- (UIBezierPath *)mapLineBetweenPoint:(CGPoint)from point:(CGPoint)to {
    NSArray *pointList = [self createPointsBetweenPoint:from point:to];
    NSLog(@"%@",pointList);
    return [self interpolatePoints:pointList];
}


#pragma mark - Create Route Points

- (NSMutableArray *) createPointsBetweenPoint:(CGPoint)from point:(CGPoint)to {
    NSInteger randomSeed = from.x + from.y + to.x + to.y;
    
    // NSMutableArray에 좌표를 저장하기 위해 CGPoint object를 NSValue로 변환합니다.
    NSValue *ns_from = [NSValue valueWithCGPoint:from];
    NSValue *ns_to = [NSValue valueWithCGPoint:to];
    
    NSMutableArray *points = [[NSMutableArray alloc] init];
    NSMutableArray *created_points = [[NSMutableArray alloc] initWithObjects:ns_from, nil];
    
    // 두 CGPoint 사이를 얼마나 나눌지 결정하기 위한 변수들입니다.
    CGFloat distance = hypotf(to.x-from.x, to.y-from.y);
    NSInteger max_divisions = floor(distance/MIN_DISTANCE);
    NSInteger num_divisions = MIN(max_divisions, MAX_LINE_DIVISION);

    BOOL too_short = distance < MIN_DISTANCE;
    BOOL max_division_0 = num_divisions == 0;
    if (too_short || max_division_0) {
        [points addObject:ns_from];
        [points addObject:ns_to];
    } else {
        NSInteger random_divs = randomSeed % num_divisions + 1;
        NSArray *partition_lengths =
            [self partitionLineOfDistance:distance numberOfDivisions:random_divs randomSeed:randomSeed];
    
        for (NSNumber *partition in partition_lengths) {
            CGFloat partition_length = partition.floatValue;
            // 너무 크거나 거꾸로 가는 각도의 deviation은 피합니다.
            CGFloat degree_angle = randomSeed % (ANGLE_DEVIATION*2) - ANGLE_DEVIATION;
            while(degree_angle <= 0) {
                degree_angle += 1;
            }
            CGFloat random_angle = RAD(degree_angle);
            CGFloat angle_from_x_axis = atan2f(to.y-from.y, to.x-from.x);
            CGFloat new_angle = random_angle + angle_from_x_axis;
            CGFloat new_x = partition_length * cosf(new_angle) + from.x;
            CGFloat new_y = partition_length * sinf(new_angle) + from.y;
            CGPoint new_point = CGPointMake(new_x, new_y);
            
            NSValue *ns_new_point = [NSValue valueWithCGPoint:new_point];
            [created_points addObject:ns_new_point];
        }

        [created_points addObject:ns_to];
        
        for (int i=1; i < [created_points count]; i++) {
            CGPoint prev_point = ((NSValue *)(created_points[i-1])).CGPointValue;
            CGPoint next_point = ((NSValue *)(created_points[i])).CGPointValue;
            [points addObjectsFromArray: [self createPointsBetweenPoint:prev_point point:next_point]];
        }
    }
    return points;
}

/**
 * 길이가 distance만큼인 선을 division 갯수로 잘라, 각 partition의 길이를 순서대로 담은
 * NSMutableArray를 리턴합니다. 각 조각의 길이는 MIN_DISTANCE 보다 큰 임의의 길이입니다.
 * 결과에 마지막 파티션은 포함하지 않습니다.
 */
- (NSArray *) partitionLineOfDistance:(NSInteger)distance
                       numberOfDivisions:(NSInteger)divisions
                       randomSeed: (NSInteger)randomSeed {
    
    NSMutableArray *partition_lengths = [[NSMutableArray alloc] initWithCapacity:divisions];
    NSInteger leftover = round(distance - MIN_DISTANCE * divisions);
    
    // 선의 각 조각을 MIN_DIST로 초기화 합니다.
    for (NSInteger i = 0; i < divisions; i++) {
        NSNumber *min_dist = [[NSNumber alloc] initWithInt:MIN_DISTANCE];
        [partition_lengths addObject:min_dist];
    }
    
    // 파티션 배열을 초기화 하고 남은 길이를 각 파티션에 랜덤으로 배분합니다.
    NSInteger toAdd = 0;
    for (NSInteger i = 0; i < divisions; i++) {
        if (leftover < 1) {
            break;
        } else {
            toAdd = randomSeed % leftover;
            NSInteger updated_length = ((NSNumber *)partition_lengths[i]).integerValue + toAdd;
            NSNumber *ns_updated_length = [[NSNumber alloc] initWithInt:(int)updated_length];
            [partition_lengths replaceObjectAtIndex:i withObject:ns_updated_length];
        }
        leftover -= toAdd;
    }
    return partition_lengths;
}


#pragma mark - Interpolation

- (UIBezierPath *) interpolatePoints:(NSArray *)pointList {
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (pointList.count < 2) {
        return path;
    } else {
        // Catmull-Rom은 선을 그리기 위해 좌표 네 개가 필요합니다. 처음 점과 마지막 점을 포인트 리스트에 더합니다.
        NSMutableArray *mutablePointList = [pointList mutableCopy];
        [mutablePointList insertObject:mutablePointList.firstObject atIndex:0];
        [mutablePointList addObject:mutablePointList.lastObject];

        CGPoint firstPoint = ((NSValue *)mutablePointList.firstObject).CGPointValue;
        [path moveToPoint:firstPoint];
        for (NSInteger i = 1; i < mutablePointList.count - 2; i++) {
            CGPoint p0 = ((NSValue *)[mutablePointList objectAtIndex:i-1]).CGPointValue;
            CGPoint p1 = ((NSValue *)[mutablePointList objectAtIndex:i]).CGPointValue;
            CGPoint p2 = ((NSValue *)[mutablePointList objectAtIndex:i+1]).CGPointValue;
            CGPoint p3 = ((NSValue *)[mutablePointList objectAtIndex:i+2]).CGPointValue;
            CGFloat dist_p0p1 = hypotf(p1.x - p0.x, p1.y - p0.y);
            CGFloat dist_p1p2 = hypotf(p2.x - p1.x, p2.y - p1.y);
            CGFloat dist_p2p3 = hypotf(p3.x - p2.x, p3.y - p2.y);
            
            CGPoint control_point_1 = [self controlPointBetweenFirstPoint:p2
                    secondPoint:p0 thirdPoint:p1 firstDistance:dist_p0p1 secondDistance:dist_p1p2];
            CGPoint control_point_2 = [self controlPointBetweenFirstPoint:p1
                    secondPoint:p3 thirdPoint:p2 firstDistance:dist_p2p3 secondDistance:dist_p1p2];
            
            // 점들이 집중된 구간은 커브를 추가하지 않습니다.
            if (p2.x - p1.x > 2) {
                [path addCurveToPoint:p2 controlPoint1:control_point_1 controlPoint2:control_point_2];
            }

        }
    }
    path.lineWidth = LINE_WIDTH;
    path.miterLimit = MITERLIM;
    return path;
}

/**
 * 세 개의 점과 그 사이 길이가 주어질 때, bezier curve를 그리기 위한 control point를 생성합니다.
 * Cem Yukesi의 <On the Parameterization of Catmull-Rom curves> 챕터 3 CUSPS AND SELF-INTERACTIONS를
 * 참고했습니다. (Equation 2를 코드로 그대로 옮겼습니다).
 */
- (CGPoint) controlPointBetweenFirstPoint:(CGPoint)first
                              secondPoint:(CGPoint)second
                               thirdPoint:(CGPoint)third
                            firstDistance:(NSInteger)first_dist
                           secondDistance:(NSInteger)second_dist {
    
    if (first_dist <= 1) {
        return first;
    }
    
    // Cem Yukes의 Equation (2) 를 만듭니다.
    CGFloat first_mutiplier = powf(first_dist,2*ALPHA);
    CGFloat second_multiplier = -1 * powf(second_dist,2*ALPHA);
    CGFloat third_multiplier = 2*first_mutiplier
                               + 3*powf(first_dist,ALPHA)*powf(second_dist,ALPHA)
                               - second_multiplier;
    
    CGPoint numerator_first = CGPointMake(first.x * first_mutiplier,
                                          first.y * first_mutiplier);
    CGPoint numerator_second = CGPointMake(second.x * second_multiplier,
                                           second.y * second_multiplier);
    CGPoint numerator_third = CGPointMake(third.x * third_multiplier,
                                          third.y * third_multiplier);
    CGPoint numerator = CGPointMake(
        numerator_first.x + numerator_second.x + numerator_third.x,
        numerator_first.y + numerator_second.y + numerator_third.y);

    CGFloat denominator = 3 * powf(first_dist,ALPHA)
                          * (powf(first_dist,ALPHA) + powf(second_dist, ALPHA));
    
    CGPoint control_point = CGPointMake(numerator.x/denominator, numerator.y/denominator);
    
    return control_point;
}
@end









