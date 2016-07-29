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

#define LEFT_TO_RIGHT = 0
#define RIGHT_TO_LEFT = 1

@interface VLOSummarySegment


@property (strong, nonatomic) VLOSummaryMarker *fromMarker;
@property (strong, nonatomic) VLOSummaryMarker *toMarker;
@property () BOOL curved;
@property () NSInteger direction;

- (id) initFrom:(VLOSummaryMarker *)fromMarker to:(VLOSummaryMarker *)toMarker;
- (void) setLine:(UIImage *)lineImage;
- (void) setLineContent:(UIImage *)contentImage;
- (UIView *) getDrawableView;

@end
