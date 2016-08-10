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
#import "VLOTravel.h"
#import "VLOTimezone.h"
#import "VLOLog.h"
#import "VLODayLog.h"
#import "VLORouteNode.h"
#import "VLORouteLog.h"
#import "VLOPlace.h"
#import "VLOCountry.h"
#import "VLOLocationCoordinate.h"
#import "VLOUtilities.h"

#define SUMMARY_HEIGHT       300

@interface VLOSummaryViewController : UIViewController

- (id) initWithTravel:(VLOTravel *)travel logList:(NSArray *)logList view:(UIView *)view;
- (void) drawSummary;

@end
