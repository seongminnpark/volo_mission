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
 *  Summary가 담길 UIView를 인자로 받습니다.
 */
- (id) initWithView:(UIView *)summaryView andMarkerList:(NSArray *)markerList;

/**
 *  셋업이 끝난 후 애니메이션을 실행합니다.
 */
- (void) animatePath;

@end
