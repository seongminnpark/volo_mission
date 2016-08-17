//
//  VLOTimelineSummary.h
//  Volo
//
//  Created by Seongmin on 8/1/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Masonry/Masonry.h>
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
#import "VLOActivityIndicator.h"
#import "VLOSummaryTheme.h"

@class VLOSummaryViewController;

@protocol VLOSummaryViewControllerDelegate <NSObject>

- (void)summaryControllerClosed:(VLOSummaryViewController *)viewController;
- (void)summaryShareSelected:(VLOSummaryViewController *)viewController;
- (void)scrollToLog:(NSInteger)logIndex;

@end

@interface VLOSummaryViewController : UIViewController

@property (weak, nonatomic) id<VLOSummaryViewControllerDelegate> delegate;

- (id) initWithTravel:(VLOTravel *)travel andLogList:(NSArray *)logList;
- (void) drawSummary;
- (void) setTheme:(VLOSummaryTheme *)theme;

@end


