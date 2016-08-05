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

#define MARKER_SIZE         5.0
#define MARKER_CONTENT_SIZE 50.0

#define MARKER_FLAG_SIZE    30.0
#define MARKER_FLAG_GAP     10.0
#define MARKER_LABEL        10.0
#define LINE_WIDTH          1.0

#define SEGMENT_HEIGHT       20
#define SEGMENT_CONTENT_SIZE 25 // 가로사이즈. 세로는 비율에 맞게 조정됨.

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
- (void) setMarkerContentImage:(NSString *)contentImageName isFlag:(BOOL)isFlag;
- (UIView *) getDrawableView;


@end


