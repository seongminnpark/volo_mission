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

#define MARKER_SIZE         10.0
#define MARKER_CONTENT_SIZE 30.0
#define MARKER_CONTENT_GAP  10.0
#define VOLO_COLOR          [UIColor colorWithRed:200/255.0 green:240/255.0 blue:235/255.0 alpha:1]
#define LINE_WIDTH          3.0

@interface VLOSummaryMarker : NSObject

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) NSString *name;
@property (nonatomic) UIColor *color;
@property (nonatomic) VLOCountry *country;
@property (nonatomic) NSNumber *day;
@property (nonatomic) BOOL hasMarkerContent;

+ (CGFloat) distanceBetweenMarker1:(VLOSummaryMarker *)marker1 Marker2:(VLOSummaryMarker *)marker2;
- (void) setMarkerImage:(NSString *)markerImageName;
- (void) setMarkerContentImage:(NSString *)contentImageName;
- (UIView *) getDrawableView;


@end


