//
//  TimelineViewController.h
//  Volo
//
//  Created by 1001246 on 2014. 12. 29..
//  Copyright (c) 2014년 SK Planet. All rights reserved.
//

#import "VLOTimelineCoverView.h"    // VLOTimelineCoverPressedViewType을 위한 Header

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "VLOTimelineSummary.h"
#define SUMMARY_HEIGHT 100


@class VLOTravelListViewController;
@class VLOTimelineTableViewController;
@class VLOTimelineNavigationBar;
@class VLOTimelineTableView;
@class VLOTimelineCoverView;
@class VLOAddCellMenuButton;
@class VLOTimelineMenu;
@class VLOTravel;
@class VLOTravelListCell;


@interface VLOTimelineViewController : UIViewController

@property (nonatomic) BOOL isOpenedFromDiscover;
@property (nonatomic) BOOL isOpenedFromEditor;
@property (nonatomic, strong) VLOTimelineCoverView *coverView;

@property (nonatomic, strong) VLOTimelineNavigationBar *timelineNavigationBar;

@property (nonatomic, strong) VLOTimelineTableViewController *tableViewController;
@property (nonatomic, strong) VLOTimelineTableView *tableView;

@property (nonatomic, strong) VLOAddCellMenuButton *addCellMenuButton;
@property (nonatomic) BOOL isCoverOpen;

@property (nonatomic, strong) VLOTravel *shortcutTravel;
@property (nonatomic, weak) VLOTravel *travel;
@property (nonatomic, weak) VLOTravelListViewController *travelListViewController;

- (void)coverOpen;
- (void)coverClose;
- (void)coverViewMoveEnded;
- (void)backToTravelListAtTimeline:(id)sender;
- (void)manualSync:(UIBarButtonItem *)sender;
- (void)addFriends:(UIButton *)sender;

- (void)shareToFacebookWithTravel:(VLOTravel *)travel;
- (void)copyURLWithTravel:(VLOTravel *)travel;
- (void)editCoverViewWithPressType:(VLOTimelineCoverPressedViewType)type isLongPress:(BOOL)isLongPress;

- (void)timelineTableViewController:(VLOTimelineTableViewController *)controller didChangingOrderStarted:(BOOL)isStarted;

- (void)timelineMenuDidSelectTextButtonWithAnimated:(BOOL)animated;
- (void)timelineMenuDidSelectPhotoButtonWithAnimated:(BOOL)animated;
- (void)timelineMenuDidSelectLocationButtonWithAnimated:(BOOL)animated;


@end