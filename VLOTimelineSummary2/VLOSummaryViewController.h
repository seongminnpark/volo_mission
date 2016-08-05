//
//  VLOTimelineSummary.h
//  Volo
//
//  Created by Seongmin on 8/1/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLOSummaryMarker.h"
#import "VLOSummarySegment.h"
#import "VLOLog.h"
#import "VLODayLog.h"
#import "VLORouteNode.h"
#import "VLORouteLog.h"
#import "VLOPlace.h"
#import "VLOLocationCoordinate.h"
#import "VLOUtilities.h"

#define SUMMARY_HEIGHT      300
#define LINE_MAX_MARKER     3


@interface VLOTimelineSummary : NSObject

@property (strong, nonatomic) NSMutableArray *distanceList;
@property () CGFloat actualWidth;
@property () CGFloat summaryWidth;
@property () CGFloat summaryHeight;
@property () CGFloat distanceSum;

- (id) initWithLogs:(NSArray *)logList andView:(UIView *)view;
- (void) drawSummary;

@end
