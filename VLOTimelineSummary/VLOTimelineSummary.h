//
//  Header.h
//  VLOTimelineSummary
//
//  Created by M on 2016. 6. 14..
//  Copyright © 2016년 M. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "getCoordinates.h"
#import "VLOPathAnimationMaker.h"
#import "Marker.h"
#import "VLOCoordinateConverter.h"
#define SUMMARY_HEIGHT 100


@interface VLOTimelineSummary : NSObject


@property (strong,nonatomic) GetCoordinates * gc;
@property (strong,nonatomic) VLOPathAnimationMaker * animationMaker;

- (id)initWithView:(UIView *)summaryView andPlaceList:(NSArray *)place_list;
- (void) animateSummary;

@end