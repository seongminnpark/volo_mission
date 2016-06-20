//
//  VLOTimelineTableViewController.h
//  Volo
//
//  Created by bamsae on 2015. 1. 2..
//  Copyright (c) 2015년 SK Planet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "VLOQuoteEditorViewController.h"
#import "VLOPhotoLogEditorViewController.h"
#import "VLOTableViewPhotoCell.h"
#import "VLOTableViewMapCell.h"
#import "VLORouteLog.h"
#import "VLOTimelineTableFooterView.h"
#import "VLOTimelineViewController.h"

#define VLOCellBottomMargin 10

static NSString * const VLOTimelineInfoKeyPrefix = @"VLOTimelineInfo_";
static NSString * const VLOTimelineInfoLastDate = @"lastDate";
static NSString * const VLOTimelineInfoLastTimeZone = @"lastTimeZone";
static NSString * const VLOTimelineInfoLastWroteDate = @"lastWroteDate";
static NSString * const VLOTimelineInfoLastViewDate = @"lastViewDate";
static NSString * const VLOTimelineInfoLastContentOffset = @"lastContentOffset";
static NSString * const VLOTimelineInfoHasBeenOpened = @"hasBeenOpened";

@class VLOTimelineCell;
@class VLOLog;
@class VLODayLog;
@class VLOTravel;
@class VLOTimelineTableViewController;
@class VLOActivityIndicator;
@class JTSScrollIndicator;
@class VLOSyncStatusBar;

typedef NS_ENUM(NSInteger, VLOScrollViewSpeed) {
    VLOScrollViewSpeedSlow,
    VLOScrollViewSpeedFast
};

@protocol VLOTimelineTableViewControllerDelegate <NSObject>

- (void)timelineTableViewControllerDidInitLogList:(VLOTimelineTableViewController *)controller;
- (void)timelineTableViewControllerDidUpdateLogList:(VLOTimelineTableViewController *)controller;

- (void)timelineTableViewController:(VLOTimelineTableViewController *)controller didChangingOrderStarted:(BOOL)isStarted;
- (void)timelineTableViewController:(VLOTimelineTableViewController *)controller didEditingWasStarted:(BOOL)isStarted;
- (void)timelineTableViewController:(VLOTimelineTableViewController *)controller didAddToBelowOfLog:(VLOLog *)log;
- (void)timelineTableViewController:(VLOTimelineTableViewController *)controller didGetTravelServerId:(NSString *)serverIdf;

- (void)timelineTableViewControllerWillAppear:(VLOTimelineTableViewController *)controller;
- (void)timelineTableViewControllerWillDisAppear:(VLOTimelineTableViewController *)controller;

- (void)timelineTableViewControllerDidShowEmptyView:(VLOTimelineTableViewController *)controller;

@end

@protocol VLOTimelineTableViewSyncDelegate <NSObject>

- (void)timelineTableViewControllerBeginSync:(VLOTimelineTableViewController *)tableViewController;
- (void)timelineTableViewControllerEndSync:(VLOTimelineTableViewController *)tableViewController;
- (void)timelineTableViewControllerSyncFaliure:(VLOTimelineTableViewController *)tableViewController;

@end

@interface VLOTimelineTableViewController : UITableViewController <UIDocumentInteractionControllerDelegate>

@property (nonatomic) BOOL isViewMode;

@property (nonatomic, strong) VLOTravel *travel;
@property (nonatomic, strong) NSMutableArray *logs;

@property (weak, nonatomic) id<VLOTableViewPhotoCellDelegate> photoDelegate;
@property (weak, nonatomic) id<VLOTableViewMapCellDelegate> mapDelegate;
@property (weak, nonatomic) id<VLOTimelineTableViewControllerDelegate> delegate;
@property (weak, nonatomic) id<VLOTimelineTableViewSyncDelegate> syncDelegate;
@property (weak, nonatomic) id<VLOTimelineTableFooterDelegate> footerDelegate;

@property (nonatomic) BOOL isOrderChangeMode;
@property (nonatomic) VLOTransportType lastTransportType;

@property (nonatomic, strong) VLOActivityIndicator *activityIndicator;

@property (nonatomic, strong) NSDate *lastWroteDate;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) NSTimeZone *lastTimeZone;

@property (strong, nonatomic) JTSScrollIndicator *indicator;

@property (nonatomic, weak) VLOLog *addToBelowPivotLog;

@property (nonatomic) BOOL canOpenDetailView;
@property (nonatomic) BOOL isMovementDecelerate;

@property (nonatomic, weak) VLOSyncStatusBar *syncStatusBar;

- (void)initTimeline;

- (void)addLog:(VLOLog *)log;
- (void)updateLog:(VLOLog *)log isChangeDate:(BOOL)isChange;
- (void)updateLog:(VLOLog *)log isSetToBelow:(VLOLog *)previous;
- (void)removeLog:(VLOLog *)log forUserAction:(BOOL)animated;
- (void)syncTimeline;
- (void)syncPhotosInTimeline;

- (void)startOrderChangeModeWithLog:(VLOLog *)log;
- (void)endOrderChangeModeWithIsChanged:(BOOL)isChanged;
- (void)cancelOrderChangeModeWithLog:(VLOLog *)log;

- (BOOL)isOnWriting;

- (NSDate *)getTimelineLastWroteDate;
- (void)setTimelineInfoLastViewDate;
- (NSDate *)getTimelineLastViewDate;
- (NSNumber *)getTimelineLastContentOffset;
- (void)setTimelineLastContentOffset:(NSNumber *)offset;

@end