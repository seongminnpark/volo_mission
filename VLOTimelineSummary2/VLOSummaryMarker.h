//
//  VLOSummaryMarker.h
//  Volo
//
//  Created by Seongmin on 7/29/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIkit/UIkit.h>
#import "VLOCountry.h"
#import "VLOUtilities.h"

#define MARKER_SIZE          5.0 * [VLOUtilities screenRatioWith6]
#define MARKER_IMAGE_SIZE   20.0 * [VLOUtilities screenRatioWith6]
#define MARKER_ICON_WIDTH   60.0 * [VLOUtilities screenRatioWith6]
#define MARKER_ICON_HEIGHT  70.0 * [VLOUtilities screenRatioWith6]
#define MARKER_LABEL        10.0 * [VLOUtilities screenRatioWith6]
#define MARKERS_PER_LINE       3

#define MARKER_FLAG_SIZE    30.0 * [VLOUtilities screenRatioWith6]
#define MARKER_FLAG_GAP     10.0 * [VLOUtilities screenRatioWith6]
#define LINE_WIDTH           3.0 * [VLOUtilities screenRatioWith6]

#define SEGMENT_HEIGHT      50.0 * [VLOUtilities screenRatioWith6]
#define SEGMENT_OFFSET      10.0 * [VLOUtilities screenRatioWith6]
#define LONG_SEGMENT       100.0 * [VLOUtilities screenRatioWith6]
#define MIDDLE_SEGMENT      30.0 * [VLOUtilities screenRatioWith6]
#define SHORT_SEGMENT       20.0 * [VLOUtilities screenRatioWith6]

#define SEGMENT_ICON_SIZE   45.0 * [VLOUtilities screenRatioWith6]

#define LINE_GAP            80.0 * [VLOUtilities screenRatioWith6]


#define VOLO_COLOR          [UIColor colorWithRed:200/255.0 green:240/255.0 blue:235/255.0 alpha:1]
#define LINE_COLOR          [UIColor colorWithRed:211/255.0 green:213/255.0 blue:212/255.0 alpha:1]



@interface VLOSummaryMarker : NSObject

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) NSString *name;
@property (nonatomic) UIColor *color;
@property (nonatomic) VLOCountry *country;
@property (nonatomic) NSNumber *day;

+ (CGFloat) distanceBetweenMarker1:(VLOSummaryMarker *)marker1 Marker2:(VLOSummaryMarker *)marker2;
- (void) setMarkerImage:(NSString *)markerImageName;
- (void) setMarkerIconImage:(NSString *)iconImageName isFlag:(BOOL)isFlag;
- (UIView *) getDrawableView;


@end


