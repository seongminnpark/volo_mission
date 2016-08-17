//
//  VLOSummaryMarker.h
//  Volo
//
//  Created by Seongmin on 7/29/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIkit/UIkit.h>
#import "VLOLog.h"
#import "VLOPlace.h"
#import "VLOUtilities.h"
#import "UIColor+VLOExtension.h"

#define MARKER_SIZE          5.0 * [VLOUtilities screenRatioWith6]
#define MARKER_IMAGE_SIZE   20.0 * [VLOUtilities screenRatioWith6]
#define MARKER_FLAG_SIZE    18.0 * [VLOUtilities screenRatioWith6]
#define DAY_LABEL_HEIGHT    12.0 * [VLOUtilities screenRatioWith6]
#define DAY_LABEL_PADDING    5.0 * [VLOUtilities screenRatioWith6]

#define MARKER_ICON_WIDTH   60.0 * [VLOUtilities screenRatioWith6]
#define MARKER_ICON_HEIGHT  67.0 * [VLOUtilities screenRatioWith6]

#define MARKER_LABEL_HEIGHT 10.0 * [VLOUtilities screenRatioWith6]

#define MARKERS_PER_LINE       3
#define LINE_WIDTH           3.0 * [VLOUtilities screenRatioWith6]

#define SEGMENT_HEIGHT      50.0 * [VLOUtilities screenRatioWith6]
#define SEGMENT_OFFSET      10.0 * [VLOUtilities screenRatioWith6]
#define LONG_SEGMENT       100.0 * [VLOUtilities screenRatioWith6]
#define MIDDLE_SEGMENT      30.0 * [VLOUtilities screenRatioWith6]
#define SHORT_SEGMENT       20.0 * [VLOUtilities screenRatioWith6]
#define CURVE_WIDTH         58.0 * [VLOUtilities screenRatioWith6]

#define SEGMENT_ICON_SIZE   45.0 * [VLOUtilities screenRatioWith6]

#define LINE_GAP            80.0 * [VLOUtilities screenRatioWith6]

#define BACKGROUND_WIDTH   375.0 * [VLOUtilities screenRatioWith6]
#define BACKGROUND_HEIGHT  150.0 * [VLOUtilities screenRatioWith6]

#define TITLE_HEIGHT        30.0 * [VLOUtilities screenRatioWith6]

#define PROXIMITY_RADIUS     0.1

#define CONTENT_SIZE_PAD   100.0 * [VLOUtilities screenRatioWith6]

#define VOLO_COLOR          [UIColor colorWithRed:200/255.0 green:240/255.0 blue:235/255.0 alpha:1]
#define LINE_COLOR          [UIColor colorWithRed:211/255.0 green:213/255.0 blue:212/255.0 alpha:1]


#define SHRINK_RATIO         0.9
#define BUTTON_SIZE         30.0 * [VLOUtilities screenRatioWith6]



@interface VLOSummaryMarker : NSObject

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) NSNumber *day;
@property (nonatomic) NSInteger logIndex;

@property () BOOL hasMarkerIcon;
@property () NSString *iconImageName;

- (id) initWithLog:(VLOLog *)log andPlace:(VLOPlace *)place;
- (void) setMarkerImage:(NSString *)markerImageName isDay:(BOOL)isDay isFlag:(BOOL)isFlag;
- (void) setMarkerIconImage:(NSString *)iconImageName;

- (UIButton *) getDrawableView;
- (UIView *) getMarkerView;
- (UIView *) getMarkerIconView;
- (UIView *) getMarkerLabel;

- (VLOPlace *) getPlace;

@end


