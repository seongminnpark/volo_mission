//  VLOPathAnimationMaker.h


#import <UIKit/UIKit.h>
#import "VLOUtilities.h"
#import "VLOPathMaker.h"
#import "VLOMarker.h"

#define MARKER_ANIMATION_DURATION 0.3
#define LINE_ANIMATION_DURATION   2

#define MITERLIM   5.0
#define LINE_WIDTH 4

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
