//  Marker.h



// 화면상의 좌표값을 담을 클래스

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VLOCountry.h"

#define MARKER_SIZE         10.0f
#define MARKER_LABEL_HEIGHT 10.0f
#define MARKER_LABEL_WIDTH  20.0f
#define MARKER_TRAVEL       20.0f
#define MARKER_IMAGE_NAME   @"marker7.png"

@interface VLOMarker : NSObject

+ (CGFloat) distanceBetweenMarker1:(VLOMarker *)marker1 Marker2:(VLOMarker *)marker2;
- (UIView *) getMarkerViewWithColor:(UIColor *)color;

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) NSString *name;
@property (nonatomic) UIColor *color;
@property (nonatomic) BOOL nameAbove;
@property (nonatomic) VLOCountry *country;
@property (nonatomic) NSNumber *day;
@property (nonatomic) BOOL dottedLeft;
@property (nonatomic) BOOL dottedRight;

@end
