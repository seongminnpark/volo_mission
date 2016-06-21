//  Marker.h



// 화면상의 좌표값을 담을 클래스

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MARKER_SIZE 30.0
#define MARKER_LABEL_HEIGHT 10.0
#define MARKER_LABEL_WIDTH MARKER_SIZE * 2.0
#define MARKER_ANIMATION_DURATION 0.3
#define MARKER_TRAVEL 20.0
#define MARKER_IMAGE_NAME @"marker5.png"


@interface VLOMarker : NSObject

- (UIView *) getMarkerView;

@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) NSString *name;

@end
