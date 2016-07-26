//  Marker.h



// 화면상의 좌표값을 담을 클래스

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MARKER_SIZE         15
#define MARKER_LABEL_HEIGHT 10.0f
#define MARKER_LABEL_WIDTH  MARKER_SIZE * 2.5f
#define MARKER_TRAVEL       20.0f
#define MARKER_IMAGE_NAME   @"marker6.png"

@interface VLOMarker : NSObject

+ (CGFloat) distanceBetweenMarker1:(VLOMarker *)marker1 Marker2:(VLOMarker *)marker2;
- (UIView *) getMarkerViewWithColor:(UIColor *)color;

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) NSString *name;
@property (nonatomic) UIColor *color;
@property (nonatomic) NSInteger day;
@property (nonatomic) BOOL nameAbove;
@property (nonatomic) BOOL dottedLeft;
@property (nonatomic) BOOL dottedRight;

@end
