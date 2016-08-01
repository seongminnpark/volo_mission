//
//  VLOSummarySegment.h
//  Volo
//
//  Created by Seongmin on 7/29/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIkit/UIkit.h>
#import "VLOSummaryMarker.h"

#define SEGMENT_HEIGHT       10
#define SEGMENT_CONTENT_SIZE 30
#define LINE_VERTICAL_DIFFERENCE 50
#define CURVE_BUFFER         20

@interface VLOSummarySegment : NSObject 

@property (strong, nonatomic) VLOSummaryMarker *fromMarker;
@property (strong, nonatomic) VLOSummaryMarker *toMarker;
@property () BOOL curved;
@property () BOOL leftToRight;
@property () BOOL hasSegmentContent;

- (id) initFrom:(VLOSummaryMarker *)fromMarker to:(VLOSummaryMarker *)toMarker;
- (void) setSegmentImage:(NSString *)segmentImageName;
- (void) setSegmentContentImage:(NSString *)contentImageName;
- (UIView *) getDrawableView;

@end
