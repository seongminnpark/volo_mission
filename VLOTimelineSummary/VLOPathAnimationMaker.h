//
//  VLOPathAnimationMaker.h
//


#import <UIKit/UIKit.h>
#import "VLOPathMaker.h"
#import "Marker.h"

#define ANIMATION_VERTICAL_LIMIT 0.7
#define BUTTON_PADDING 10.0
#define BUTTON_HEIGHT_RATIO 0.1
#define WHOLE_DURATION 2
#define MARKER_SIZE 50.0
#define MARKER_ANIMATION_DURATION 0.3
#define MARKER_TRAVEL 20.0

/**
 *  `VLOPathAnimationMaker`는 주어진 Marker의 목록으로 지도 같이 구불구불한 길을 그리는 
 *  애니메이션이 담긴 UIView를 만듭니다.
 */
@interface VLOPathAnimationMaker : UIViewController

/**
 *  `[[VLOPathAnimationMaker alloc] init]`으로 VLOPathAnimationMaker의 객채를 생성합니다.
 */
- (id) init;

/**
 *  마커와 경로가 만나는 애니메이션이 담긴 UIView를 리턴합니다.
 */
- (UIView *) pathViewFromMarkers:(NSArray *)markerList;

@end
