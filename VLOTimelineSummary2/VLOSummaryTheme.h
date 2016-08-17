//
//  VLOSummaryTheme.h
//  Volo
//
//  Created by Seongmin on 8/17/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface VLOSummaryTheme : MTLModel

@property () NSArray *longSegments;
@property () NSArray *mediumSegments;
@property () NSArray *shortSegments;
@property () NSArray *curveSegments;

@property () NSString *backgroundImage;
@property () NSString *markerImage;

- (id) init;
- (void) shuffleIndex:(NSInteger)segmentCount;

- (NSString *)getLongSeg:(NSInteger)index;
- (NSString *)getMedSeg:(NSInteger)index;
- (NSString *)getShortSeg:(NSInteger)index;
- (NSString *)getCurveSeg:(NSInteger)index;

@end
