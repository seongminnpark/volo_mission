//
//  VLOTimelineTableViewController.m
//  Volo
//
//  Created by bamsae on 2015. 1. 2..
//  Copyright (c) 2015년 SK Planet. All rights reserved.
//

#import "VLOTimelineTableViewController.h"

// Controller
#import "VLOTextEditorNavigationController.h"
#import "VLOPhotoLogEditorNavigationController.h"
#import "VLOTextEditorViewController.h"
#import "VLOQuoteEditorViewController.h"
#import "VLOPhotoLogEditorViewController.h"
#import "VLODatePickerViewController.h"
#import "VLOMapEditorNavigationController.h"
#import "VLOMapEditorViewController.h"
#import "VLOPhotoDetailViewController.h"
#import "VLORouteEditorNavigationController.h"
#import "VLORouteEditorViewController.h"
#import "VLOActionSheet.h"
#import "VLOMainTabBarController.h"

// View
#import "VLOTimelineTableView.h"
#import "VLOOrderChangeMarkButton.h"
#import "VLOTableViewCellFooterView.h"
#import "VLOProfileImageView.h"
#import "VLOStickerTextView.h"
#import "VLORouteCellNodeView.h"
#import "VLOActivityIndicator.h"
#import "VLOTimelineTableHeaderView.h"
#import "VLOTimelineNavigationBar.h"

// Cell
#import "VLOTimelineCell.h"
#import "VLOTableViewDayCell.h"
#import "VLOTableViewPhotoCell.h"
#import "VLOTableViewPhoto1Cell.h"
#import "VLOTableViewQuoteCell.h"
#import "VLOTableViewTextCell.h"
#import "VLOTableViewMapCell.h"
#import "VLOTableViewRouteCell.h"

// Model
#import "VLOUser.h"
#import "VLOLog.h"
#import "VLOSticker.h"
#import "VLOPhotoLog.h"
#import "VLOTextLog.h"
#import "VLODayLog.h"
#import "VLOMapLog.h"
#import "VLOQuoteLog.h"
#import "VLOPlace.h"
#import "VLOTravel.h"
#import "VLORouteLog.h"
#import "VLORouteNode.h"
#import "VLOPhoto.h"
#import "VLOTimezone.h"
#import "VLOLocationCoordinate.h"
#import "VLOInsertDiffFromServer.h"
#import "VLODeleteDiffFromServer.h"
#import "VLOInsertDiffFromLocal.h"

// Utility
#import "VLOUtilities.h"
#import "NSDate+VLOExtension.h"
#import "UIColor+VLOExtension.h"
#import "UIFont+VLOExtension.h"
#import "UIImageViewAligned.h"
#import "VLOLocalStorage.h"
#import "VLOSyncManager.h"
#import "VLOAPNSManager.h"
#import "VLONetwork.h"
#import "VLOAnalyticsManager.h"
#import "VLOShare.h"

#import "VLOWatchHandler.h"

#import "JTSScrollIndicator.h"
#import "JTSScrollIndicatorConfig.h"
#import "VLOShareAlert.h"

// Library
#import <VLOToast/VLOToast.h>

#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface VLOTimelineTableViewController () <VLOTimelineCellDelegate, VLOTableViewTextCellDelegate, VLOQuoteEditorModificationDelegate, VLOPhotoLogEditorDelegate, VLOMapEditorDelegate, VLORouteEditorDelegate, VLOTextEditorDelegate>

@property (nonatomic, strong) VLOTimelineCell *editingCell;
@property (nonatomic, strong) UIView *emptyView;

@property (nonatomic) BOOL isOrderChangeModeAppear;

@property (nonatomic) NSInteger orderChangeRow;
@property (nonatomic, strong) VLOLog *orderChangingLog;
@property (nonatomic, strong) VLOUser *me;

@property (nonatomic, strong) NSMutableDictionary *logsHeightCache;
@property (nonatomic, strong) NSMutableDictionary *dayCellDictionary;

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@property (nonatomic) CGPoint lastOffset;
@property (nonatomic) NSTimeInterval lastOffsetCapture;
@property (nonatomic) BOOL isScrollingFast;

@property (nonatomic) BOOL isInitForWriteMode;

@property (nonatomic) CGFloat lastScrolledContentOffset;

@property (nonatomic) BOOL isCalledNextCellForViewMode;
@property (nonatomic) BOOL isEndOfTravelForViewMode;

@property (nonatomic) BOOL isPhotoEditingMode;

@property (nonatomic) BOOL isSyncOn;

@property (nonatomic, strong) VLOTimelineTableFooterView *footerView;

@end

@implementation VLOTimelineTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _canOpenDetailView = YES;
    _isOrderChangeModeAppear = NO;
    _isOrderChangeMode = NO;
    _me = [VLOLocalStorage getCurrentUser];
    
    _lastDate = [self getTimelineLastDate];
    _lastTimeZone = [self getTimelineLastTimeZone];
    _lastWroteDate = [self getTimelineLastWroteDate];
    [[NSUserDefaults standardUserDefaults] setObject:_lastWroteDate forKey:VLOLastOpenedTimelineLastWroteDateKey];
    
    _indicator = [[JTSScrollIndicator alloc] initWithScrollView:self.tableView];
    _indicator.backgroundColor = [UIColor colorWithHexString:@"838996"];
    _indicator.backgroundView.backgroundColor = [UIColor colorWithHexString:@"d6d8dc"];
    [JTSScrollIndicatorConfig sharedConfig].width = 4.0f;
    [JTSScrollIndicatorConfig sharedConfig].rightMargin = 2.0f;
    
    [VLOWatchHandler sharedWatchHandler].timelineTableViewController = self;

    [self initTimeline];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([_delegate respondsToSelector:@selector(timelineTableViewControllerWillAppear:)]) {
        [_delegate timelineTableViewControllerWillAppear:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([_delegate respondsToSelector:@selector(timelineTableViewControllerWillDisAppear:)]) {
        [_delegate timelineTableViewControllerWillDisAppear:self];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _emptyView.frame = CGRectSetY([UIScreen mainScreen].bounds, -64);
}

- (void)initTimeline
{
    _logs = [[NSMutableArray alloc] initWithCapacity:0];
    _logsHeightCache = [[NSMutableDictionary alloc] initWithCapacity:0];
    _dayCellDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    // 작성 상태 구분
    if (_isViewMode) { // 보기 모드 (후 처리)
        [self loadTimelineForViewModeWithSinceId:nil];
    } else {
        [self loadTimelineForWriteMode];
    }
}

- (void)loadTimelineForWriteMode
{
    [_activityIndicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray *localLogs = [[VLOLocalStorage loadTimelineCellsIn:_travel fromCell:@"top"] mutableCopy];
        _logs = [self logListWithDayLogFromLogList:localLogs]; // 불러온 쎌 목록에 Day쎌 추가
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_logs.count > 0) {
                [_activityIndicator stopAnimating];
            }
            
            [self updateTimelineLayout]; // 엠티뷰, 데이쎌 스크롤바 인디케이터 표기 등 (후 처리)
            
            if (_logs.count <= 0) {
                [self setTimelineLastStateInfoForEmpty]; // 마지막 작성 시점 등 처리 (후 처리)
            }
            
            if ([_delegate respondsToSelector:@selector(timelineTableViewControllerDidInitLogList:)]) {
                [_delegate timelineTableViewControllerDidInitLogList:self];
            } // UI 반영 작업 (후 처리)
            
            [self syncTimeline];
        });
    });
}

- (void)syncTimeline
{
    if (_isViewMode || _isPhotoEditingMode) {
        return;
    } else {
        if ([_syncDelegate respondsToSelector:@selector(timelineTableViewControllerBeginSync:)]) {
            [_syncDelegate timelineTableViewControllerBeginSync:self];
        } // 싱크 버튼 회전 UI 위한 protocol
        
        _isSyncOn = YES;
        if ([self isRemainUnSyncedLog]) {
            [_syncStatusBar startContentSyncOnViewController:self];
        } else if (_travel.serverId) {
            [self syncPhotosInTimeline];
        }
        [VLOSyncManager syncGetTimelineIn:_travel diffResult:^(NSMutableArray *insertDiffs, NSMutableArray *deleteDiffs) {
            _isInitForWriteMode = YES;
            [_activityIndicator stopAnimating];
            if ([_delegate respondsToSelector:@selector(timelineTableViewController:didGetTravelServerId:)]) {
                [_delegate timelineTableViewController:self didGetTravelServerId:_travel.serverId];
            } // 여행기 싱크가 될 경우 (후 처리)
            
            [self setTimelineWithInsertDiff:insertDiffs andDeleteDiffs:deleteDiffs]; // UI 반영
            [self setSyncMessageWithInsertDiffs:insertDiffs andDeleteDiffs:deleteDiffs]; // 싱크에 대한 얇은 노티 (후 처리)
            
            [VLOSyncManager syncPostTimelineIn:_travel handler:^{ // 단말의 변경분 sync
                _isSyncOn = NO;
                if ([self isRemainUnSyncedLog]) {
                    [self showSyncFailMessage];
                }
                [self syncAddedPhotoInTimeline]; // 사진 더하기 쪽 싱크
                [self syncPhotosInTimeline]; // 사진 정보 서버와 싱크
                [self syncLikeInfoInTimeline]; // 좋아요 정보 싱크
                [_syncStatusBar stopContentSync];
            }];
        }];
    }
}

- (void)setTimelineWithInsertDiff:(NSArray *)insertDiffs andDeleteDiffs:(NSArray *)deleteDiffs // 데이터 전체 로드시 필요 없는 부분 (싱크 작업 후 UI 처리)
{
    NSMutableArray *removeListFromDuplicated = [[NSMutableArray alloc] initWithCapacity:0];
    for (id diff in insertDiffs) {
        VLOInsertDiffFromServer *insertDiff;
        if ([diff isKindOfClass:[NSDictionary class]]) {
            insertDiff = [diff objectForKey:@"insertDiff"];
            NSString *duplicatedId = [diff objectForKey:@"timelineId"];
            
            NSArray *copiedLogs = [_logs copy];
            for (VLOLog *log in copiedLogs) {
                if ([log.timelineId isEqualToString:duplicatedId]) {
                    [removeListFromDuplicated addObject:log];
                }
            }
        }
        else {
            insertDiff = (VLOInsertDiffFromServer*)diff;
        }
        [self addLogToDataSource:insertDiff.log];
    }
    
    for (VLOLog *removeLog in removeListFromDuplicated) {
        [self removeLog:removeLog forUserAction:NO];
    }
    
    for (id diff in deleteDiffs) {
        VLODeleteDiffFromServer *deleteDiff = (VLODeleteDiffFromServer *)diff;
        NSArray *copiedLogs = [_logs copy];
        for (VLOLog *log in copiedLogs) {
            if ([deleteDiff.cellId isEqualToString:log.timelineId]) {
                [self removeLog:log forUserAction:NO];
            }
        }
    }
    
    [self updateTimelineLayout];
}

- (void)setSyncMessageWithInsertDiffs:(NSMutableArray *)insertDiffs andDeleteDiffs:(NSMutableArray *)deleteDiffs // 타임라인 상에 노티 (우선 푸쉬)
{
    for (id diff in insertDiffs) {
        VLOInsertDiffFromServer *insertDiff = nil;
        if ([diff isKindOfClass:[NSDictionary class]]) {
            insertDiff = [diff objectForKey:@"insertDiff"];
        }
        else {
            insertDiff = (VLOInsertDiffFromServer *)diff;
        }
        NSArray *deleteDiffsCopy = [deleteDiffs copy];
        for (id diff in deleteDiffsCopy) {
            VLODeleteDiffFromServer *deleteDiff = nil;
            if ([diff isKindOfClass:[NSDictionary class]]) {
                deleteDiff = [diff objectForKey:@"deleteDiff"];
            }
            else {
                deleteDiff = (VLODeleteDiffFromServer *)diff;
            }
            
            if (insertDiff.log.ancestorId.length > 0 && deleteDiff.ancestorId > 0
                && [insertDiff.log.ancestorId isEqualToString:deleteDiff.ancestorId]) {
                [deleteDiffs removeObject:diff];
            }
        }
    }
    BOOL hasBeenOpened = [self hasBeenOpened];
    
    if (deleteDiffs.count > 1 && insertDiffs.count == 0) {
        NSString *toastMessage = [NSString stringWithFormat:NSLocalizedString(@"toast_timeline_did_sync_many_post", nil), deleteDiffs.count, NSLocalizedString(@"toast_timeline_did_work_deleted", )];
        [VLOAPNSManager makeToastWithMessage:toastMessage backgroundColor:[UIColor vlo_statusBarGrayColor]];
    }
    else if ((insertDiffs.count + deleteDiffs.count) > 1) {
        NSString *toastMessage = [NSString stringWithFormat:NSLocalizedString(@"toast_timeline_did_sync_many_post", nil), insertDiffs.count + deleteDiffs.count, (hasBeenOpened) ? NSLocalizedString(@"toast_timeline_did_work_updated", ) : NSLocalizedString(@"toast_timeline_did_work_loaded", )];
        [VLOAPNSManager makeToastWithMessage:toastMessage backgroundColor:[UIColor vlo_statusBarGrayColor]];
    }
    else if (insertDiffs.count == 1) {
        id diff = insertDiffs[0];
        VLOInsertDiffFromServer *insertDiff = nil;
        if ([diff isKindOfClass:[NSDictionary class]]) {
            insertDiff = [diff objectForKey:@"insertDiff"];
        }
        else {
            insertDiff = (VLOInsertDiffFromServer *)diff;
        }
        
        VLOLog *insertedLog = insertDiff.log;
        
        NSString *cellTypeString;
        if (insertedLog.type == VLOLogTypeTitle) {
            cellTypeString = NSLocalizedString(@"toast_cellType_quote", );
        } else if (insertedLog.type == VLOLogTypeText) {
            cellTypeString = NSLocalizedString(@"toast_cellType_note", );
        } else if (insertedLog.type == VLOLogTypeMap) {
            cellTypeString = NSLocalizedString(@"toast_cellType_location", );
        } else if (insertedLog.type == VLOLogTypeRoute) {
            cellTypeString = NSLocalizedString(@"toast_cellType_route", );
        } else if (insertedLog.type == VLOLogTypePhoto) {
            VLOPhotoLog *photoLog = (VLOPhotoLog *)insertedLog;
            if (photoLog.count > 1) {
                cellTypeString = NSLocalizedString(@"toast_cellType_photo", );
            } else {
                cellTypeString = NSLocalizedString(@"toast_cellType_photos", );
            }
        }
        if (cellTypeString && insertedLog.user.userName) {
            NSString *toastMessage = [NSString stringWithFormat:NSLocalizedString(@"toast_timeline_did_sync_one_post", ), insertedLog.user.userName, cellTypeString];
            [VLOAPNSManager makeToastWithMessage:toastMessage backgroundColor:[UIColor vlo_statusBarGrayColor]];
        }
    }
    else if (deleteDiffs.count == 1) {
        id diff = deleteDiffs[0];
        VLODeleteDiffFromServer *deleteDiff = nil;
        if ([diff isKindOfClass:[NSDictionary class]]) {
            deleteDiff = [diff objectForKey:@"deleteDiff"];
        }
        else {
            deleteDiff = (VLODeleteDiffFromServer *)diff;
        }
        
        NSString *cellTypeString;
        
        switch (deleteDiff.logType) {
            case VLOLogTypeTitle:
                cellTypeString = NSLocalizedString(@"toast_cellType_quote", );
                break;
            case VLOLogTypeText:
                cellTypeString = NSLocalizedString(@"toast_cellType_note", );
                break;
            case VLOLogTypeMap:
                cellTypeString = NSLocalizedString(@"toast_cellType_location", );
                break;
            case VLOLogTypeRoute:
                cellTypeString = NSLocalizedString(@"toast_cellType_route", );
                break;
            case VLOLogTypePhoto:
                if (deleteDiff.photoCount > 1) {
                    cellTypeString = NSLocalizedString(@"toast_cellType_photos", );
                } else {
                    cellTypeString = NSLocalizedString(@"toast_cellType_photo", );
                }
                break;
            default:
                cellTypeString = NSLocalizedString(@"toast_cellType_default", );
                break;
        }
        
        if (cellTypeString && deleteDiff.userName) {
            NSString *toastMessage = [NSString stringWithFormat:NSLocalizedString(@"toast_timeline_did_sync_one_deleted_post", nil), deleteDiff.userName, cellTypeString];
            [VLOAPNSManager makeToastWithMessage:toastMessage backgroundColor:[UIColor vlo_statusBarGrayColor]];
        }
    }
}


- (void)syncAddedPhotoInTimeline
{
    [VLOSyncManager syncAddPhotoIn:_travel success:^{
        [self syncPhotosInTimeline];
    } failureToReSync:^{
        [self syncTimeline];
    }];
}

- (void)syncPhotosInTimeline
{
    NSArray *photoLogList = [self getPhotoLogsStartFromVisibleArea];
    
    [VLOSyncManager syncPhotosForDownloadInTravel:_travel photoLogList:photoLogList downloadHandler:^(VLOPhotoLog *photoLog) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[_logs indexOfObject:photoLog] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [VLOSyncManager syncPhotosForUploadInTravel:_travel uploadHandler:^(NSInteger done, NSInteger fail, NSInteger total, VLOPhotoLog *photoLog) {
        if (_syncStatusBar) {
            if (done < total) {
                [_syncStatusBar setUploadPhotosProgressWithDone:done+1 total:total onViewController:self];
            } else {
                [_syncStatusBar stopUploadPhotosSync];
                if (!_isSyncOn && [_syncDelegate respondsToSelector:@selector(timelineTableViewControllerEndSync:)]) { // 싱크 버튼 UI 적용
                    [_syncDelegate timelineTableViewControllerEndSync:self];
                }
                if (fail > 0) {
                    [self showSyncFailMessage];
                }
            }
        }
    }];
}

- (NSArray *)getPhotoLogsStartFromVisibleArea
{
    NSInteger visibleRow = ((NSIndexPath *)[[self.tableView indexPathsForVisibleRows] lastObject]).row;
    NSMutableArray *photoLogList = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSInteger i = 0; i < MAX(visibleRow, _logs.count-visibleRow); i ++) {
        VLOLog *topWayLog;
        if (visibleRow-i-1 >= 0) {
            topWayLog = [_logs objectAtIndex:visibleRow-i-1];
            if ([topWayLog isKindOfClass:[VLOPhotoLog class]]) {
                [photoLogList addObject:topWayLog];
            }
        }
        VLOLog *bottomWayLog;
        if (visibleRow + i < _logs.count) {
            bottomWayLog = [_logs objectAtIndex:visibleRow + i];
            if ([bottomWayLog isKindOfClass:[VLOPhotoLog class]]) {
                [photoLogList addObject:bottomWayLog];
            }
        }
    }
    return photoLogList;
}

- (BOOL)isRemainUnSyncedLog
{
    return [VLOLocalStorage countOfUnsyncedTimeline:_travel] > 0;
}

static BOOL isFailMessageOn = NO;
- (void)showSyncFailMessage
{
    BOOL isSyncOn = [VLOSyncManager getSyncGetStateInTravel:_travel] || [VLOSyncManager getSyncPostStateInTravel:_travel];
    if (isSyncOn) {
        return;
    }
    if (!isFailMessageOn) {
        [VLOAPNSManager makeToastWithMessage:NSLocalizedString(@"story_sync_statusbar_fail", ) backgroundColor:[UIColor vlo_statusBarRedColor] complete:^{
            isFailMessageOn = NO;
        }];
        isFailMessageOn = YES;
    }
    if ([_syncDelegate respondsToSelector:@selector(timelineTableViewControllerSyncFaliure:)]) { // 싱크 버튼 UI 적용
        [_syncDelegate timelineTableViewControllerSyncFaliure:self];
    }
}

- (void)syncLikeInfoInTimeline
{
    [VLONetwork getLikeInfosInTravel:_travel success:^(NSDictionary *responseObject) {
        for (VLOLog *log in _logs) {
            if (log.type == VLOLogTypeDay) {
                continue;
            }
            NSDictionary *likeInfo;
            if (log.ancestorId) {
                likeInfo = [responseObject objectForKey:log.ancestorId];
            }
            else {
                likeInfo = [responseObject objectForKey:log.timelineId];
            }
            if (log.likeCount != [[likeInfo objectForKey:@"likeCount"] integerValue] || log.isLiked != [[likeInfo objectForKey:@"like"] boolValue]) {
                if (likeInfo) {
                    log.likeCount = [[likeInfo objectForKey:@"likeCount"] integerValue];
                    log.isLiked = [[likeInfo objectForKey:@"like"] boolValue];
                }
                else {
                    log.likeCount = 0;
                    log.isLiked = NO;
                }
                [VLOLocalStorage updateLikeInfoWithTimelineCell:log];
            }
        }
        NSInteger totalCount = 0;
        for (NSString *key in responseObject) {
            totalCount += [[[responseObject objectForKey:key] objectForKey:@"likeCount"] integerValue];
        }
        _travel.likeCount = totalCount;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(NSError *error, NSString *message) {
        
    }];
}


#pragma mark - load timeline for view mode

- (void)loadTimelineForViewModeWithSinceId:(NSString *)sinceId
{
    if (_isCalledNextCellForViewMode || _isEndOfTravelForViewMode) {
        return;
    }
    _isCalledNextCellForViewMode = YES;
    
    if (_activityIndicator) {
        [_activityIndicator startAnimating];
    }
    [VLONetwork getTimelineListinTravel:_travel sinceId:sinceId count:VLO_GETSYNC_LIMT success:^(NSArray *responseObject) {
        [_logs addObjectsFromArray:[self logListWithDayLogFromLogList:responseObject]];
        [self updateTimelineLayout];
        
        _isCalledNextCellForViewMode = NO;
        if (responseObject.count < VLO_GETSYNC_LIMT) {
            _isEndOfTravelForViewMode = YES;
        }
        
        [_activityIndicator stopAnimating];
    } failure:^(NSError *error, NSString *message) {
        _isCalledNextCellForViewMode = NO;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert_error",)
                                                                       message:NSLocalizedString(@"load_timeline_error_message", )
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"alert_close", )
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *action) {
                                                            }];
        [alert addAction:closeAction];
        [self presentViewController:alert animated:YES completion:nil];
        [_activityIndicator stopAnimating];
    }];
}

- (NSMutableArray *)logListWithDayLogFromLogList:(NSArray *)logList
{
    NSMutableArray *resultLogList = [[NSMutableArray alloc] initWithCapacity:0];
    VLOLog *previousLog = [_logs lastObject];
    for (VLOLog *log in logList) {
        if (previousLog == nil || [VLOUtilities calculateDaysBetweenFrom:log.date withGMTOffset:[log.timezone.offsetFromGMT integerValue] to:previousLog.date withGMTOffset:[previousLog.timezone.offsetFromGMT integerValue]] < 0) {
            NSInteger comparedDay = [VLOUtilities calculateDaysBetweenFrom:_travel.startDate withGMTOffset:[_travel.timezone.offsetFromGMT integerValue] to:log.date withGMTOffset:[log.timezone.offsetFromGMT integerValue]] + 1;
            VLODayLog *day = [[VLODayLog alloc] initWithDay:comparedDay];
            if (![_dayCellDictionary objectForKey:day.day]) {
                day.date = log.date;
                day.timezone = log.timezone;
                [resultLogList addObject:day];
                [_dayCellDictionary setObject:day forKey:day.day];
            }
        }
        [resultLogList addObject:log];
        previousLog = log;
    }
    return resultLogList;
}

- (BOOL)isLogHasProb:(VLOLog *)log
{
    if ([log class] == [VLOPhotoLog class]) {
        if (((VLOPhotoLog *)log).count == 0) {
            return YES;
        }
    }
    else if ([log class] == [VLOTextLog class]) {
        if ([((VLOTextLog *)log).text length] == 0) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - add log

- (void)addLog:(VLOLog *)log // 유저 작성 동작시
{
    [self setTimelineLastStateInfoWithLog:log];
    
    [self addLogToDataSource:log];
    [self updateTimelineLayout];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_logs indexOfObject:log] inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    [self syncTimeline];
    
    [self countUpWriteCount];
}

- (void)countUpWriteCount
{
    NSNumber *cellWriteCount = [[NSUserDefaults standardUserDefaults] objectForKey:VLO_CELL_WRITE_COUNT_KEY];
    if (!cellWriteCount) {
        [[NSUserDefaults standardUserDefaults] setValue:@(1) forKey:VLO_CELL_WRITE_COUNT_KEY];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setValue:@(cellWriteCount.integerValue+1) forKey:VLO_CELL_WRITE_COUNT_KEY];
    }
}


#pragma mark - update data with log

- (void)addLogToDataSource:(VLOLog *)log
{
    if ([self isLogHasProb:log]) {
        return;
    }
    if (log.user == nil) {
        log.user = [VLOLocalStorage getCurrentUser];
    }
    
    NSInteger logOrder = _logs.count;
    
    if (_addToBelowPivotLog) {
        NSInteger pivotIndex = [_logs indexOfObject:_addToBelowPivotLog];
        if (pivotIndex < _logs.count-1) {   // 예외 처리
            pivotIndex += 1;
            
            VLOLog *pivotLog = [_logs objectAtIndex:pivotIndex]; // 예외 처리
            if ([pivotLog.date compare:log.date] >= 0) {    // 예외 처리
                logOrder = pivotIndex;
            }
        }
    }
    
    [self validTimeInfoToLog:log withLogOrder:logOrder]; // 예외 처리
    
    VLOLog *lastAtIndex;
    for (NSInteger i = logOrder-1; i >= 0; i --) {
        VLOLog *logAtIndex = [_logs objectAtIndex:i];
        if (logAtIndex.type == VLOLogTypeDay) {
            logOrder = i;
            continue;
        }
        else if (log.previousCellId.length > 0 && [log.previousCellId isEqualToString:logAtIndex.timelineId])
        {
            logOrder = i + 1;
            lastAtIndex = logAtIndex;
            break;
        }
        else if (log.previousCellId.length > 0)
        {
            logOrder = i;
            continue;
        }
        // 기본 로직
        else if ([self isLog:log afterPivotLog:logAtIndex])
        {
            logOrder = i + 1;
            lastAtIndex = logAtIndex;
            log.previousCellId = logAtIndex.timelineId;
            break;
        } // 기본 로직
        logOrder = i;
    }
    
    // ==============================
    // 싱크 후 순서가 엉키는 상황을 위한 로직
    for (NSInteger i = logOrder; i < [_logs count]; i ++) {
        VLOLog *logAtIndex = [_logs objectAtIndex:i];
        if ([VLOUtilities calculateDaysBetweenFrom:log.date withGMTOffset:[log.timezone.offsetFromGMT integerValue] to:logAtIndex.date withGMTOffset:[logAtIndex.timezone.offsetFromGMT integerValue]] == 0 && logAtIndex.type == VLOLogTypeDay) {
            continue;
        }
        if ([log.date compare:logAtIndex.date] <= 0)
        {
            logOrder = i;
            if (logAtIndex.type == VLOLogTypeDay) {
                if (i == 0) {
                    log.previousCellId = @"top";
                }
                else {
                    log.previousCellId = ((VLOLog *)[_logs objectAtIndex:i-1]).timelineId;
                }
            } else {
                if (!lastAtIndex) {
                    log.previousCellId = @"top";
                } else {
                    log.previousCellId = lastAtIndex.timelineId;
                }
            }
            break;
        }
        lastAtIndex = logAtIndex;
        logOrder = i+1;
        log.previousCellId = lastAtIndex.timelineId;
    }
    // ===================================
    
    BOOL isAddDayLog = [self addDayLogWithLog:log logOrder:logOrder];
    if (isAddDayLog) {
        logOrder += 1;
    }
    [_logs insertObject:log atIndex:logOrder];
    
    if (log.timelineId == nil) {
        if (logOrder > 0 && [log.date compare:((VLOLog *)[_logs objectAtIndex:logOrder-1]).date] == NSOrderedAscending) {
            log.date = ((VLOLog *)[_logs objectAtIndex:logOrder-1]).date;
            log.timezone = ((VLOLog *)[_logs objectAtIndex:logOrder-1]).timezone;
        }
        log.travelId = _travel.travelId;
        [VLOLocalStorage insertTimelineCell:log];
    }
    
    _addToBelowPivotLog = nil; // add below
}

- (void)validTimeInfoToLog:(VLOLog *)log withLogOrder:(NSInteger)logOrder
{
    if (log.date == nil) {
        if ([_logs count] == 0) {
            log.date = _travel.startDate;
        }
        else if (logOrder > 0) {
            log.date = ((VLOLog *)[_logs objectAtIndex:logOrder-1]).date;
        }
    }
    if (log.timezone == nil) {
        log.timezone = [[VLOTimezone alloc] initWithTimezone:[NSTimeZone systemTimeZone]];
    }
}

- (BOOL)isLog:(VLOLog *)log afterPivotLog:(VLOLog *)pivotLog
{
    return pivotLog.type != VLOLogTypeDay && ([VLOUtilities calculateDaysBetweenFrom:log.date withGMTOffset:[log.timezone.offsetFromGMT integerValue] to:pivotLog.date withGMTOffset:[pivotLog.timezone.offsetFromGMT integerValue]] <= 0 || [log.date compare:pivotLog.date] >= 0);
}

- (BOOL)addDayLogWithLog:(VLOLog *)log logOrder:(NSInteger)logOrder
{
    VLOLog *previousLog = nil;
    if (logOrder > 0 && _logs.count > 0) {
        previousLog = (VLOLog *)[_logs objectAtIndex:logOrder-1];
    }
    if (logOrder <= 0 || [VLOUtilities calculateDaysBetweenFrom:previousLog.date withGMTOffset:[previousLog.timezone.offsetFromGMT integerValue] to:log.date withGMTOffset:[log.timezone.offsetFromGMT integerValue]] > 0) {
        NSInteger comparedDay = [VLOUtilities calculateDaysBetweenFrom:_travel.startDate withGMTOffset:[_travel.timezone.offsetFromGMT integerValue] to:log.date withGMTOffset:[log.timezone.offsetFromGMT integerValue]] + 1;
        VLODayLog *day = [[VLODayLog alloc] initWithDay:comparedDay];
        if (![_dayCellDictionary objectForKey:day.day]) {
            day.date = log.date;
            day.timezone = log.timezone;
            [_logs insertObject:day atIndex:logOrder];
            logOrder += 1;
            [_dayCellDictionary setObject:day forKey:day.day];
            
            return YES;
        }
    }
    return NO;
}

- (void)updateLog:(VLOLog *)log isChangeDate:(BOOL)isChange
{
    _lastDate = log.date;
    _lastTimeZone = [log.timezone getNSTimezone];
    _lastWroteDate = [NSDate date];
    [self setTimelineLastStateInfoWithLog:log];
    
    if (![_logs containsObject:log]) {
        log.timelineId = nil;
        if (isChange) { log.previousCellId = nil; }
        [self addLog:log];
        return;
    }
    if (isChange) {
        NSInteger logOrder = [_logs indexOfObject:log];
        [_logs removeObject:log];
        
        BOOL isLogOrderValidate = logOrder != NSNotFound && logOrder != 0;
        BOOL isLogAtEndOfDay = _logs.count == logOrder || ((VLOLog *)[_logs objectAtIndex:logOrder]).type == VLOLogTypeDay;
        BOOL isLogAfterDayLog = ((VLOLog *)[_logs objectAtIndex:logOrder-1]).type == VLOLogTypeDay;
        if (isLogOrderValidate && isLogAtEndOfDay && isLogAfterDayLog) {
            logOrder -= 1;
            [_dayCellDictionary removeObjectForKey:((VLODayLog *)[_logs objectAtIndex:logOrder]).day];
            [_logs removeObjectAtIndex:logOrder];
        }
        
        for (NSInteger i = _logs.count-1; i >= 0; i --) {
            VLOLog *logAtIndex = [_logs objectAtIndex:i];
            if ([self isLog:log afterPivotLog:logAtIndex]) {
                logOrder = i + 1;
                log.previousCellId = logAtIndex.timelineId;
                break;
            }
            logOrder = i;
            log.previousCellId = @"top";
        }
        
        BOOL isAddDayLog = [self addDayLogWithLog:log logOrder:logOrder];
        if (isAddDayLog) {
            logOrder += 1;
        }
        [_logs insertObject:log atIndex:logOrder];
        
        if (logOrder > 0 && [log.date compare:((VLOLog *)[_logs objectAtIndex:logOrder-1]).date] == NSOrderedAscending) {
            log.date = ((VLOLog *)[_logs objectAtIndex:logOrder-1]).date;
            log.timezone = ((VLOLog *)[_logs objectAtIndex:logOrder-1]).timezone;
        }
    }
    [VLOLocalStorage updateTimelineCell:log isChangedOrder:isChange];
    
    [self.tableView reloadData];
    
    [self syncTimeline];
}

- (void)updateAddPhotoLog:(VLOPhotoLog *)log
{
    _lastDate = log.date;
    _lastTimeZone = [log.timezone getNSTimezone];
    _lastWroteDate = [NSDate date];
    [self setTimelineLastStateInfoWithLog:log];
    
    [VLOLocalStorage updateFromAddPhotoTimelineCell:log];
    
    [self.tableView reloadData];
    
    [self syncTimeline];
}

- (void)updateLog:(VLOLog *)log isSetToBelow:(VLOLog *)previous
{
    [self.tableView beginUpdates];
    if (previous.type != VLOLogTypeDay) {
        log.previousCellId = previous.timelineId;
    }
    else if ([_logs indexOfObject:previous] != 0) {
        VLOLog *realPrevious = [_logs objectAtIndex:[_logs indexOfObject:previous]-1];
        log.previousCellId = realPrevious.timelineId;
    }
    else {
        log.previousCellId = nil;
    }
    NSInteger beforeIndex = [_logs indexOfObject:log];
    NSInteger afterIndex;
    NSInteger logOrder = [_logs indexOfObject:log];
    NSInteger firstRow = logOrder;
    [_logs removeObject:log];
    if ((_logs.count == logOrder || ((VLOLog *)[_logs objectAtIndex:logOrder]).type == VLOLogTypeDay) && ((VLOLog *)[_logs objectAtIndex:logOrder-1]).type == VLOLogTypeDay) {
        logOrder -= 1;
        [_dayCellDictionary removeObjectForKey:((VLODayLog *)[_logs objectAtIndex:logOrder]).day];
        [_logs removeObjectAtIndex:logOrder];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:logOrder inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    NSDate *date = previous.date;
    VLOTimezone *timezone = previous.timezone;
    if (previous.type == VLOLogTypeDay) {
        date = ((VLOLog *)[_logs objectAtIndex:[_logs indexOfObject:previous]+1]).date;
        timezone = ((VLOLog *)[_logs objectAtIndex:[_logs indexOfObject:previous]+1]).timezone;
    }
    log.date = date;
    log.timezone = timezone;

    [_logs insertObject:log atIndex:[_logs indexOfObject:previous] + 1];
    [VLOLocalStorage updateTimelineCell:log isChangedOrder:YES];
    
    logOrder = [_logs indexOfObject:previous] + 1;
    [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:firstRow inSection:0] toIndexPath:[NSIndexPath indexPathForRow:logOrder inSection:0]];
    [self.tableView endUpdates];
    
    VLOTimelineCell *selectedCell = (VLOTimelineCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:logOrder inSection:0]];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        selectedCell.alpha = 0.0f;
        selectedCell.backgroundColor = [UIColor clearColor];
    } completion:nil];
    [UIView animateWithDuration:0.3f delay:0.4f options:UIViewAnimationOptionCurveEaseIn animations:^{
        selectedCell.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self syncTimeline];
    }];
    
    afterIndex = [_logs indexOfObject:log];
    
    [VLOAnalyticsManager reportEventWithCategory:VLOCategoryCellMenu action:VLOActionChangeOrder label:nil andValue:@(labs(beforeIndex-afterIndex))];
}

- (void)removeLog:(VLOLog *)log forUserAction:(BOOL)isUserAction;
{
    if (isUserAction) {
        [self.tableView beginUpdates];
        [VLOLocalStorage removeTimelineCellForUserInteraction:log];
    }
    NSInteger index;
    index = [_logs indexOfObject:log];
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]].alpha = .0f;
    [_logs removeObject:log];
    if (isUserAction) {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if ((_logs.count == index || ((VLOLog *)[_logs objectAtIndex:index]).type == VLOLogTypeDay) && ((VLOLog *)[_logs objectAtIndex:index-1]).type == VLOLogTypeDay) {
        [_dayCellDictionary removeObjectForKey:((VLODayLog *)[_logs objectAtIndex:index-1]).day];
        [_logs removeObjectAtIndex:index-1];
        if (isUserAction) {
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    if (isUserAction) {
        [self.tableView endUpdates];
        [self setEmptyView];
        [self syncTimeline];
    } else {
        [self updateTimelineLayout];
    }
}

- (void)updateTimelineLayout
{
    [self setEmptyView];
    [self.tableView reloadData];
    if ([_delegate respondsToSelector:@selector(timelineTableViewControllerDidUpdateLogList:)]) {
        [_delegate timelineTableViewControllerDidUpdateLogList:self];
    }
}

- (void)setEmptyView
{
    if (!_isInitForWriteMode) {
        return;
    }
    
    if (_logs.count == 0) {
        if (!_emptyView) {
            _emptyView = [[[NSBundle mainBundle] loadNibNamed:@"VLOTimelineEmptyView" owner:self options:nil] firstObject];
        }
        _emptyView.frame = self.tableView.frame;
        [self.view addSubview:_emptyView];
        
        if ([_delegate respondsToSelector:@selector(timelineTableViewControllerDidShowEmptyView:)]) {
            [_delegate timelineTableViewControllerDidShowEmptyView:self];
        }
    }
    else if (_emptyView) {
        [_emptyView removeFromSuperview];
        _emptyView = nil;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _logs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_logs.count - 6 < indexPath.row && _isViewMode) {
        [self loadTimelineForViewModeWithSinceId:((VLOLog *)[_logs lastObject]).timelineId];
    }
    VLOLog *log = [_logs objectAtIndex:indexPath.row];
    VLOTimelineCell *cell;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (log.type == VLOLogTypePhoto) {
        VLOPhotoLog *photoLog = (VLOPhotoLog *)log;
        VLOTableViewPhotoCell *photoCell = [tableView dequeueReusableCellWithIdentifier:[photoLog cellNibName] forIndexPath:indexPath];
        photoCell.photoDelegate = _photoDelegate;
        cell = photoCell;
    }
    else if (log.type == VLOLogTypeText) {
        if (![cell isKindOfClass:[VLOTableViewTextCell class]] || !cell) {
            VLOTableViewTextCell *textCell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
            textCell.textCellDelegate = self;
            cell = textCell;
        }
    }
    else if (log.type == VLOLogTypeMap) {
        if (![cell isKindOfClass:[VLOTableViewMapCell class]] || !cell) {
            VLOTableViewMapCell *mapCell = [tableView dequeueReusableCellWithIdentifier:@"mapCell" forIndexPath:indexPath];
            mapCell.mapCelldelegate = _mapDelegate;
            cell = mapCell;
        }
    }
    else if (log.type == VLOLogTypeDay) {
        if (![cell isKindOfClass:[VLOTableViewDayCell class]] || !cell) {
            VLOTableViewDayCell *dayCell = [tableView dequeueReusableCellWithIdentifier:@"dayCell" forIndexPath:indexPath];
            if (_travel.hasDate) {
                dayCell.hidden = NO;
                
                if (indexPath.row == 0)
                    dayCell.isFirstDay = YES;
                else
                    dayCell.isFirstDay = NO;
                
            } else {
                dayCell.hidden = YES;
                dayCell.isFirstDay = NO;
                dayCell.height = 0.f;
            }
            cell = dayCell;
        }
    }
    else if (log.type == VLOLogTypeTitle) {
        if (![cell isKindOfClass:[VLOTableViewQuoteCell class]] || !cell) {
            VLOTableViewQuoteCell *quoteCell = [tableView dequeueReusableCellWithIdentifier:@"quoteCell" forIndexPath:indexPath];
            cell = quoteCell;
        }
    }
    else if (log.type == VLOLogTypeRoute) {
        if (![cell isKindOfClass:[VLOTableViewRouteCell class]] || !cell) {
            VLOTableViewRouteCell *routeCell = [tableView dequeueReusableCellWithIdentifier:@"routeCell" forIndexPath:indexPath];
            VLORouteLog *routelog = (VLORouteLog *)log;
            
            _lastTransportType = ((VLORouteNode *)[routelog.nodes lastObject]).transportType;
    
            cell = routeCell;
        }
    }
 
    cell.indexPath = indexPath;
    cell.log = log;
    cell.delegate = self;
    cell.clipsToBounds = NO;
    
    if (_isOrderChangeMode) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            cell.footerView.alpha = 0.0f;
            if (log.type == VLOLogTypeDay) {
                VLOTableViewDayCell *dayCell = (VLOTableViewDayCell *)cell;
                dayCell.topDivisionView.alpha = 0.0f;
            }
            if (log.type == VLOLogTypePhoto) {
                VLOTableViewPhotoCell *photoCell = (VLOTableViewPhotoCell *)cell;
                for (UIImageView *imageView in photoCell.imageViewList) {
                    imageView.userInteractionEnabled = NO;
                }
            }
            if (_orderChangeRow != indexPath.row && _orderChangeRow - 1 != indexPath.row) {
                cell.orderChangeBelowMark.alpha = 1.0f;
            }
        } completion:nil];
    }
    else {
        cell.orderChangeBelowMark.alpha = 0.0f;
        if (!_isOrderChangeModeAppear) {
            cell.footerView.alpha = 1.0f;
            
            if (log.type == VLOLogTypeDay && indexPath.row != 0) {
                VLOTableViewDayCell *dayCell = (VLOTableViewDayCell *)cell;
                dayCell.topDivisionView.alpha = 1.0f;
            }
            if (log.type == VLOLogTypePhoto) {
                VLOTableViewPhotoCell *photoCell = (VLOTableViewPhotoCell *)cell;
                for (UIImageView *imageView in photoCell.imageViewList) {
                    imageView.userInteractionEnabled = YES;
                }
            }
        }
        else
        {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                cell.footerView.alpha = 1.0f;
                
                if (log.type == VLOLogTypeDay && indexPath.row != 0) {
                    VLOTableViewDayCell *dayCell = (VLOTableViewDayCell *)cell;
                    dayCell.topDivisionView.alpha = 1.0f;
                }
                if (log.type == VLOLogTypePhoto) {
                    VLOTableViewPhotoCell *photoCell = (VLOTableViewPhotoCell *)cell;
                    for (UIImageView *imageView in photoCell.imageViewList) {
                        imageView.userInteractionEnabled = YES;
                    }
                }
            } completion:^(BOOL finished) {
                _isOrderChangeModeAppear = NO;
            }];
        }
    }
    
    
    cell.footerView.hidden = (log.type==VLOLogTypeDay);
    BOOL isWalkthrough = [_travel isWalkthrough];
    BOOL isGroup = (_travel.users.count > 1);


    BOOL isPhotoLog = (log.type == VLOLogTypePhoto);

    [cell.footerView setLayoutWithIsWalkthrough:isWalkthrough
                                     isViewMode:_isViewMode
                                        isGroup:isGroup
                                     isPhotoLog:isPhotoLog
                                        hasDate:_travel.hasDate];
    
    if (log.type == VLOLogTypeDay && !_travel.hasDate) {
        cell.height = .0f;
    }
    
    [_logsHeightCache setObject:@(cell.height) forKey:log];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:VLOTableViewPhotoCell.class] && ([tableView isDragging] || [tableView isDecelerating])) {
        [((VLOTableViewPhotoCell *)cell) photoCellDisappear];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    VLOTimelineCell *timelineCell = (VLOTimelineCell *)cell;
    timelineCell.backgroundColor = [UIColor clearColor];
    timelineCell.orderChangeBackground.alpha = 0.0f;
    if (_isOrderChangeMode && ((VLOTimelineCell *)cell).log == _orderChangingLog) {
        timelineCell.orderChangeBackground.alpha = 1.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VLOLog *log = [_logs objectAtIndex:indexPath.row];
    CGFloat height = .0f;
    if ([_logsHeightCache objectForKey:log]) {
        height = [[_logsHeightCache objectForKey:log] floatValue];
    }
    else if (log.type == VLOLogTypePhoto) {
        height = [VLOTableViewPhotoCell heightWithLog:log];
    }
    else if (log.type == VLOLogTypeText) {
        VLOTextLog *textLog = (VLOTextLog *)log;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = .0f;
        paragraphStyle.minimumLineHeight = 27.0f;
        paragraphStyle.paragraphSpacing = 5.0f;
        
        NSDictionary *attributes = @{
                                     NSParagraphStyleAttributeName : paragraphStyle,
                                     NSForegroundColorAttributeName: [UIColor vlo_blackColor],
                                     NSFontAttributeName: [UIFont ralewayRegularWithSize:VLO_TEXTCELL_FONTSIZE]
                                     };
        
        CGFloat height;
        CGSize textSize = [textLog.text boundingRectWithSize:CGSizeMake([VLOUtilities screenWidth] - 60, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        CGFloat stickerHeight = textLog.sticker.stickerImage.size.height * VLO_TEXTCELL_STICKERWIDTH / textLog.sticker.stickerImage.size.width;
        if (textLog.sticker.stickerImage.size.width == 0) {
            stickerHeight = 0;
        }
        
        if (textLog.sticker.stickerImage) {
            CGFloat stickerAreaHeight = MIN(stickerHeight + 24, textSize.height);
            CGFloat addedHeight = stickerAreaHeight * (VLO_TEXTCELL_STICKERWIDTH/([VLOUtilities screenWidth]-40.0f));
            
            height = MAX(stickerHeight + 36, textSize.height + addedHeight);
        } else {
            height = textSize.height;
        }
        return height + 10.0f + 16.0f + VLO_CELL_BOTTOMMARGIN;
    }
    else if (log.type == VLOLogTypeMap) {
        height = [VLOTableViewMapCell heightWithLog:log];
    }
    else if (log.type == VLOLogTypeDay) {
        if (_travel.hasDate) {
            CGFloat fixedBottomMargin = 71.0f;
            CGFloat topPadding = 0;
            if (indexPath.row == 0) {
                topPadding = 17.0f;
            } else {
                topPadding = 36.0f;
            }
            return topPadding + fixedBottomMargin + VLO_CELL_BOTTOMMARGIN;
        } else {
            return 0.f;
        }
    }
    else if (log.type == VLOLogTypeTitle) {
        height = [VLOTableViewQuoteCell heightWithLog:log];
    }
    else if (log.type == VLOLogTypeRoute) {
        height = [VLOTableViewRouteCell heightWithLog:log];
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VLOLog *log = [_logs objectAtIndex:indexPath.row];
    CGFloat height = .0f;
    if ([_logsHeightCache objectForKey:log]) {
        height = [[_logsHeightCache objectForKey:log] floatValue];
    }
    else if (log.type == VLOLogTypePhoto) {
        height = [VLOTableViewPhotoCell heightWithLog:log];
    }
    else if (log.type == VLOLogTypeText) {
        VLOTextLog *textLog = (VLOTextLog *)log;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = .0f;
        paragraphStyle.minimumLineHeight = 27.0f;
        paragraphStyle.paragraphSpacing = 5.0f;
        
        NSDictionary *attributes = @{
                              NSParagraphStyleAttributeName : paragraphStyle,
                              NSForegroundColorAttributeName: [UIColor vlo_blackColor],
                              NSFontAttributeName: [UIFont ralewayRegularWithSize:VLO_TEXTCELL_FONTSIZE]
                              };
        
        VLOStickerTextView *textView = [[VLOStickerTextView alloc] initWithFrame:CGRectMake(20, 0, [VLOUtilities screenWidth] - 40.0f, 0)];
        textView.text = textLog.text;
        [textView setAttributedText:[[NSAttributedString alloc] initWithString:textView.text attributes:attributes]];
        textView.scrollEnabled = NO;
        textView.clipsToBounds = YES;
        
        CGFloat stickerHeight = textLog.sticker.stickerImage.size.height * VLO_TEXTCELL_STICKERWIDTH / textLog.sticker.stickerImage.size.width;
        if (textLog.sticker.stickerImage.size.width == 0) {
            stickerHeight = 0;
        }
        
        if (textLog.sticker.stickerImage) {
            VLOSticker *sticker = textLog.sticker;
            textView.stickerImage = sticker.stickerImage;
            textView.stickerSize = CGSizeMake(VLO_TEXTCELL_STICKERWIDTH, stickerHeight);
            textView.stickerOrigin = CGPointMake(0, 24);
            textView.gap = 0;
        } else {
            textView.stickerSize = CGSizeZero;
            textView.stickerOrigin = CGPointZero;
            textView.gap = 0.0f;
            textView.stickerImage = nil;
        }
        
        CGSize textViewSize = [textView sizeThatFits:CGSizeMake([VLOUtilities screenWidth] - 40,
                                                                CGFLOAT_MAX)];
        return MAX(textViewSize.height, stickerHeight + 36) + 10.0f + VLO_CELL_BOTTOMMARGIN;
    }
    else if (log.type == VLOLogTypeMap) {
        height = [VLOTableViewMapCell heightWithLog:log];
    }
    else if (log.type == VLOLogTypeDay) {
        if (_travel.hasDate) {
            CGFloat fixedBottomMargin = 71.0f;
            CGFloat topPadding = 0;
            if (indexPath.row == 0) {
                topPadding = 17.0f;
            } else {
                topPadding = 36.0f;
            }
            return topPadding + fixedBottomMargin + VLO_CELL_BOTTOMMARGIN;
        }
        else {
            return 0;
        }
    }
    else if (log.type == VLOLogTypeTitle) {
        height = [VLOTableViewQuoteCell heightWithLog:log];
    }
    else if (log.type == VLOLogTypeRoute) {
        height = [VLOTableViewRouteCell heightWithLog:log];
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (_logs.count <= 0) {
        return nil;
    }
    if (!_footerView) {
        _footerView = [[VLOTimelineTableFooterView alloc] initWithTravel:_travel];
        _footerView.delegate = _footerDelegate;
    } else {
        _footerView.travel = _travel;
    }
    return _footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0 && _logs.count > 0) {
        return [VLOTimelineTableFooterView heightWithTravel:_travel];
    }
    return .0f;
}


#pragma mark - tableview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tableView.contentInset.top < 64.0f + SUMMARY_HEIGHT) {
        return;
    }
    // =======================================================
    //          scrollView가 빠르게 스크롤되고있는지 확인 시작
    //       http://stackoverflow.com/a/9705218/4356845
    // =======================================================
    
    VLOScrollViewSpeed speed = VLOScrollViewSpeedSlow;
    CGPoint currentOffset = scrollView.contentOffset;
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    NSTimeInterval timeDiff = currentTime - _lastOffsetCapture;
    if(timeDiff > 0.1) {
        CGFloat distance = currentOffset.y - _lastOffset.y;
        //The multiply by 10, / 1000 isn't really necessary.......
        CGFloat scrollSpeedNotAbs = (distance * 10) / 1000; //in pixels per millisecond
        
        CGFloat scrollSpeed = fabs(scrollSpeedNotAbs);
        static CGFloat VLOScrollViewSpeedFastValue = 2.3f;  // 해당 값보다 scrollSpeed가 클 경우 `빠른 스크롤`이라 판단.
        if (scrollSpeed > VLOScrollViewSpeedFastValue) {
            _isScrollingFast = YES;
            speed = VLOScrollViewSpeedFast;
        } else {
            _isScrollingFast = NO;
            speed = VLOScrollViewSpeedSlow;
        }
        
        _lastOffset = currentOffset;
        _lastOffsetCapture = currentTime;
    }

    // =======================================================
    //          scrollView가 빠르게 스크롤되고있는지 확인 종료
    // =======================================================
    
    __weak id<VLOTimelineTableViewDelegate> delegate = ((VLOTimelineTableView *)self.tableView).scrollTopDelegate;
    if ([delegate respondsToSelector:@selector(tableViewDidScroll:)]) {
        [delegate tableViewDidScroll:((VLOTimelineTableView *)self.tableView)];
    }
    
    if (fabs(scrollView.contentOffset.y - _lastScrolledContentOffset) < 3 || scrollView.contentOffset.y + 50.0f >= scrollView.contentSize.height - scrollView.frame.size.height) {
        if (!_isViewMode) {
            [self setTimelineLastContentOffset:@(scrollView.contentOffset.y)];
        }
    }
    _lastScrolledContentOffset = scrollView.contentOffset.y;
    
    [_indicator scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [_indicator scrollViewDidEndScrollingAnimation:scrollView];
    _canOpenDetailView = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_indicator scrollViewDidEndDecelerating:scrollView];
    
    if (!_isViewMode) {
        [self setTimelineLastContentOffset:@(scrollView.contentOffset.y)];
    }
    _canOpenDetailView = YES;
    _isMovementDecelerate = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_indicator scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    if (!decelerate) {
        if (!_isMovementDecelerate) {
            _canOpenDetailView = YES;
        }
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    _canOpenDetailView = NO;
    _isMovementDecelerate = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _canOpenDetailView = NO;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [_indicator scrollViewDidScrollToTop:scrollView];
    
    if (!_isViewMode) {
        [self setTimelineLastContentOffset:@(scrollView.contentOffset.y)];
    }
}


#pragma mark - Timeline cell delegate

- (void)timelineCellDidSelectMoreButton:(VLOTimelineCell *)cell
{
    _editingCell = cell;

    NSString *typeName = [self cellTypeName:cell];

    VLOActionSheet *moreButtonActionSheet = [self showMoreActionSheetWithCellTypeName:typeName];
    moreButtonActionSheet.dismissHandler = ^{
        [cell.footerView highlightMoreButton:NO];
    };

}


- (void)timelineCellDidSelectShareButton:(VLOTimelineCell *)cell
{
    _editingCell = cell;

    NSString *typeName = [self cellTypeName:cell];
    VLOActionSheet *shareButtonActionSheet = [self showShareActionSheetWithCellTypeName:typeName];
    shareButtonActionSheet.dismissHandler = ^{
        [cell.footerView highlightShareButton:NO];
    };
}


- (NSString *)cellTypeName:(VLOTimelineCell *)cell
{
    NSString *typeName = nil;
    switch (cell.log.type) {
        case VLOLogTypeText:
            typeName = NSLocalizedString(@"menuButton_Note", );
            break;
        case VLOLogTypeRoute:
            typeName = NSLocalizedString(@"menuButton_Route", );
            break;
        case VLOLogTypeTitle:
            typeName = NSLocalizedString(@"menuButton_Quote", );
            break;
        case VLOLogTypePhoto:
            typeName = NSLocalizedString(@"menuButton_Photo", );
            break;
        case VLOLogTypeMap:
            typeName = NSLocalizedString(@"menuButton_Location", );
            break;
        default:
            typeName = @"__unknown_type__";
    }

    return typeName;
}

- (void)timelineCellDidSelectAddBelowButton:(VLOTimelineCell *)cell
{
    _editingCell = cell;
    _addToBelowPivotLog = _editingCell.log;
    [self.delegate timelineTableViewController:self didAddToBelowOfLog:_addToBelowPivotLog];
}

- (void)timelineCellDidSelectedForAddToBelow:(VLOTimelineCell *)cell
{
    _orderChangingLog.date = cell.log.date;
    [self updateLog:_orderChangingLog isSetToBelow:cell.log];
    
    [self endOrderChangeModeWithIsChanged:YES];
    
    if ([_delegate respondsToSelector:@selector(timelineTableViewController:didChangingOrderStarted:)]) {
        [_delegate timelineTableViewController:self didChangingOrderStarted:NO];
    }
}

- (void)timelineCellDidSelectLikeButton:(VLOTimelineCell *)cell
{
    if (cell.log.isLiked) {
        [self setDisLikeToCell:cell];
        [VLONetwork disLikeToTimelineCell:cell.log inTravel:_travel success:^(NSDictionary *responseObject) {
            [self setLikeInfoWithResponseObject:responseObject forCell:cell];
        } failure:^(NSError *error, NSString *message) {
            [VLONetwork getLikeFromCell:cell.log inTravel:_travel success:^(NSDictionary *responseObject) {
                [self setLikeInfoWithResponseObject:responseObject forCell:cell];
            } failure:^(NSError *error, NSString *message) {
            }];
        }];
    }
    else {
        
        if ([cell.footerView isMyCell]) {
            [cell.footerView.likeView shake];
            return;
        }
        
        [self setLikeToCell:cell];
        [VLONetwork likeToTimelineCell:cell.log inTravel:_travel success:^(NSDictionary *responseObject) {
            [self setLikeInfoWithResponseObject:responseObject forCell:cell];
        } failure:^(NSError *error, NSString *message) {
            [VLONetwork getLikeFromCell:cell.log inTravel:_travel success:^(NSDictionary *responseObject) {
                [self setLikeInfoWithResponseObject:responseObject forCell:cell];
            } failure:^(NSError *error, NSString *message) {
            }];
        }];
    }
}


- (void)setLikeToCell:(VLOTimelineCell *)cell
{
    VLOLog *log = cell.log;
    log.likeCount = log.likeCount + 1;
    log.isLiked = YES;
    cell.log = log;
    _travel.likeCount += 1;
    [self applyUILikeInfoChangedCell:cell];
}

- (void)setDisLikeToCell:(VLOTimelineCell *)cell
{
    VLOLog *log = cell.log;
    log.likeCount = log.likeCount - 1;
    log.isLiked = NO;
    cell.log = log;
    _travel.likeCount -= 1;
    [self applyUILikeInfoChangedCell:cell];
}

- (void)applyUILikeInfoChangedCell:(VLOTimelineCell *)cell
{
    BOOL isWalkthrough = [_travel isWalkthrough];
    BOOL isGroup = (_travel.users.count > 1);
    BOOL isPhotoLog = (cell.log.type == VLOLogTypePhoto);
    
    [cell.footerView setLayoutWithIsWalkthrough:isWalkthrough
                                     isViewMode:_isViewMode
                                        isGroup:isGroup
                                     isPhotoLog:isPhotoLog
                                        hasDate:_travel.hasDate];
    _footerView.travel = _travel;
}

- (void)setLikeInfoWithResponseObject:(NSDictionary *)responseObject forCell:(VLOTimelineCell *)cell
{
    NSInteger diff = [[responseObject objectForKey:@"likeCount"] integerValue] - cell.log.likeCount;
    VLOLog *log = cell.log;
    log.likeCount = [[responseObject objectForKey:@"likeCount"] integerValue];
    log.isLiked = [[responseObject objectForKey:@"like"] boolValue];
    [VLOLocalStorage updateLikeInfoWithTimelineCell:log];
    
    _travel.likeCount += diff;
}


- (VLOActionSheet*)showShareActionSheetWithCellTypeName:(NSString *)type
{
    UIFont *itemFont = [UIFont museoSans500WithSize:15.0f];
    VLOActionSheet *actionSheet = [[VLOActionSheet alloc] init];
    VLOActionSheetSection *shareSection = [[VLOActionSheetSection alloc] init];

    VLOLogType sharedCellType = _editingCell.log.type;
    if (!_isViewMode) {
        // share
        UIColor *facebookColor = [UIColor colorWithHexString:@"#3A56A1"];
        UIColor *instagramColor = [UIColor colorWithHexString:@"#48769D"];
        UIColor *itemColor = [UIColor whiteColor];

        shareSection = [[VLOActionSheetSection alloc] init];

        VLOActionSheetItem *facebookShareItem = [[VLOActionSheetItem alloc] initWithTitle:NSLocalizedString(@"timeline_share_menu_facebook",) color:facebookColor font:itemFont handler:^{

            VLOShare *shareManager = [VLOShare sharedInstance];

            switch (sharedCellType) {
//                case VLOLogTypeText:
//                    [self shareViaFacebook:shareManager
//                              withTextCell:(VLOTableViewTextCell *) _editingCell];
//                    break;
//                case VLOLogTypeTitle:
//                    [self shareViaFacebook:shareManager
//                             withQuoteCell:(VLOTableViewQuoteCell *) _editingCell];
//                    break;
                case VLOLogTypePhoto:
                    [self shareViaFacebook:shareManager
                             withPhotoCell:(VLOTableViewPhotoCell *) _editingCell];
                    break;
//                case VLOLogTypeMap:
//                    [self shareViaFacebook:shareManager
//                               withMapCell:(VLOTableViewMapCell *) _editingCell];
//                    break;
//                case VLOLogTypeRoute:
//                    [self shareViaFacebook:shareManager
//                             withRouteCell:(VLOTableViewRouteCell *) _editingCell];
//                    break;
                default:
                    // ERROR REPORT
                    break;
            }
            NSInteger cellTarget = 1;
            if (![[VLOLocalStorage getCurrentUser].userId isEqualToString:_editingCell.log.user.userId]) {
                cellTarget = 2;
            }
            [VLOAnalyticsManager reportEventWithCategory:VLOCategoryCellShare action:VLOActionShareCellFB label:[VLOLog typeStringWithType:sharedCellType] andValue:@(cellTarget)];
            [VLOAnalyticsManager facebookTrackingEvent:VLOFBLogShareCellToFB];
            [Flurry logEvent:VLOFlurryCellShareToFacebook withParameters:@{@"cellId" : _editingCell.log.timelineId}];
        }];
        facebookShareItem.backgroundColor = itemColor;
        [shareSection addItem:facebookShareItem];
        if (sharedCellType == VLOLogTypePhoto || sharedCellType == VLOLogTypeRoute) {

            // Share to Instagram
            VLOActionSheetItem *instagramShareItem = [[VLOActionSheetItem alloc] initWithTitle:NSLocalizedString(@"timeline_share_menu_instagram",) color:instagramColor font:itemFont handler:^{

                NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
                BOOL canOpenInstagram = [[UIApplication sharedApplication] canOpenURL:instagramURL];

                if (canOpenInstagram) {



                    UIImage *image = nil;
                    if (sharedCellType == VLOLogTypePhoto) {

                        VLOTableViewPhotoCell *photoCell = (VLOTableViewPhotoCell *) _editingCell;
                        image = [photoCell imageValueForFacebook];

                        NSString *caption = photoCell.photoLog.text;
                        if (caption.length > 0) {
                            [[UIPasteboard generalPasteboard] setString:caption];
                        }
                    }
                    else {
                        VLOTableViewRouteCell *routeCellForShare = [[VLOTableViewRouteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                        routeCellForShare.log = _editingCell.log;
                        image = [routeCellForShare imageValueForFacebook];
                        routeCellForShare = nil;
                    }

                    NSString *photoFilePath = [NSString stringWithFormat:@"%@/voloinstgramphoto.igo", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];

                    [UIImageJPEGRepresentation(image, 1.0) writeToFile:photoFilePath
                                                            atomically:YES];

                    NSURL *fileURL = [NSURL fileURLWithPath:photoFilePath];

                    NSString *caption = @"#withVOLO";
                    _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
                    _documentInteractionController.UTI = @"com.instagram.exclusivegram";
                    _documentInteractionController.delegate = nil;
                    _documentInteractionController.annotation = [NSDictionary dictionaryWithObject:caption forKey:@"InstagramCaption"];
                    [_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];

                    [VLONetwork logInstagramShareInTravel:_travel withSuccess:^{
                    }                             failure:^(NSError *error, NSString *message) {

                    }];
                    NSInteger cellTarget = 1;
                    if (![[VLOLocalStorage getCurrentUser].userId isEqualToString:_editingCell.log.user.userId]) {
                        cellTarget = 2;
                    }
                    [VLOAnalyticsManager reportEventWithCategory:VLOCategoryCellShare action:VLOActionShareCellInsta label:[VLOLog typeStringWithType:sharedCellType] andValue:@(cellTarget)];
                    [VLOAnalyticsManager facebookTrackingEvent:VLOFBLogShareCellToInsta];
                    [Flurry logEvent:VLOFlurryCellShareToInstagram withParameters:@{@"cellId" : _editingCell.log.timelineId}];
                } else {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert_title_instagram_not_found",)
                                                                                             message:NSLocalizedString(@"alert_message_instagram_not_found",)
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"alert_close",)
                                                                          style:UIAlertActionStyleCancel
                                                                        handler:nil];
                    [alertController addAction:closeAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                }

            }];
            instagramShareItem.backgroundColor = itemColor;

            [shareSection addItem:instagramShareItem];
        }
    }

    if (shareSection && (sharedCellType != VLOLogTypeText && sharedCellType != VLOLogTypeTitle) && _travel.privacyType == VLOTravelPrivacyPublicType) {
        [actionSheet addSection:shareSection];
    }

    [actionSheet setCancelTitle:NSLocalizedString(@"actionSheet_cancel", ) andHandler:^{}];

    NSInteger itemsCount = 0;
    for (VLOActionSheetSection *s in actionSheet.sections) {
        itemsCount += s.items.count;
    }

    if (itemsCount) {
        [actionSheet showInViewController:self];
    }

    return actionSheet;
}

- (VLOActionSheet*)showMoreActionSheetWithCellTypeName:(NSString *)type
{
    if (_isOrderChangeMode) {
        return nil;
    }
    UIColor *blackItemColor = [UIColor vlo_blackColor];
    UIColor *redItemColor = [UIColor colorWithHexString:@"ff8791"];

    UIFont *itemFont = [UIFont museoSans500WithSize:15.0f];
    
    
    VLOActionSheet *actionSheet = [[VLOActionSheet alloc] init];
    VLOActionSheetSection *section = [[VLOActionSheetSection alloc] init];
    //VLOActionSheetSection *shareSection;
    
    VLOLogType sharedCellType = _editingCell.log.type;
    if (!_isViewMode) {
        // share
        UIColor *facebookColor = [UIColor colorWithHexString:@"#3A56A1"];
        UIColor *instagramColor = [UIColor colorWithHexString:@"#48769D"];
        UIColor *itemColor = [UIColor whiteColor];

//        shareSection = [[VLOActionSheetSection alloc] init];
//
//        VLOActionSheetItem *facebookShareItem = [[VLOActionSheetItem alloc] initWithTitle:NSLocalizedString(@"timeline_share_menu_facebook", ) color:facebookColor font:itemFont handler:^{
//
//            VLOShare *shareManager = [VLOShare sharedInstance];
//
//            switch(sharedCellType) {
//                case VLOLogTypeText:
//                    [self shareViaFacebook:shareManager
//                              withTextCell:(VLOTableViewTextCell *)_editingCell];
//                    break;
//                case VLOLogTypeTitle:
//                    [self shareViaFacebook:shareManager
//                             withQuoteCell:(VLOTableViewQuoteCell *)_editingCell];
//                    break;
//                case VLOLogTypePhoto:
//                    [self shareViaFacebook:shareManager
//                             withPhotoCell:(VLOTableViewPhotoCell *)_editingCell];
//                    break;
//                case VLOLogTypeMap:
//                    [self shareViaFacebook:shareManager
//                               withMapCell:(VLOTableViewMapCell *)_editingCell];
//                    break;
//                case VLOLogTypeRoute:
//                    [self shareViaFacebook:shareManager
//                             withRouteCell:(VLOTableViewRouteCell *)_editingCell];
//                    break;
//                default:
//                    // ERROR REPORT
//                    break;
//            }
//            NSInteger cellTarget = 1;
//            if (![[VLOLocalStorage getCurrentUser].userId isEqualToString:_editingCell.log.user.userId]) {
//                cellTarget = 2;
//            }
//            [VLOAnalyticsManager reportEventWithCategory:VLOCategoryCellShare action:VLOActionShareCellFB label:[VLOLog typeStringWithType:sharedCellType] andValue:@(cellTarget)];
//            [VLOAnalyticsManager facebookTrackingEvent:VLOFBLogShareCellToFB];
//            [Flurry logEvent:VLOFlurryCellShareToFacebook withParameters:@{@"cellId": _editingCell.log.timelineId}];
//        }];
//        facebookShareItem.backgroundColor = itemColor;
//        [shareSection addItem:facebookShareItem];
//        if (sharedCellType == VLOLogTypePhoto || sharedCellType == VLOLogTypeRoute) {
//
//            // Share to Instagram
//            VLOActionSheetItem *instagramShareItem = [[VLOActionSheetItem alloc] initWithTitle:NSLocalizedString(@"timeline_share_menu_instagram", )  color:instagramColor font:itemFont handler:^{
//
//                NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
//                BOOL canOpenInstagram = [[UIApplication sharedApplication] canOpenURL:instagramURL];
//
//                if (canOpenInstagram) {
//                    UIImage *image;
//                    if (sharedCellType == VLOLogTypePhoto) {
//                        VLOTableViewPhotoCell *photoCell = (VLOTableViewPhotoCell *)_editingCell;
//                        image = [photoCell imageValueForInstagram];
//                    }
//                    else {
//                        VLOTableViewRouteCell *routeCellForShare = [[VLOTableViewRouteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//                        routeCellForShare.log = _editingCell.log;
//                        image = [routeCellForShare imageValueForInstagram];
//                        routeCellForShare = nil;
//                    }
//
//                    NSString *photoFilePath = [NSString stringWithFormat:@"%@/voloinstgramphoto.igo",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
//
//                    [UIImageJPEGRepresentation(image, 1.0) writeToFile:photoFilePath
//                                                            atomically:YES];
//
//                    NSURL *fileURL = [NSURL fileURLWithPath:photoFilePath];
//
//                    NSString *caption = @"#withVOLO";
//                    _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
//                    _documentInteractionController.UTI = @"com.instagram.exclusivegram";
//                    _documentInteractionController.delegate = nil;
//                    _documentInteractionController.annotation = [NSDictionary dictionaryWithObject:caption forKey:@"InstagramCaption"];
//                    [_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
//
//                    [VLONetwork logInstagramShareInTravel:_travel withSuccess:^{
//                    } failure:^(NSError *error, NSString *message) {
//
//                    }];
//                    NSInteger cellTarget = 1;
//                    if (![[VLOLocalStorage getCurrentUser].userId isEqualToString:_editingCell.log.user.userId]) {
//                        cellTarget = 2;
//                    }
//                    [VLOAnalyticsManager reportEventWithCategory:VLOCategoryCellShare action:VLOActionShareCellInsta label:[VLOLog typeStringWithType:sharedCellType] andValue:@(cellTarget)];
//                    [VLOAnalyticsManager facebookTrackingEvent:VLOFBLogShareCellToInsta];
//                    [Flurry logEvent:VLOFlurryCellShareToInstagram withParameters:@{@"cellId": _editingCell.log.timelineId}];
//                } else {
//                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"alert_title_instagram_not_found", )
//                                                                                             message:NSLocalizedString(@"alert_message_instagram_not_found", )
//                                                                                      preferredStyle:UIAlertControllerStyleAlert];
//                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"alert_close", )
//                                                                          style:UIAlertActionStyleCancel
//                                                                        handler:nil];
//                    [alertController addAction:closeAction];
//                    [self presentViewController:alertController animated:YES completion:nil];
//                }
//
//            }];
//            instagramShareItem.backgroundColor = itemColor;
//
//            [shareSection addItem:instagramShareItem];
//        }
        
        
        // menu
        
        BOOL isMyLog = [_editingCell.log.user.userId isEqualToString:[VLOLocalStorage getCurrentUser].userId];
        
        NSString *addBelowTitleFormatStr = NSLocalizedString(@"timeline_more_addtobelow", );
        NSString *addBelowTitle = [NSString stringWithFormat:addBelowTitleFormatStr, type];
        VLOActionSheetItem *addBelowItem = [[VLOActionSheetItem alloc] initWithTitle:addBelowTitle
                                                                               color:blackItemColor
                                                                                font:itemFont
                                                                             handler:^{
            //todo: INSERT TABLEVIEWCELL   
                                                                                 
            _addToBelowPivotLog = _editingCell.log;
            [self.delegate timelineTableViewController:self didAddToBelowOfLog:_addToBelowPivotLog];
        }];
        
        if (isMyLog) {
            VLOActionSheetItem *editItem = [[VLOActionSheetItem alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"actionSheet_editCell", ), type]
                                                                               color:blackItemColor
                                                                                font:itemFont
                                                                             handler:^{
                [self.delegate timelineTableViewController:self didEditingWasStarted:YES];
                [self editCell];
                [VLOAnalyticsManager reportEventWithCategory:VLOCategoryCellMenu action:VLOActionEdit label:[VLOLog typeStringWithType:sharedCellType] andValue:nil];
            }];
            [section addItem:editItem];
            
            [section addItem:addBelowItem];
            
            NSString *changeOrderItemTitle = [NSString stringWithFormat:NSLocalizedString(@"actionSheet_changeOrder", ) ,type];
            VLOActionSheetItem *orderChange = [[VLOActionSheetItem alloc] initWithTitle:changeOrderItemTitle
                                                                                  color:blackItemColor
                                                                                   font:itemFont
                                                                                handler:^{
                [self startOrderChangeModeWithLog:_editingCell.log];
            }];
            [section addItem:orderChange];
            
            
            
            NSString *removeItemFormatStr = NSLocalizedString(@"actionSheet_removeItem", );
            NSString *removeItemTitle = [NSString stringWithFormat:removeItemFormatStr, type];
            VLOActionSheetItem *removeItem =
            [[VLOActionSheetItem alloc] initWithTitle:removeItemTitle
                                                color:redItemColor
                                                 font:itemFont
                                              handler:^{
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_confirm_title", )
                                                                 message:NSLocalizedString(@"alert_confirm_contents_item", )
                                                                delegate:self
                                                       cancelButtonTitle:NSLocalizedString(@"alert_no", )
                                                       otherButtonTitles:NSLocalizedString(@"alert_yes", ), nil];
                 [alert show];
                 [VLOAnalyticsManager reportEventWithCategory:VLOCategoryCellMenu action:VLOActionDelete label:[VLOLog typeStringWithType:sharedCellType] andValue:nil];
             }];
            //[section addItem:removeItem];
            actionSheet.cancelSectionItems = [NSMutableArray arrayWithObject:removeItem];
        }
        else if (_editingCell.log.type == VLOLogTypePhoto) {
            VLOActionSheetItem *editItem = [[VLOActionSheetItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"actionSheet_add", ), type]  color:[UIColor colorWithHexString:@"#32729b"] font:itemFont handler:^{
                [self.delegate timelineTableViewController:self didEditingWasStarted:YES];
                [self editCell];
            }];
            [editItem setIsAddPhotoItem:YES andUserProfileImage:((VLOProfileImageView *)[_editingCell.footerView.userViews firstObject]).image];
            
            VLOActionSheetSection *addPhotoSection = [[VLOActionSheetSection alloc] initWithItems:@[editItem, addBelowItem]];
            
            [actionSheet addSection:addPhotoSection];
        } else {
            VLOActionSheetSection *addBelowSection = [[VLOActionSheetSection alloc] initWithItems:@[addBelowItem]];
            
            [actionSheet addSection:addBelowSection];
        }
    }
    
    [actionSheet addSection:section];
//    if (shareSection && (sharedCellType != VLOLogTypeText && sharedCellType != VLOLogTypeTitle) && _travel.privacyType == VLOTravelPrivacyPublicType) {
//        [actionSheet addSection:shareSection];
//    }

    [actionSheet setCancelTitle:NSLocalizedString(@"actionSheet_cancel", ) andHandler:^{
    }];

    NSInteger itemsCount = 0;
    for (VLOActionSheetSection *s in actionSheet.sections) {
        itemsCount += s.items.count;
    }

    if (itemsCount) {
        [actionSheet showInViewController:self];
    }

    return actionSheet;
}


#pragma mark - order change

- (void)startOrderChangeModeWithLog:(VLOLog *)log
{
    if ([_delegate respondsToSelector:@selector(timelineTableViewController:didChangingOrderStarted:)]) {
        [_delegate timelineTableViewController:self didChangingOrderStarted:YES];
    }
    _isOrderChangeMode = !_isOrderChangeMode;
    _orderChangeRow = [_logs indexOfObject:log];
    _orderChangingLog = log;
    [self.tableView reloadData];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.tableView.transform = CGAffineTransformMakeScale(VLO_REARRANGEPER, VLO_REARRANGEPER);
    } completion:nil];
    
    [_indicator setHidden:YES];
}

- (void)endOrderChangeModeWithIsChanged:(BOOL)isChanged
{
    _isOrderChangeModeAppear = YES;
    _isOrderChangeMode = NO;
    
    if (!isChanged) {
        [self cancelOrderChangeModeWithLog:_editingCell.log];
    }
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.tableView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        for (VLOTimelineCell *cell in [self.tableView visibleCells]) {
            cell.orderChangeBelowMark.alpha = 0.0f;
            cell.footerView.alpha = 1.0f;
            cell.orderChangeBackground.alpha = 0.0f;
        }
    } completion:^(BOOL finished) {
    }];
    
    [_indicator setHidden:NO];
}

- (void)cancelOrderChangeModeWithLog:(VLOLog *)log
{
    if ([_delegate respondsToSelector:@selector(timelineTableViewController:didChangingOrderStarted:)]) {
        [_delegate timelineTableViewController:self didChangingOrderStarted:NO];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        if (_editingCell.log.type == VLOLogTypePhoto) {
            [UIView animateWithDuration:.5f animations:^{
                ((VLOTableViewPhotoCell *)_editingCell).contentView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [self removeLog:_editingCell.log forUserAction:YES];
            }];
        } else {
            [self removeLog:_editingCell.log forUserAction:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VLOLog *log = [_logs objectAtIndex:indexPath.row];
    if(log.type == VLOLogTypeDay){
//        VLODatePickerViewController *datePicker = [[VLODatePickerViewController alloc] initWithFirstDate:_travel.startDate lastDate:_travel.endDate travelStartDate:_travel.startDate andSelectedDate:log.date andCompletion:^(NSDate *selectedDate) {
//        }];
//        datePicker.doneButton.hidden = YES;
        
//        VLODatePickerViewController *datePicker = [[VLODatePickerViewController alloc] initForDayCellWithFirstDate:_travel.startDate lastDate:_travel.endDate travelStartDate:_travel.startDate andSelectedDate:log.date];
//        [self presentViewController:datePicker animated:YES completion:nil];
    }
}

- (void)editCell
{
    VLOLog *log = [VLOLocalStorage loadTimelineCellIn:_travel cellId:_editingCell.log.timelineId];
    if (!log) {
        return;
    }
    log.previousCellId = _editingCell.log.previousCellId;
    [_logs replaceObjectAtIndex:[_logs indexOfObject:_editingCell.log] withObject:log];
    _editingCell.log = log;
    if (log.type == VLOLogTypeText) {
        VLOTextEditorViewController *editor = [[VLOTextEditorViewController alloc] initWithTravel:_travel withType:VLOTextEditorTypeModification andLog:(VLOTextLog *)log];
        editor.delegate = self;
        VLOTextEditorNavigationController *navigation = [[VLOTextEditorNavigationController alloc] initWithRootViewController:editor];
        
        [self presentViewController:navigation animated:YES completion:nil];
    }
    else if (log.type == VLOLogTypeTitle) {
        VLOQuoteEditorViewController *editor = [self.parentViewController.storyboard instantiateViewControllerWithIdentifier:VLOQuoteEditorStoryboardID];
        editor.isModificationMode = YES;
        editor.modificationTitleLog = (VLOQuoteLog *)log;
        editor.modificationDelegate = self;
        editor.travel = _travel;
        editor.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        [self presentViewController:editor animated:NO completion:nil];
    }
    else if (log.type == VLOLogTypePhoto) {
        VLOPhotoLogEditorViewController *editor = [[VLOPhotoLogEditorViewController alloc] initWithLog:(VLOPhotoLog *)log
                                                                                                travel:_travel
                                                                                               andType:VLOPhotoLogEditorTypeModification];
        editor.delegate = self;
        VLOPhotoLogEditorNavigationController *navigation = [[VLOPhotoLogEditorNavigationController alloc] initWithRootViewController:editor];
        [self presentViewController:navigation animated:YES completion:nil];
        _isPhotoEditingMode = YES;
        
        if (![log.user.userId isEqualToString:[VLOLocalStorage getCurrentUser].userId]) {
            NSString *userCount = [NSString stringWithFormat:@"%ld", _travel.users.count];
            NSInteger photoCount = ((VLOPhotoLog *)log).photos.count;
            [VLOAnalyticsManager reportEventWithCategory:VLOCategoryCellMenu action:VLOActionAddPhoto label:userCount andValue:@(photoCount)];
        }
    }
    else if (log.type == VLOLogTypeMap) {
        VLOMapEditorViewController *mapEditor = [[VLOMapEditorViewController alloc] initWithTravel:_travel withType:VLOMapEditorTypeModification andMapLog:(VLOMapLog *)log];
        mapEditor.delegate = self;
        VLOMapEditorNavigationController *navigation = [[VLOMapEditorNavigationController alloc] initWithRootViewController:mapEditor];
        [self presentViewController:navigation animated:YES completion:nil];
    }
    else if (log.type == VLOLogTypeRoute) {
        VLORouteEditorViewController *editor = [[VLORouteEditorViewController alloc] initWithTravel:_travel andLog:(VLORouteLog *)log];
        VLORouteEditorNavigationController *navigationController = [[VLORouteEditorNavigationController alloc] initWithRootViewController:editor];
        editor.delegate = self;
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}


#pragma mark - text cell delegate

- (void)textCell:(VLOTableViewTextCell *)textCell DidLoadNewSticker:(VLOSticker *)sticker
{
    if (textCell && [self.tableView indexPathForCell:textCell]) {
        [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:textCell]] withRowAnimation:UITableViewRowAnimationNone];
    }
}


#pragma mark - Quote View Controller Delegate

- (void)quoteEditorDidClosed:(VLOQuoteEditorViewController *)editor
{
    [VLOAnalyticsManager reportScreenWithName:kVLOScreenNameTimeline];
}


#pragma mark - Editor modification delegate

- (void)textEditor:(VLOTextEditorViewController *)textEditor didDoneWithTextLog:(VLOTextLog *)log isChangeDate:(BOOL)dateChanged
{
    [self updateLog:log isChangeDate:dateChanged];
}

- (void)quoteEditor:(VLOQuoteEditorViewController *)editor didModify:(VLOQuoteLog *)log isChangeDate:(BOOL)isChange
{
    [self updateLog:log isChangeDate:isChange];
}

- (void)mapEditor:(VLOMapEditorViewController *)mapEditorViewController didDoneWithLog:(VLOMapLog *)log isChangeDate:(BOOL)changeDate
{
    [self updateLog:log isChangeDate:changeDate];
}

- (void)photoLogEditor:(VLOPhotoLogEditorViewController *)editor didModify:(VLOPhotoLog *)log isChangeDate:(BOOL)isChange
{
    _isPhotoEditingMode = NO;
    [self updateLog:log isChangeDate:isChange];
}

- (void)photoLogEditor:(VLOPhotoLogEditorViewController *)editor didAddPhoto:(VLOPhotoLog *)log
{
    _isPhotoEditingMode = NO;
    [self updateAddPhotoLog:log];
    
    NSString *userCount = [NSString stringWithFormat:@"%ld", _travel.users.count];
    NSInteger addedPhotoCount = 0;
    for (VLOPhoto *photo in log.photos) {
        if ([photo.user.userId isEqualToString:[VLOLocalStorage getCurrentUser].userId]) {
            addedPhotoCount += 1;
        }
    }
    [VLOAnalyticsManager reportEventWithCategory:VLOCategoryAddPhoto action:VLOActionDone label:userCount andValue:@(addedPhotoCount)];
    [Flurry logEvent:VLOFlurryAppendPhoto withParameters:@{@"travelId": _travel.serverId, @"photoCellId": log.timelineId}];
}

- (void)photoLogEditorDidClose:(VLOPhotoLogEditorViewController *)editor
{
    _isPhotoEditingMode = NO;
}

- (void)routeEditor:(VLORouteEditorViewController *)routeEditor didFinishEditWithLog:(VLORouteLog *)log isChangeDate:(BOOL)changed
{
    [self updateLog:log isChangeDate:changed];
}


#pragma mark - timeline state

- (BOOL)isOnWriting
{
    if ([[NSDate date] timeIntervalSince1970] - [_lastWroteDate timeIntervalSince1970] < 60 * 10) {
        return YES;
    }
    return NO;
}

- (void)setTimelineLastStateInfoForEmpty
{
    VLOLog *tampLogForEmptyTravel = [[VLOLog alloc] init];
    NSTimeInterval halfDayTimeInterval = 12*3600;
    tampLogForEmptyTravel.date = [_travel.startDate dateByAddingTimeInterval:halfDayTimeInterval];
    tampLogForEmptyTravel.timezone = _travel.timezone;
    [self setTimelineLastStateInfoWithLog:tampLogForEmptyTravel];
}

- (void)setTimelineLastStateInfoWithLog:(VLOLog *)log
{
    [[NSUserDefaults standardUserDefaults] setObject:@([log.date timeIntervalSince1970]) forKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastDate]];
    [[NSUserDefaults standardUserDefaults] setObject:@([[log.timezone getNSTimezone] secondsFromGMT]) forKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastTimeZone]];
    [[NSUserDefaults standardUserDefaults] setObject:@([[NSDate date] timeIntervalSince1970]) forKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastWroteDate]];
    
    _lastDate = [self getTimelineLastDate];
    _lastTimeZone = [self getTimelineLastTimeZone];
    _lastWroteDate = [self getTimelineLastWroteDate];
    
    [[NSUserDefaults standardUserDefaults] setObject:_lastWroteDate forKey:VLOLastOpenedTimelineLastWroteDateKey];
}

- (void)setTimelineInfoLastViewDate
{
    [[NSUserDefaults standardUserDefaults] setObject:@([[NSDate date] timeIntervalSince1970]) forKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastViewDate]];
}

- (NSDate *)getTimelineLastDate
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastDate]]) {
        return [NSDate dateWithTimeIntervalSince1970:[[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastDate]] doubleValue]];
    }
    return nil;
}

- (NSDate *)getTimelineLastViewDate
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastViewDate]]) {
        return [NSDate dateWithTimeIntervalSince1970:[[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastViewDate]] doubleValue]];
    }
    return nil;
}

- (NSTimeZone *)getTimelineLastTimeZone
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastTimeZone]]) {
        return [NSTimeZone timeZoneForSecondsFromGMT:[[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastTimeZone]] integerValue]];
    }
    return nil;
}

- (NSDate *)getTimelineLastWroteDate
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastWroteDate]]) {
        return [NSDate dateWithTimeIntervalSince1970:[[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastWroteDate]] doubleValue]];
    }
    return nil;
}

- (NSNumber *)getTimelineLastContentOffset
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastContentOffset]]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastContentOffset]];
    }
    return nil;
}

- (void)setTimelineLastContentOffset:(NSNumber *)offset
{
    [[NSUserDefaults standardUserDefaults] setObject:offset forKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoLastContentOffset]];
}

- (BOOL)hasBeenOpened
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoHasBeenOpened]]) {
        return YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@%@%@", _travel.travelId, VLOTimelineInfoKeyPrefix, VLOTimelineInfoHasBeenOpened]];
    return NO;
}


#pragma mark - share via facebook

- (void)shareViaFacebook:(VLOShare *)shareManager
           withPhotoCell:(VLOTableViewPhotoCell *)photoCell
{

    UIImage *collaged = [photoCell imageValueForFacebook];

    VLOShare *shareUtil = [VLOShare sharedInstance];
    [shareUtil shareCollagedPhotoViaFacebookWithPhoto:collaged
                                              caption:photoCell.photoLog.text
                                   fromViewController:self];

}

//- (void)shareViaFacebook:(VLOShare *)shareManager
//           withTextCell:(VLOTableViewTextCell *)textCell
//{
//    NSLog(@"%s", __FUNCTION__);
//    VLOTextLog *textLog = (VLOTextLog *) textCell.log;
//    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//
//    // TODO: set proper handlers
//    if (textLog.text.length > 0) {
//        [[UIPasteboard generalPasteboard] setString:textLog.text];
//    }
//
//    VLOShareCompletion onCompletion = ^(NSDictionary *result)
//    {
//        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"share_fb_alert_success_title",)];
//        VLOShareAlert *alert = [[VLOShareAlert alloc] initWithTitle:msg];
//        [alert showInViewController:self];
//    };
//    VLOShareFailure onFailure = ^(NSError *error)
//    {
//        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"share_fb_alert_failure_contents",), @"Text"];
//        VLOShareAlert *alert = [[VLOShareAlert alloc] initWithTitle:msg];
//        [alert showInViewController:self];
//    };
//
//    [shareManager shareViaFacebookWithFromViewController:self
//                                                 content:content
//                                       completionHandler:onCompletion
//                                               onFailure:onFailure
//                                                onCancel:nil];
//}

//- (void)shareViaFacebook:(VLOShare *)shareManager
//             withMapCell:(VLOTableViewMapCell *)mapCell
//{
//    NSLog(@"%s", __FUNCTION__);
//    VLOMapLog *mapLog = (VLOMapLog *)mapCell.log;
//    NSString *ancestorId = mapLog.ancestorId;
//    NSString *timelineId = mapLog.timelineId;
//    if (ancestorId.length < 12) {
//        ancestorId = timelineId;
//    }
//    ancestorId = [ancestorId substringToIndex:12];
//    timelineId = [timelineId substringToIndex:12];
//    NSString *parameterString = [NSString stringWithFormat:@"/location/%@?hash=%@", ancestorId, timelineId];
//
//    VLOUser *user = [VLOLocalStorage getCurrentUser];
//    NSString *link = _travel.url;
//    link = [link stringByReplacingOccurrencesOfString:@"$$CANONICAL$$" withString:user.userName];
//    link = [link stringByAppendingString:parameterString];
//
//    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//    content.contentURL = [NSURL URLWithString:link];
//
//    if (mapLog.caption.length > 0) {
//        [[UIPasteboard generalPasteboard] setString:mapLog.caption];
//    }
//
//    VLOShareCompletion onCompletion = ^(NSDictionary *result)
//    {
//        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"share_fb_alert_success_title",)];
//        VLOShareAlert *alert = [[VLOShareAlert alloc] initWithTitle:msg];
//        [alert showInViewController:self];
//    };
//    VLOShareFailure onFailure = ^(NSError *error)
//    {
//        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"share_fb_alert_failure_contents",), @"Map"];
//        VLOShareAlert *alert = [[VLOShareAlert alloc] initWithTitle:msg];
//        [alert showInViewController:self];
//    };
//    VLOShareCancel onCancel = ^
//    {
//        VLOShareAlert *alert = [[VLOShareAlert alloc] initWithTitle:NSLocalizedString(@"share_fb_alert_cancel_contents",)];
//        [alert showInViewController:self];
//    };
//    [shareManager shareViaFacebookWithFromViewController:self
//                                                 content:content
//                                       completionHandler:onCompletion
//                                               onFailure:onFailure
//                                                onCancel:onCancel];
//}
//
//- (void)shareViaFacebook:(VLOShare *)shareManager
//           withRouteCell:(VLOTableViewRouteCell *)routeCell
//{
//    NSLog(@"%s", __FUNCTION__);
//    VLOTableViewRouteCell *routeCellForShare = [[VLOTableViewRouteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    routeCellForShare.log = routeCell.log;
////    NSData *photoParam = UIImagePNGRepresentation([routeCellForShare imageValueForFacebook]);
//
//    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
//    photo.image = [routeCellForShare imageValueForFacebook];
//    photo.userGenerated = YES;
//
//    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
//    content.photos = @[photo];
//
//    VLOShareCompletion onCompletion = ^(NSDictionary *result)
//    {
//        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"share_fb_alert_success_title",)];
//        VLOShareAlert *alert = [[VLOShareAlert alloc] initWithTitle:msg];
//        [alert showInViewController:self];
//    };
//    VLOShareFailure onFailure = ^(NSError *error)
//    {
//        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"share_fb_alert_failure_contents",), @"Route"];
//        VLOShareAlert *alert = [[VLOShareAlert alloc] initWithTitle:msg];
//        [alert showInViewController:self];
//    };
//    VLOShareCancel onCancel = ^
//    {
//        VLOShareAlert *alert = [[VLOShareAlert alloc] initWithTitle:NSLocalizedString(@"share_fb_alert_cancel_contents",)];
//        [alert showInViewController:self];
//    };
//    [shareManager shareViaFacebookWithFromViewController:self
//                                                 content:content
//                                       completionHandler:onCompletion
//                                               onFailure:onFailure
//                                                onCancel:onCancel];
//}
//
//
//- (void)shareViaFacebook:(VLOShare *)shareManager
//          withQuoteCell:(VLOTableViewQuoteCell *)quoteCell
//{
//    NSLog(@"%s", __FUNCTION__);
//    VLOQuoteLog *textLog = (VLOQuoteLog *) quoteCell.log;
//    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
//
//    if (textLog.text.length > 0) {
//        [[UIPasteboard generalPasteboard] setString:textLog.text];
//    }
//
//    VLOShareCompletion onCompletion = ^(NSDictionary *result ){
//        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"share_fb_alert_success_title", )];
//        VLOShareAlert *alert = [[VLOShareAlert alloc] initWithTitle:msg];
//        [alert showInViewController:self];
//    };
//    VLOShareFailure onFailure = ^(NSError *error){
//        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"share_fb_alert_failure_contents", ), @"Quote"];
//        VLOShareAlert *alert = [[VLOShareAlert alloc] initWithTitle:msg];
//        [alert showInViewController:self];
//    };
//    VLOShareCancel onCancel = ^{
//        VLOShareAlert *alert = [[VLOShareAlert alloc] initWithTitle:NSLocalizedString(@"share_fb_alert_cancel_contents", )];
//        [alert showInViewController:self];
//    };
//    [shareManager shareViaFacebookWithFromViewController:self
//                                                 content:content
//                                       completionHandler:onCompletion
//                                               onFailure:onFailure
//                                                onCancel:onCancel];
//}

@end
