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

@interface VLOSummarySegment : NSObject

@property () BOOL curved;
@property () BOOL leftToRight;

- (id) initFrom:(VLOSummaryMarker *)fromMarker to:(VLOSummaryMarker *)toMarker;

- (void) updateMarkerPositions;

- (void) setSegmentImageLong:(NSString *)longImage
                      middle:(NSString *)middleImage
                       shortt:(NSString *)shortImage
                       curve:(NSString *)curveImage;

- (void) setSegmentIconImage:(NSString *)iconImageName;

- (UIView *) getDrawableView;

- (UIView *) getSegmentIconView;

- (UIView *) getSegmentView;

@end
