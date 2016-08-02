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

@interface VLOTimelineSummary : NSObject

- (id) initWithLogs:(NSArray *)logList andView:(UIView *)view;
- (void) drawSummary;

@end
