//
//  VLOCoordinateConverter.h
//  Volo
//
//  Created by Seongmin on 6/20/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLOUtilities.h"
#import "Marker.h"
#import "VLOLocationCoordinate.h"
#import "VLOPlace.h"
#import "VLOTimeLineSummary.h"

#define MARKER_VERTICAL_OFFSET MARKER_SIZE + MARKER_LABEL_HEIGHT

@interface VLOCoordinateConverter : NSObject

- (id) init;
- (NSArray *) getCoordinates:(NSArray *)placesList;

@end
