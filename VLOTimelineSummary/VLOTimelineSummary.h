//
//  Header.h
//  VLOTimelineSummary
//
//  Created by M on 2016. 6. 14..
//  Copyright © 2016년 M. All rights reserved.
//

#ifndef Header_h
#define Header_h
#import <UIKit/UIKit.h>
#import "getCoordinates.h"
#import "VLOPathAnimationMaker.h"
#import "Marker.h"


@interface VLOTimelineSummary : NSObject


@property (strong,nonatomic) GetCoordinates * gc;
@property (strong,nonatomic) VLOPathAnimationMaker * animationMaker;

- (id)initWithView:(UIView *)summaryView andLocationList:(NSArray *)location_list;
- (void) animateSummary;

@end


#endif /* Header_h */
