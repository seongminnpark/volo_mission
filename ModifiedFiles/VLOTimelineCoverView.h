//
//  VLOTimelineCoverView.h
//  Volo
//
//  Created by 1001246 on 2014. 12. 30..
//  Copyright (c) 2014년 SK Planet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class VLOTravel;
@class VLOTravelListCell;
@class VLOBlurredImageView;
@class VLOTimelineCoverView;
@class VLOFriendsView;
@class VLOTimelineSummary;

typedef NS_ENUM(NSInteger, VLOTimelineCoverPressedViewType) {
    VLOTimelineCoverPressedViewTypeDefault,
    VLOTimelineCoverPressedViewTypeImageView,
    VLOTimelineCoverPressedViewTypeDate
};
static CGFloat const VLOTimelineAnimateDurate = .35f;
static NSString * const VLOTimelineCoverViewNibName = @"VLOTimelineCoverView";

@protocol VLOTimelineCoverViewDelegate <NSObject>

- (void)coverViewDidSelectBackButton:(VLOTimelineCoverView *)coverView;
- (void)coverViewDidSelectMoreButton:(VLOTimelineCoverView *)coverView;
- (void)coverView:(VLOTimelineCoverView *)coverView didRecognizeLongPressGestureWithType:(VLOTimelineCoverPressedViewType)type;
- (void)coverViewDidSelectFriendsDetailButton:(VLOTimelineCoverView *)coverView;

@end

/**
 *  타임라인 (`VLOTimelineViewController`) 상단에 위치한 Cover view 입니다.
 *  여행기 (`VLOTravel`)에 대한 정보를 보여줍니다.
 */
@interface VLOTimelineCoverView : UIView

@property (nonatomic) BOOL isViewMode;

/**
 *  여행기 (`VLOTravel`)의 Cover image를 보여주는 `UIImageView` 입니다.
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 *  사용자가 입력한 여행기 날짜를 보여주는 `UILabel` 입니다.
 */
@property (nonatomic, strong) UILabel *dateLabel;

@property (strong, nonatomic) UIView *topContainerView;
@property (strong, nonatomic) UITextView *titleTextView;

@property (strong, nonatomic) CAGradientLayer *overlay;
@property (strong, nonatomic) UIView *titleSeparator;

@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *editButton;
@property (strong, nonatomic) UIButton *shareButton;

@property (strong, nonatomic) NSArray *friends;

@property (weak, nonatomic) id <VLOTimelineCoverViewDelegate> delegate;

@property (nonatomic) BOOL isFirstOpen;

@property (weak, nonatomic) VLOTravel *travel;
@property (nonatomic) double beginTime;
@property (nonatomic, strong) UIView *summaryView;





- (void)resizeTextViewHeight;
- (void)coverPageAppear;
- (double)checkTimeInCoverViewWithPresentTime:(CGFloat)presentTime andWhere:(NSString *)where;

- (void)coverPageInteractionWithGetureYMove:(CGFloat)yMove;
- (void)coverPageInteractionEnd;
- (BOOL)isCoverPageInteractedForClose;

- (void)backToTravelListAtCoverView:(UIButton *)backButton;
- (void)friendsViewDidSelectFriendsDetailButton:(VLOFriendsView *)friendsView;

- (instancetype)initWithFrame:(CGRect)frame andIsViewMode:(BOOL)isViewMode;

@end
